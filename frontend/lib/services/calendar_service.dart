import 'package:flutter/material.dart';
import 'package:frontend/models/schedule_model.dart';

class CalendarService {
  // mocked data
  static final List<ScheduleModel> _schedules = [
    ScheduleModel(
      id: "1",
      title: "Math",
      description: "Mathematics",
      room: "A1",
      weekDay: 1,
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 9, minute: 0),
      color: Colors.blue,
    ),
    ScheduleModel(
      id: "2",
      title: "English",
      description: "English language",
      room: "A2",
      weekDay: 2,
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 0),
      color: Colors.green,
    ),
    ScheduleModel(
      id: "3",
      title: "Physics",
      weekDay: 1,
      startTime: const TimeOfDay(hour: 12, minute: 0),
      endTime: const TimeOfDay(hour: 14, minute: 0),
      color: Colors.red,
    ),
    ScheduleModel(
      id: "4",
      title: "Chemistry",
      description: "Chemistry",
      weekDay: 1,
      startTime: const TimeOfDay(hour: 11, minute: 0),
      endTime: const TimeOfDay(hour: 13, minute: 0),
      color: Colors.orange,
    ),
    ScheduleModel(
      id: "5",
      title: "Biology",
      description: "Biology",
      weekDay: 1,
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 15, minute: 0),
      color: Colors.purple,
    ),
    ScheduleModel(
      id: "6",
      title: "History",
      description: "History",
      weekDay: 1,
      startTime: const TimeOfDay(hour: 15, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 0),
      color: Colors.blue,
    ),
    ScheduleModel(
      id: "7",
      title: "Geography",
      description: "Geography",
      weekDay: 1,
      startTime: const TimeOfDay(hour: 16, minute: 0),
      endTime: const TimeOfDay(hour: 17, minute: 0),
      color: Colors.green,
    ),
  ];

  static List<ScheduleModel> getSchedules() {
    return _schedules;
  }

  static void addSchedule(ScheduleModel schedule) {
    _schedules.add(schedule);
  }

  static void deleteSchedule(ScheduleModel schedule) {
    _schedules.remove(schedule);
  }
}
