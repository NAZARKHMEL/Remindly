class NotificationData {
  final int id;
  String message;
  DateTime scheduledDate;

  NotificationData({
    required this.id,
    required this.message,
    required this.scheduledDate,
  });

  // Convert a NotificationData object into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'scheduledDate': scheduledDate.toIso8601String(),
    };
  }

  // Convert a JSON object into a NotificationData object
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'],
      message: json['message'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
    );
  }
}
