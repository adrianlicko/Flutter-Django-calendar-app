import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/card_banner.dart';
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildCalendarIcon() {
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

  Widget _buildProfileIcon() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(1.1)
        ..rotateZ(0 * (math.pi / 180)),
      child: Image.asset(
        "images/profile_icon.png",
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardBanner(
            title: AppLocalizations.of(context)!.calendar,
            gradientColors: [Colors.blue[700]!, Colors.blue],
            icon: _buildCalendarIcon(),
            onTap: () => router.push('/calendar')),
        CardBanner(
            title: AppLocalizations.of(context)!.todoTasks,
            gradientColors: [Colors.red[700]!, Colors.purple],
            icon: _buildTodoIcon(),
            onTap: () => router.push('/todo')),
        CardBanner(
          title: AppLocalizations.of(context)!.profile,
          gradientColors: [Colors.grey[700]!, Colors.grey],
          icon: _buildProfileIcon(),
          halfWidth: true,
          onTap: () => router.push('/profile'),
        ),
      ],
    ));
  }
}
