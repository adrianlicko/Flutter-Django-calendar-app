import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/card_banner.dart';
import 'dart:math' as math;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildCalendarIcon() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(1.3)
        ..rotateZ(-30 * (math.pi / 180)),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          "images/calendar_icon.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTodoIcon() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(1.3)
        ..rotateZ(-20 * (math.pi / 180)),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          "images/todo_icon.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Column(
      children: [
        CardBanner(
            title: "Calendar",
            gradientColors: [Colors.blue[700]!, Colors.blue],
            icon: _buildCalendarIcon(),
            onTap: () {
              router.push('/calendar');
            }),
            CardBanner(
              title: "To Do",
              gradientColors: [Colors.red[700]!, Colors.purple],
              icon: _buildTodoIcon(),
              onTap: () {
                router.push('/todo');
              },
            ),
      ],
    ));
  }
}
