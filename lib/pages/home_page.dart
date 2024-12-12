import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'manage_notifications_page.dart'; // Import the ManageNotificationsPage
import '../models/notification_data.dart';
import '../sharedpreferences.dart';

class HelloWorldPage extends StatefulWidget {
  const HelloWorldPage({super.key});

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
    tz_data.initializeTimeZones();
    _initializeNotifications();
    requestIOSPermissions();
  }

  void _initializeNotifications() async {
    final DarwinInitializationSettings darwinInitializationSettings =
        const DarwinInitializationSettings(
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
      // Покажем ошибку, если нет сообщения или даты
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите сообщение и выберите дату')),
      );
      return;
    }

    try {
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final newNotification = NotificationData(
        id: notificationId,
        message: _messageController.text,
        scheduledDate: _selectedDateTime!,
      );

    await sendScheduledNotification(
        newNotification.scheduledDate, newNotification.message);

      // Добавляем новое уведомление в список
      _notifications.add(newNotification);

      // Сохраняем обновленный список уведомлений в SharedPreferences
      await NotificationStorage.saveNotifications(_notifications);


    setState(() {
      _messageController.clear();
      _selectedDateTime = null;
    });

    // Reload notifications after saving
    await _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Напоминание успешно добавлено')),
      );

      // Очищаем поля ввода и обновляем состояние
      setState(() {
        _messageController.clear();
        _selectedDateTime = null;
      });
    } catch (e) {
      // Покажем ошибку, если что-то пошло не так
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
      print('Error adding notification: $e');
    }

  }

  Future<void> sendScheduledNotification(
      DateTime scheduledDate, String message) async {
    final DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails();
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
        title: const Text('Notification App'),
        actions: [
          // Add an IconButton to navigate to ManageNotificationsPage
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageNotificationsPage(
                    flutterLocalNotificationsPlugin:
                        flutterLocalNotificationsPlugin,
                    notifications: _notifications,
                    onNotificationsUpdated: (updatedNotifications) {
                      setState(() {
                        _notifications = updatedNotifications;
                      });
                    },
                  ),
                )
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Введите сообщение'),
            ),
            const SizedBox(height: 10),
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
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addNotification,
                    child: const Text('Добавить напоминание'),
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
