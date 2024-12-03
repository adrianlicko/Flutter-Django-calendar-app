import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: Text("Profile screen"),
      ),
    );
  }
}
