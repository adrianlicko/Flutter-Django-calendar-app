import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
