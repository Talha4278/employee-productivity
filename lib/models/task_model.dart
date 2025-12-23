enum TaskStatus { pending, inProgress, completed, cancelled }
enum TaskPriority { low, medium, high, urgent }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;
  final String createdByName;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int progress; // 0-100
  final List<String> tags;
  final List<CommentModel> comments;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByName,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
    this.progress = 0,
    this.tags = const [],
    this.comments = const [],
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      assignedToName: map['assignedToName'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      dueDate: map['dueDate']?.toDate(),
      progress: map['progress'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      comments: (map['comments'] as List<dynamic>?)
          ?.map((c) => CommentModel.fromMap(c))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'progress': progress,
      'tags': tags,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    int? progress,
    List<String>? tags,
    List<CommentModel>? comments,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      progress: progress ?? this.progress,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
    );
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'message': message,
      'timestamp': timestamp,
    };
  }
}

