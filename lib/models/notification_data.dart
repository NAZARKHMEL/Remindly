class NotificationData {
  final int id;
  String message;
  DateTime scheduledDate;

  NotificationData({
    required this.id,
    required this.message,
    required this.scheduledDate,
  });

  // Метод для создания дефолтного уведомления
  static NotificationData createDefault() {
    return NotificationData(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Генерация уникального ID
      message: 'Default Test Notification',
      scheduledDate: DateTime.now().add(Duration(minutes: 1)), // Срабатывает через 1 минуту
    );
  }
}
