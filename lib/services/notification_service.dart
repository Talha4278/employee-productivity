import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> initialize() async {
    // Request permission for notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      // Store token in Firestore for the current user
      // This should be called after user login
    }
  }

  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  Future<void> saveFCMToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Future<void> createNotification(
    NotificationModel notification,
    String userId,
  ) async {
    try {
      final notificationData = notification.toMap();
      notificationData['userId'] = userId;
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notificationData);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  Future<void> sendNotificationToUser(
    String userId,
    String title,
    String body,
    NotificationType type, {
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'];

      // Create local notification record
      final notification = NotificationModel(
        id: _uuid.v4(),
        title: title,
        body: body,
        type: type,
        relatedId: relatedId,
        timestamp: DateTime.now(),
        data: data,
      );

      // Add userId to notification data for Firestore query
      final notificationData = notification.toMap();
      notificationData['userId'] = userId;

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notificationData);

      // Send push notification via FCM
      // Note: In production, this should be done via a backend service
      // For now, we'll just create the notification record
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }
}

