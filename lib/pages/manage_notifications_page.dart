import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_data.dart';
import 'edit_notification_page.dart';

class ManageNotificationsPage extends StatefulWidget {
  final List<NotificationData> notifications;
  final Function(int) cancelNotification;  // Функция для удаления уведомления
  final Function(NotificationData, DateTime, String) editNotification;  // Функция для редактирования уведомления

  ManageNotificationsPage({
    required this.notifications,
    required this.cancelNotification,
    required this.editNotification,  // Передаем функцию редактирования
  });

  @override
  _ManageNotificationsPageState createState() => _ManageNotificationsPageState();
}

class _ManageNotificationsPageState extends State<ManageNotificationsPage> {
  void _updateNotification(NotificationData notification, DateTime newDate, String newMessage) {
    setState(() {
      // Обновляем уведомление в списке
      notification.scheduledDate = newDate;
      notification.message = newMessage;
    });
  }

  void _deleteNotification(int notificationId) {
    setState(() {
      // Удаляем уведомление из списка
      widget.notifications.removeWhere((notif) => notif.id == notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Список напоминаний')),
      body: ListView.builder(
        itemCount: widget.notifications.length,
        itemBuilder: (context, index) {
          final notification = widget.notifications[index];
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
                          // Обновляем уведомление в родительском виджете
                          _updateNotification(notification, newDate, newMessage);
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Удаляем уведомление в родительском виджете
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
