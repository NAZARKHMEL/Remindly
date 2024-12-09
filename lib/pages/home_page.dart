import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'manage_notifications_page.dart';  // Import the ManageNotificationsPage
import '../models/notification_data.dart';
import '../sharedpreferences.dart';

class HelloWorldPage extends StatefulWidget {
  @override
  _HelloWorldPageState createState() => _HelloWorldPageState();
}

class _HelloWorldPageState extends State<HelloWorldPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedDateTime;
  List<NotificationData> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _notifications = await NotificationStorage.loadNotifications();
    setState(() {});
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

    // Send scheduled notification
    await sendScheduledNotification(newNotification.scheduledDate, newNotification.message);

    // Add the new notification to the list
    _notifications.add(newNotification);

    // Save the updated notifications list to SharedPreferences
    await NotificationStorage.saveNotifications(_notifications);

    // Clear input and update state
    setState(() {
      _messageController.clear();
      _selectedDateTime = null;
    });
  }

  Future<void> sendScheduledNotification(DateTime scheduledDate, String message) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification App'),
        actions: [
          // Add an IconButton to navigate to ManageNotificationsPage
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageNotificationsPage()),
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
                          : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
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
