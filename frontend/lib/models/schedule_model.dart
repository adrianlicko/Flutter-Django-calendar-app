import 'package:flutter/material.dart';

class ScheduleModel {
  final String id;
  final String title;
  final String? description;
  final String? room;
  final int weekDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;

  ScheduleModel({
    required this.id,
    required this.title,
    this.description,
    this.room,
    required this.weekDay,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}