import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/comment_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  final String? taskId;

  const TaskDetailScreen({super.key, this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commentController = TextEditingController();
  TaskStatus _selectedStatus = TaskStatus.pending;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  int _progress = 0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadTask();
    } else {
      _isEditing = true;
    }
  }

  Future<void> _loadTask() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.loadTaskById(widget.taskId!);
    final task = taskProvider.selectedTask;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedStatus = task.status;
      _selectedPriority = task.priority;
      _selectedDueDate = task.dueDate;
      _progress = task.progress;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final currentUser = authProvider.currentUser!;

    final task = TaskModel(
      id: widget.taskId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      assignedTo: widget.taskId != null
          ? taskProvider.selectedTask!.assignedTo
          : currentUser.id,
      assignedToName: widget.taskId != null
          ? taskProvider.selectedTask!.assignedToName
          : currentUser.name,
      createdBy: currentUser.id,
      createdByName: currentUser.name,
      status: _selectedStatus,
      priority: _selectedPriority,
      createdAt: widget.taskId != null
          ? taskProvider.selectedTask!.createdAt
          : DateTime.now(),
      dueDate: _selectedDueDate,
      progress: _progress,
    );

    final success = widget.taskId != null
        ? await taskProvider.updateTask(task)
        : await taskProvider.createTask(task);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskProvider.errorMessage ?? 'Failed to save task')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final currentUser = authProvider.currentUser!;

    final comment = CommentModel(
      id: const Uuid().v4(),
      userId: currentUser.id,
      userName: currentUser.name,
      message: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    final success = await taskProvider.addComment(widget.taskId!, comment);

    if (!mounted) return;

    if (success) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final task = widget.taskId != null ? taskProvider.selectedTask : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId != null ? 'Task Details' : 'New Task'),
        actions: [
          if (widget.taskId != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveTask();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              enabled: _isEditing || widget.taskId == null,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              enabled: _isEditing || widget.taskId == null,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing || widget.taskId == null) ...[
              DropdownButtonFormField<TaskStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  _selectedDueDate != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDueDate!)
                      : 'No due date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDueDate = date;
                    });
                  }
                },
              ),
            ] else ...[
              _buildInfoRow('Status', task!.status.toString().split('.').last),
              _buildInfoRow('Priority', task.priority.toString().split('.').last),
              if (task.dueDate != null)
                _buildInfoRow(
                  'Due Date',
                  DateFormat('yyyy-MM-dd').format(task.dueDate!),
                ),
            ],
            const SizedBox(height: 16),
            Text('Progress: $_progress%'),
            Slider(
              value: _progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '$_progress%',
              onChanged: (_isEditing || widget.taskId == null)
                  ? (value) {
                      setState(() {
                        _progress = value.toInt();
                      });
                    }
                  : null,
            ),
            if (widget.taskId != null) ...[
              const Divider(),
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...task!.comments.map((comment) => CommentWidget(comment: comment)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}

