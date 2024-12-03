import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Center(
        child: Text("Todo screen"),
      ),
    );
  }
}
