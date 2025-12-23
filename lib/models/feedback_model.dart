enum FeedbackStatus { pending, reviewed, resolved }

class FeedbackModel {
  final String id;
  final String customerId;
  final String customerName;
  final String subject;
  final String message;
  final FeedbackStatus status;
  final DateTime createdAt;
  final String? response;
  final DateTime? respondedAt;

  FeedbackModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.subject,
    required this.message,
    this.status = FeedbackStatus.pending,
    required this.createdAt,
    this.response,
    this.respondedAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => FeedbackStatus.pending,
      ),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      response: map['response'],
      respondedAt: map['respondedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'subject': subject,
      'message': message,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'response': response,
      'respondedAt': respondedAt,
    };
  }

  FeedbackModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? subject,
    String? message,
    FeedbackStatus? status,
    DateTime? createdAt,
    String? response,
    DateTime? respondedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

