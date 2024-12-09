import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './models/notification_data.dart';

class NotificationStorage {
  static const _key = 'notifications_key'; // Key for SharedPreferences

  // Save list of notifications
  static Future<void> saveNotifications(List<NotificationData> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = json.encode(
      notifications.map((notification) => notification.toJson()).toList(),
    );
    await prefs.setString(_key, encodedData);
  }

  // Load list of notifications
  static Future<List<NotificationData>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);
    if (encodedData == null) {
      return []; // Return an empty list if no data exists
    }
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData
        .map((jsonItem) => NotificationData.fromJson(jsonItem))
        .toList();
  }
}
