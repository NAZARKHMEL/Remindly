import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HelloWorldPage(),
    );
  }
}

class HelloWorldPage extends StatefulWidget {
  @override
  _HelloWorldPageState createState() => _HelloWorldPageState();
}

class _HelloWorldPageState extends State<HelloWorldPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _initializeNotifications();
    requestIOSPermissions();  // Запрос разрешений на уведомления
  }

  // Инициализация уведомлений для iOS с использованием DarwinInitializationSettings
  void _initializeNotifications() async {
    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      iOS: darwinInitializationSettings,  // iOS и другие устройства Apple
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Запрос разрешений на уведомления для iOS
  Future<void> requestIOSPermissions() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
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

  // Метод для отправки уведомления в заданное время и с заданным содержанием
  Future<void> sendScheduledNotification(DateTime scheduledDate, String message) async {
    final DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

    final NotificationDetails notificationDetails = NotificationDetails(
      iOS: darwinNotificationDetails,
    );

    // Добавляем uiLocalNotificationDateInterpretation
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID уведомления
      'Напоминание', // Заголовок уведомления
      message, // Текст уведомления
      tz.TZDateTime.from(scheduledDate, tz.local), 
      notificationDetails,
      payload: 'custom_payload',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // Интерпретация времени как абсолютного
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, World!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Пример: Отправляем уведомление через 10 секунд с заданным текстом
                DateTime scheduledDate = DateTime.now().add(Duration(seconds: 10));
                String message = 'Это уведомление для вас!';
                sendScheduledNotification(scheduledDate, message);
              },
              child: Text('Запланировать уведомление'),
            ),
          ],
        ),
      ),
    );
  }
}
