import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/dialogs/create_time_dialog.dart';
import 'package:frontend/models/schedule_model.dart';
import 'package:frontend/services/calendar_service.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:frontend/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<String, int> weekDays = {
    'Po': 1,
    'Ut': 2,
    'St': 3,
    'Št': 4,
    'Pi': 5,
  };
  DateTime now = DateTime.now();
  int currentWeekDay = DateTime.now().weekday;
  int selectedWeekDay = DateTime.now().weekday;
  List<ScheduleModel> schedules = CalendarService.getSchedules();

  Widget _buildAddScheduleButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CreateTimeDialog(selectedWeekDay: selectedWeekDay),
        ).then((_) {
          setState(() {});
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
        ),
        child: const Icon(Icons.playlist_add, size: 30),
      ),
    );
  }

  Widget _buildDayButton(String dayLabel, String dateLabel) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor,
            ),
            child: Text(dayLabel, style: const TextStyle(color: Colors.white))),
        const SizedBox(height: 4.0),
        SizedBox(width: 58, child: Center(child: Text(dateLabel))),
      ],
    );
  }

  Widget _buildCurrentDayButton(String dayLabel, String dateLabel) {
    return Container(
      padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor.withOpacity(0.2),
      ),
      child: _buildDayButton(dayLabel, dateLabel),
    );
  }

  Widget _buildWeekButtons() {
    DateTime monday = now.subtract(Duration(days: currentWeekDay - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        DateTime date = monday.add(Duration(days: index));
        String dayLabel = weekDays.keys.elementAt(index);
        String dateLabel = '${date.day}.${date.month}.';

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedWeekDay = date.weekday;
            });
          },
          child: selectedWeekDay == date.weekday
              ? _buildCurrentDayButton(dayLabel, dateLabel)
              : _buildDayButton(dayLabel, dateLabel),
        );
      }),
    );
  }

  Widget _buildScheduleTime(ScheduleModel schedule) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(schedule.startTime.format(context)),
            Text(schedule.endTime.format(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCalendar(ScheduleModel schedule) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 24.0, right: 32.0),
        decoration: BoxDecoration(
          color: schedule.color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Dismissible(
            key: Key(schedule.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                schedules.remove(schedule);
                CalendarService.deleteSchedule(schedule);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${schedule.title} bol vymazaný')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(schedule.title, style: const TextStyle().copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (schedule.description != null)
                        Text(schedule.description!,
                            style: const TextStyle().copyWith(color: Colors.black.withOpacity(0.4))),
                      if (schedule.room != null) Text(schedule.room!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isLastSchedule(ScheduleModel schedule) {
    ScheduleModel lastSchedule = schedule;
    for (int i = schedules.indexOf(schedule) + 1; i < schedules.length; i++) {
      if (schedules[i].weekDay == selectedWeekDay) {
        lastSchedule = schedules[i];
      }
    }
    return lastSchedule != schedule;
  }

  Widget _buildScheduleDivider(ScheduleModel schedule) {
    return Column(
      children: [
        const SizedBox(height: 4.0),
        if (_isLastSchedule(schedule)) const Divider(indent: 8.0, endIndent: 8.0),
        const SizedBox(height: 4.0),
      ],
    );
  }

  Widget _buildTimeTable() {
    return Column(
      children: schedules.map((schedule) {
        if (schedule.weekDay == selectedWeekDay) {
          schedules.sort((a, b) =>
              (a.startTime.hour * 60 + a.startTime.minute).compareTo(b.startTime.hour * 60 + b.startTime.minute));
          return Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    _buildScheduleTime(schedule),
                    _buildScheduleCalendar(schedule),
                  ],
                ),
              ),
              _buildScheduleDivider(schedule),
            ],
          );
        } else {
          return Container();
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: _buildAddScheduleButton(),
      body: Column(
        children: [
          _buildWeekButtons(),
          const SizedBox(height: 16.0),
          Expanded(child: SingleChildScrollView(child: _buildTimeTable())),
        ],
      ),
    );
  }
}
