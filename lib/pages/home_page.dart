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
    requestIOSPermissions(); // Ensure this method is defined
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

  Future<void> sendScheduledNotification(
      DateTime scheduledDate, String message) async {
    final DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();
    final NotificationDetails notificationDetails =
        NotificationDetails(iOS: darwinNotificationDetails);
    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Напоминание',
      message,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: 'custom_payload',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    setState(() {
      _notifications.add(NotificationData(
          id: notificationId, message: message, scheduledDate: scheduledDate));
    });
  }

  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    setState(() {
      // Remove the notification from the list after it's canceled
      _notifications
          .removeWhere((notification) => notification.id == notificationId);
    });
  }

  Future<void> _editNotification(NotificationData notificationData,
      DateTime newScheduledDate, String newMessage) async {
    await cancelNotification(notificationData.id);

    sendScheduledNotification(newScheduledDate, newMessage);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification App'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageNotificationsPage(
                    notifications: _notifications,
                    cancelNotification: cancelNotification,
                    editNotification: _editNotification,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Введите текст уведомления',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDateTime(context),
                    child: Text(
                      _selectedDateTime == null
                          ? 'Выбрать дату и время'
                          : DateFormat('yyyy-MM-dd HH:mm')
                              .format(_selectedDateTime!),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty &&
                    _selectedDateTime != null) {
                  sendScheduledNotification(
                      _selectedDateTime!, _messageController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Уведомление запланировано!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Пожалуйста, заполните все поля.')));
                }
              },
              child: Text('Запланировать уведомление'),
            ),
          ],
        ),
      ),
    );
  }
}
