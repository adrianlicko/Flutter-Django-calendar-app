import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoModel {
  final DateTime? createdAt;
  final int? id;
  final String title;
  final String? description;
  bool isCompleted;
  final DateTime? date;
  final TimeOfDay? time;

  TodoModel({
    this.createdAt, // backend will handle this
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.date,
    this.time,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'] != null ? _parseTimeOfDay(json['time']) : null,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  // date format: YYYY-MM-DD

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
      'time': time != null ? _formatTimeOfDay(time!) : null,
      'is_completed': isCompleted,
    };
  }

static TimeOfDay _parseTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

static String _formatTimeOfDay(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
}
}
