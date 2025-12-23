import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Stream<List<TaskModel>> getTasksForUser(String userId) {
    return _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<TaskModel>> getAllTasks() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (doc.exists) {
        return TaskModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  Future<String> createTask(TaskModel task) async {
    try {
      final taskId = _uuid.v4();
      await _firestore.collection('tasks').doc(taskId).set({
        ...task.copyWith(id: taskId).toMap(),
        'id': taskId,
      });
      return taskId;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> updateTaskProgress(String taskId, int progress) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'progress': progress,
        'status': progress == 100
            ? TaskStatus.completed.toString().split('.').last
            : TaskStatus.inProgress.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  Future<void> addComment(String taskId, CommentModel comment) async {
    try {
      final task = await getTaskById(taskId);
      if (task != null) {
        final updatedComments = [...task.comments, comment];
        await _firestore.collection('tasks').doc(taskId).update({
          'comments': updatedComments.map((c) => c.toMap()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}

