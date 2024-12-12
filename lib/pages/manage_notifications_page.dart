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
  final List<NotificationData> notifications; // Передаем список уведомлений
  final Function(List<NotificationData>)
      onNotificationsUpdated; // Коллбэк для обновления

  const ManageNotificationsPage({super.key, 
    required this.flutterLocalNotificationsPlugin,
    required this.notifications,
    required this.onNotificationsUpdated,
  });

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
    _deleteExpiredNotifications(); // Удаляем просроченные уведомления
    setState(() {});
  }

  // Удаляем все просроченные уведомления
  void _deleteExpiredNotifications() {
    DateTime currentTime = DateTime.now();
    List<NotificationData> expiredNotifications = [];

    // Ищем все уведомления, чье время наступило
    for (var notification in _notifications) {
      if (notification.scheduledDate.isBefore(currentTime) ||
          notification.scheduledDate.isAtSameMomentAs(currentTime)) {
        expiredNotifications.add(notification);
      }
    }

    // Удаляем все просроченные уведомления из списка и из плагина
    for (var expired in expiredNotifications) {
      _deleteNotification(expired.id);
    }
  }

  Future<void> _deleteNotification(int id) async {
    widget.notifications.removeWhere((notification) => notification.id == id);
    await widget.flutterLocalNotificationsPlugin.cancel(id);
    widget.onNotificationsUpdated(widget.notifications);
    setState(() {});
  }

  void _updateNotification(
      NotificationData notification, DateTime newDate, String newMessage) {
    notification.scheduledDate = newDate;
    notification.message = newMessage;
    widget.flutterLocalNotificationsPlugin
        .cancel(notification.id); // Удаляем старое уведомление
    NotificationStorage.saveNotifications(_notifications);
    _addNotificationToPlugin(
        notification); // Добавляем обновленное уведомление в плагин
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
        title: const Text('Список напоминаний'),
      ),
      body: ListView.builder(
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
