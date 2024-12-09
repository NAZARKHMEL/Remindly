import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_data.dart';

class EditNotificationPage extends StatefulWidget {
  final NotificationData notification;
  final Function(DateTime, String) onEdit;

  EditNotificationPage({
    required this.notification,
    required this.onEdit,
  });

  @override
  _EditNotificationPageState createState() => _EditNotificationPageState();
}

class _EditNotificationPageState extends State<EditNotificationPage> {
  late TextEditingController _messageController;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _messageController =
        TextEditingController(text: widget.notification.message);
    _selectedDateTime = widget.notification.scheduledDate;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
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

  void _saveChanges() {
    // Проверка на пустое поле сообщения или не выбранную дату
    if (_messageController.text.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля перед сохранением')),
      );
      return;
    }

    // Передаем изменения обратно в родительский виджет
    widget.onEdit(_selectedDateTime!, _messageController.text);
    Navigator.pop(context);  // Закрываем экран редактирования
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Редактировать напоминание'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _messageController,
            decoration: InputDecoration(labelText: 'Текст напоминания'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _selectDateTime(context),
            child: Text(
              _selectedDateTime == null
                  ? 'Выбрать дату'
                  : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),  // Закрываем без изменений
          child: Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,  // Сохраняем изменения
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}
