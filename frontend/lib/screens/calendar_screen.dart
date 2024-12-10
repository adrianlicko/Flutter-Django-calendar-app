import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/theme/all_themes.dart';
import 'package:frontend/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime now = DateTime.now();
  int currentWeekDay = DateTime.now().weekday;
  int selectedWeekDay = DateTime.now().weekday;

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
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 4.0, right: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: AppTheme.getThemeFromColors(AllAppColors.lightBlueColorScheme).primaryColor.withOpacity(0.2),
      ),
      child: _buildDayButton(dayLabel, dateLabel),
    );
  }

  Widget _buildWeekButtons() {
    List<String> weekDays = ['Po', 'Ut', 'St', 'Št', 'Pi'];

    DateTime monday = now.subtract(Duration(days: currentWeekDay - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        DateTime date = monday.add(Duration(days: index));
        String dayLabel = weekDays[index];
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

  Widget _buildTimeColumn() {
    List<String> times = [];
    for (int i = 7; i <= 20; i++) {
      times.add('$i:00');
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: times.map((time) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 48, child: Text(time)),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Container(height: 1, color: Colors.black),
                    const SizedBox(height: 24.0),
                    // Container(height: 1, color: Colors.grey[500]),
                    const SizedBox(height: 24.0),
                    // Container(height: 1, color: Colors.grey[500]),
                    const SizedBox(height: 24.0),
                    // Container(height: 1, color: Colors.grey[500]),
                    const SizedBox(height: 14.0),
                  ],
                ),
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddScheduleButton() {
    return GestureDetector(
      onTap: () {},
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              _buildWeekButtons(),
              _buildTimeColumn(),
            ],
          ),
          Positioned(bottom: 25, right: 25, child: _buildAddScheduleButton())
        ],
      ),
    );
  }
}
