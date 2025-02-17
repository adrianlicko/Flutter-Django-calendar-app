import 'package:flutter/material.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/schedule_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'dart:convert';

class ScheduleService {
  final AuthService _authService = locator<AuthService>();
  List<ScheduleModel> _schedules = [];

  Future<List<ScheduleModel>> getSchedules(BuildContext context) async {
    if (_schedules.isNotEmpty) {
      return Future.value(_schedules);
    }

    final response = await _authService.authenticatedRequest(
      method: 'GET',
      endpoint: 'schedules/',
    );

    if (response != null && response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _schedules = data.map((json) => ScheduleModel.fromJson(json)).toList();
      return _schedules;
    } else {
      return List<ScheduleModel>.empty();
    }
  }

  Future<ScheduleModel?> addSchedule(BuildContext context, ScheduleModel schedule) async {
    final response = await _authService.authenticatedRequest(
      method: 'POST',
      endpoint: 'schedules/',
      body: json.encode(schedule.toJson()),
    );

    if (response != null && response.statusCode == 201) {
      final newSchedule = ScheduleModel.fromJson(jsonDecode(response.body));
      _schedules.add(newSchedule);
      return newSchedule;
    } else {
      throw Exception('Failed to add schedule');
    }
  }

  Future<void> deleteSchedule(BuildContext context, int scheduleId) async {
    final response = await _authService.authenticatedRequest(
      method: 'DELETE',
      endpoint: 'schedules/$scheduleId/',
    );

    if (response != null && response.statusCode == 204) {
      _schedules.removeWhere((schedule) => schedule.id == scheduleId);
    } else {
      throw Exception('Failed to delete schedule');
    }
  }
}