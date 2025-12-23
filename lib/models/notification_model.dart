enum NotificationType {
  taskAssigned,
  taskUpdated,
  taskCompleted,
  messageReceived,
  announcement,
  feedbackResponse,
  serviceUpdate,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? relatedId; // ID of related task, message, etc.
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => NotificationType.announcement,
      ),
      relatedId: map['relatedId'],
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'relatedId': relatedId,
      'timestamp': timestamp,
      'isRead': isRead,
      'data': data,
    };
  }
}

