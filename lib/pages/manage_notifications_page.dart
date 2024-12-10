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

  ManageNotificationsPage({required this.flutterLocalNotificationsPlugin});

  @override
  _ManageNotificationsPageState createState() =>
      _ManageNotificationsPageState();
}

class _ManageNotificationsPageState extends State<ManageNotificationsPage> {
  List<NotificationData> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    tz_data.initializeTimeZones();
  }

  Future<void> _loadNotifications() async {
    _notifications = await NotificationStorage.loadNotifications();
    setState(() {});
  }

  Future<void> _deleteNotification(int id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    await widget.flutterLocalNotificationsPlugin.cancel(id); // Удаляем уведомление из плагина
    await NotificationStorage.saveNotifications(_notifications);
    setState(() {});
  }

  void _updateNotification(
      NotificationData notification, DateTime newDate, String newMessage) {
    notification.scheduledDate = newDate;
    notification.message = newMessage;
    // Обновляем уведомление в плагине
    widget.flutterLocalNotificationsPlugin.cancel(notification.id); // Сначала удаляем старое
    NotificationStorage.saveNotifications(_notifications);
    _addNotificationToPlugin(notification); // Добавляем обновленное уведомление
    setState(() {});
  }

  Future<void> _addNotificationToPlugin(NotificationData notification) async {
    final notificationDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(),
    );
    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id,
      'Напоминание',
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