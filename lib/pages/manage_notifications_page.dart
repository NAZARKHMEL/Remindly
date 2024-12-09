import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_notification_page.dart';
import '../models/notification_data.dart';
import '../sharedpreferences.dart';  // Import your NotificationStorage

class ManageNotificationsPage extends StatefulWidget {
  @override
  _ManageNotificationsPageState createState() => _ManageNotificationsPageState();
}

class _ManageNotificationsPageState extends State<ManageNotificationsPage> {
  List<NotificationData> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Load notifications from SharedPreferences using NotificationStorage
  Future<void> _loadNotifications() async {
    _notifications = await NotificationStorage.loadNotifications();
    setState(() {});
  }

  // Delete a notification
  Future<void> _deleteNotification(int id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await NotificationStorage.saveNotifications(_notifications);  // Save updated list
    setState(() {});
  }

  // Update a notification
  void _updateNotification(NotificationData notification, DateTime newDate, String newMessage) {
    notification.scheduledDate = newDate;
    notification.message = newMessage;

    // Save updated notifications list to SharedPreferences
    NotificationStorage.saveNotifications(_notifications);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список напоминаний'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification.message),
            subtitle: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(notification.scheduledDate),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditNotificationPage(
                        notification: notification,
                        onEdit: (newDate, newMessage) {
                          _updateNotification(notification, newDate, newMessage);
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteNotification(notification.id);
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
