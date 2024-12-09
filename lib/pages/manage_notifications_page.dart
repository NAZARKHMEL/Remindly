import 'package:flutter/material.dart';
import '../models/notification_data.dart';
import 'edit_notification_page.dart';
import 'package:intl/intl.dart';

class ManageNotificationsPage extends StatelessWidget {
  final List<NotificationData> notifications;
  final Future<void> Function(int) cancelNotification;
  final Future<void> Function(NotificationData, DateTime, String) editNotification; // Modified to accept NotificationData

  ManageNotificationsPage({
    required this.notifications,
    required this.cancelNotification,
    required this.editNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            title: Text(notification.message),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(notification.scheduledDate)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // You can add code to allow the user to edit the notification here.
                    // After they edit, call editNotification.
                    DateTime newScheduledDate = DateTime.now().add(Duration(hours: 1)); // Example
                    String newMessage = "Updated notification message"; // Example
                    editNotification(notification, newScheduledDate, newMessage); // Pass NotificationData here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    cancelNotification(notification.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}