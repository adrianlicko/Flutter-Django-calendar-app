import 'package:flutter/material.dart';

class TodoModel {
  final DateTime? createdAt;
  final String id;
  final String title;
  final String? description;
  bool isCompleted;
  final DateTime? date;
  final TimeOfDay? time;

  TodoModel({
    this.createdAt, // backend will handle this
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.date,
    this.time,
  });
}
