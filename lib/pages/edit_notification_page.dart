import 'package:flutter/material.dart';
import '../models/notification_data.dart';
import 'package:intl/intl.dart';

class EditNotificationPage extends StatefulWidget {
   final NotificationData notification;

  EditNotificationPage({required this.notification});

  @override
  _EditNotificationPageState createState() => _EditNotificationPageState();
}

class _EditNotificationPageState extends State<EditNotificationPage> {
  final TextEditingController _messageController = TextEditingController();
  DateTime? _scheduledDateTime;

  @override
  void initState() {
    super.initState();
    _messageController.text = widget.notification.message;
    _scheduledDateTime = widget.notification.scheduledDate;
  }

  void _saveChanges() {
    // Update notification data or any logic to save changes
    setState(() {
      widget.notification.message = _messageController.text;
      widget.notification.scheduledDate = _scheduledDateTime!;
    });

    Navigator.pop(context);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime != null) {
        setState(() {
          _scheduledDateTime = DateTime(
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
      appBar: AppBar(title: Text('Edit Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Scheduled time: ${_scheduledDateTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(_scheduledDateTime!) : 'Not set'}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDateTime(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}