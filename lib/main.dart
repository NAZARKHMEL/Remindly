import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminder App',
      home: ReminderHomePage(),
    );
  }
}

class ReminderHomePage extends StatelessWidget {
  const ReminderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Напоминания'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Генерируем уникальный идентификатор
            int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

            // Создаем напоминание
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: uniqueId, // Уникальный ID для каждого уведомления
                channelKey: 'basic_channel',
                title: 'Напоминание!',
                body: 'Это ваше напоминание.',
              ),
              schedule: NotificationCalendar.fromDate(
                date: DateTime.now().add(Duration(seconds: 5)), // через 5 секунд
              ),
            );

            // Выводим в консоль ID напоминания (удобно для отладки)
            print('Notification created with ID: $uniqueId');
          },
          child: const Text('Создать напоминание'),
        ),
      ),
    );
  }
}
