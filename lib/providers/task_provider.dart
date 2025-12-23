import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<TaskModel> _tasks = [];
  TaskModel? _selectedTask;
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get tasks => _tasks;
  TaskModel? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => t.status == TaskStatus.pending).toList();

  List<TaskModel> get inProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList();

  void loadTasksForUser(String userId) {
    _taskService.getTasksForUser(userId).listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  void loadAllTasks() {
    _taskService.getAllTasks().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  Future<void> loadTaskById(String taskId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedTask = await _taskService.getTaskById(taskId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createTask(TaskModel task) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _taskService.createTask(task);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _taskService.updateTask(task);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTaskProgress(String taskId, int progress) async {
    try {
      await _taskService.updateTaskProgress(taskId, progress);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _taskService.updateTaskStatus(taskId, status);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment(String taskId, CommentModel comment) async {
    try {
      await _taskService.addComment(taskId, comment);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _taskService.deleteTask(taskId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectTask(TaskModel? task) {
    _selectedTask = task;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

