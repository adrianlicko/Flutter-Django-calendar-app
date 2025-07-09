import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/card_banner.dart';
import 'dart:math' as math;
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

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

  Widget _buildScanIcon() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(1.1)
        ..rotateZ(0 * (math.pi / 180)),
      child: Image.asset(
        "images/camera_scanner_icon.png",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGalleryIcon() {
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
          "images/gallery_icon.png",
          fit: BoxFit.cover,
        ),
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
            gradientColors: [Colors.teal[500]!, Colors.blue],
            icon: _buildCalendarIcon(),
            onTap: () => context.push('/calendar')),
        CardBanner(
            title: AppLocalizations.of(context)!.todoTasks,
            gradientColors: [Colors.red[700]!, Colors.purple],
            icon: _buildTodoIcon(),
            onTap: () => context.push('/todo')),
        if (Platform.isAndroid)
          Row(
            children: [
              Flexible(
                flex: 1,
                child: CardBanner(
                  title: AppLocalizations.of(context)!.gallery,
                  gradientColors: const [Color.fromRGBO(22, 63, 122, 1), Color.fromRGBO(41, 175, 234, 1)],
                  paddingImageRight: 0.0,
                  icon: _buildGalleryIcon(),
                  onTap: () => context.push('/gallery'),
                ),
              ),
              Flexible(
                flex: 1,
                child: CardBanner(
                  title: AppLocalizations.of(context)!.scanner,
                  gradientColors: [Colors.purple[700]!, Colors.blue[800]!],
                  paddingImageRight: 0.0,
                  icon: _buildScanIcon(),
                  onTap: () => context.push('/scan'),
                ),
              ),
            ],
          ),
        CardBanner(
            title: AppLocalizations.of(context)!.profile,
            gradientColors: [Colors.grey[700]!, Colors.grey],
            icon: _buildProfileIcon(),
            onTap: () => context.push('/profile')),
      ],
    ));
  }
}
