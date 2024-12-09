import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'manage_notifications_page.dart';
import '../models/notification_data.dart';

class HelloWorldPage extends StatefulWidget {
  @override
  _HelloWorldPageState createState() => _HelloWorldPageState();
}

class _HelloWorldPageState extends State<HelloWorldPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedDateTime;
  final List<NotificationData> _notifications = [];

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _initializeNotifications();
    requestIOSPermissions();
    _addDefaultNotification();
  }

  void _initializeNotifications() async {
    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(iOS: darwinInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestIOSPermissions() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (result != null && result) {
      print('Разрешение на уведомления получено');
    } else {
      print('Разрешение на уведомления не получено');
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addDefaultNotification() {
    final defaultNotification = NotificationData(
      id: 1,
      message: 'Default Test Notification', 
      scheduledDate: DateTime.now().add(Duration(minutes: 1)), // Через 1 минуту
    );

    setState(() {
      _notifications.add(defaultNotification);
    });

    sendScheduledNotification(defaultNotification.scheduledDate, defaultNotification.message);
  }

  Future<void> _addNotification() async {
    if (_messageController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите сообщение и выберите дату')),
      );
      return;
    }

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final newNotification = NotificationData(
      id: notificationId,
      message: _messageController.text,
      scheduledDate: _selectedDateTime!,
    );

    await sendScheduledNotification(
      newNotification.scheduledDate,
      newNotification.message,
    );

    setState(() {
      _notifications.add(newNotification);
      _messageController.clear();
      _selectedDateTime = null;
    });
  }

  Future<void> sendScheduledNotification(
      DateTime scheduledDate, String message) async {
    final DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();
    final NotificationDetails notificationDetails =
        NotificationDetails(iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Напоминание',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: 'custom_payload',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    setState(() {
      _notifications.removeWhere((notification) => notification.id == notificationId);
    });
  }

  // Метод для обновления уведомления после редактирования
  void _editNotification(NotificationData notification, DateTime newDate, String newMessage) {
    setState(() {
      notification.scheduledDate = newDate;
      notification.message = newMessage;
    });

    sendScheduledNotification(newDate, newMessage); // Переносим уведомление с новой датой
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification App'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageNotificationsPage(
                    notifications: _notifications,
                    cancelNotification: cancelNotification,
                    editNotification: _editNotification
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Введите сообщение'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDateTime(context),
                    child: Text(
                      _selectedDateTime == null
                          ? 'Выбрать дату'
                          : DateFormat('yyyy-MM-dd HH:mm')
                              .format(_selectedDateTime!),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addNotification,
                    child: Text('Добавить напоминание'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
