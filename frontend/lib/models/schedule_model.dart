import 'package:flutter/material.dart';

class ScheduleModel {
  final int? id;
  final String title;
  final String? description;
  final String? room;
  final int weekDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;

  ScheduleModel({
    this.id,
    required this.title,
    this.description,
    this.room,
    required this.weekDay,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  // from json
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      room: json['room'],
      weekDay: json['week_day'],
      startTime: _parseTimeOfDay(json['start_time']),
      endTime: _parseTimeOfDay(json['end_time']),
      color: _parseColor(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'room': room,
      'week_day': weekDay,
      'start_time': _formatTimeOfDay(startTime),
      'end_time': _formatTimeOfDay(endTime),
      'color': _formatColor(color),
    };
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');

    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  static Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  static String _formatColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).padLeft(6, '0')}';
  }
}
