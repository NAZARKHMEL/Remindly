import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_notification_page.dart';
import '../models/notification_data.dart';
import '../sharedpreferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class ManageNotificationsPage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final List<NotificationData> notifications; // Notifications to manage
  final Function(List<NotificationData>) onNotificationsUpdated; // Callback for updates

  const ManageNotificationsPage({
    Key? key,
    required this.flutterLocalNotificationsPlugin,
    required this.notifications,
    required this.onNotificationsUpdated,
  }) : super(key: key);

  @override
  _ManageNotificationsPageState createState() => _ManageNotificationsPageState();
}


class _ManageNotificationsPageState extends State<ManageNotificationsPage> {
  late List<NotificationData> _notifications; // Local notifications list

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications); // Create a copy of the notifications
    tz_data.initializeTimeZones();
    _deleteExpiredNotifications();
  }

  Future<void> _deleteExpiredNotifications() async {
    final currentTime = DateTime.now();
    final expiredIds = _notifications
        .where((notification) => notification.scheduledDate.isBefore(currentTime))
        .map((notification) => notification.id)
        .toList();

    for (final id in expiredIds) {
      await _deleteNotification(id);
    }
  }

  Future<void> _deleteNotification(int id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await widget.flutterLocalNotificationsPlugin.cancel(id);

    // Save changes and notify parent widget
    await NotificationStorage.saveNotifications(_notifications);
    widget.onNotificationsUpdated(_notifications);

    setState(() {});
  }

  void _updateNotification(
      NotificationData notification, DateTime newDate, String newMessage) {
    // Update notification details
    notification.scheduledDate = newDate;
    notification.message = newMessage;

    // Cancel the old notification and reschedule
    widget.flutterLocalNotificationsPlugin.cancel(notification.id);
    _addNotificationToPlugin(notification);

    // Save changes and notify parent widget
    NotificationStorage.saveNotifications(_notifications);
    widget.onNotificationsUpdated(_notifications);

    setState(() {});
  }

  Future<void> _addNotificationToPlugin(NotificationData notification) async {
    final notificationDetails = const NotificationDetails(
      iOS: DarwinNotificationDetails(),
    );
    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id,
      'Reminder',
      notification.message,
      tz.TZDateTime.from(notification.scheduledDate, tz.local),
      notificationDetails,
      payload: 'custom_payload',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification List'),
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text('There no new notifications.'),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  title: Text(notification.message),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                      .format(notification.scheduledDate)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditNotificationPage(
                              notification: notification,
                              onEdit: (newDate, newMessage) {
                                _updateNotification(
                                    notification, newDate, newMessage);
                              },
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteNotification(notification.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
