import 'package:frontend/locator.dart';
import 'package:frontend/models/schedule_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScheduleService {
  final AuthService _authService = locator<AuthService>();
  List<ScheduleModel> _schedules = [];
  final String _baseUrl = "http://localhost:8000/api/schedules/";

  Future<List<ScheduleModel>> getSchedules() async {
    if (_schedules.isNotEmpty) {
      return Future.value(_schedules);
    }
    final String token = _authService.accessToken!;
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _schedules = data.map((json) => ScheduleModel.fromJson(json)).toList();
      return _schedules;
    } else {
      return List<ScheduleModel>.empty();
    }
  }

  Future<ScheduleModel?> addSchedule(ScheduleModel schedule) async {
    final String token = _authService.accessToken!;
    final response = await http.post(Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(schedule.toJson()));

    if (response.statusCode == 201) {
      final newSchedule = ScheduleModel.fromJson(jsonDecode(response.body));
      _schedules.add(newSchedule);
      return newSchedule;
    } else {
      throw Exception('Failed add schedule');
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    final String token = _authService.accessToken!;
    final response = await http.delete(Uri.parse('$_baseUrl$scheduleId/'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 204) {
      _schedules.removeWhere((schedule) => schedule.id == scheduleId);
    } else {
      throw Exception('Failed to delete todo');
    }
  }
}
