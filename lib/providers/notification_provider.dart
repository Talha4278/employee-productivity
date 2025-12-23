import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  void loadNotificationsForUser(String userId) {
    _notificationService.getNotificationsForUser(userId).listen((notifications) {
      _notifications = notifications;
      _unreadCount = notifications.where((n) => !n.isRead).length;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendNotification(
    String userId,
    String title,
    String body,
    NotificationType type, {
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendNotificationToUser(
        userId,
        title,
        body,
        type,
        relatedId: relatedId,
        data: data,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<String?> getFCMToken() async {
    return await _notificationService.getFCMToken();
  }

  Future<void> saveFCMToken(String userId, String token) async {
    await _notificationService.saveFCMToken(userId, token);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

