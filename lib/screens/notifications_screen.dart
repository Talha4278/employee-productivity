import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view notifications')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton(
              onPressed: () {
                notificationProvider.markAllAsRead(currentUser.id);
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: notificationProvider.notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: notification.isRead ? null : Colors.blue[50],
                  child: ListTile(
                    leading: _getNotificationIcon(notification.type),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: notification.isRead
                        ? null
                        : const Icon(Icons.circle, size: 8, color: Colors.blue),
                    onTap: () {
                      notificationProvider.markAsRead(notification.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.taskAssigned:
      case NotificationType.taskUpdated:
      case NotificationType.taskCompleted:
        icon = Icons.task;
        color = Colors.blue;
        break;
      case NotificationType.messageReceived:
        icon = Icons.message;
        color = Colors.green;
        break;
      case NotificationType.announcement:
        icon = Icons.announcement;
        color = Colors.orange;
        break;
      case NotificationType.feedbackResponse:
        icon = Icons.feedback;
        color = Colors.purple;
        break;
      case NotificationType.serviceUpdate:
        icon = Icons.business;
        color = Colors.teal;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

