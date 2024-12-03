import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: Text("Calendar screen"),
      ),
    );
  }
}
