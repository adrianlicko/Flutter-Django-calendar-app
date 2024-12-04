import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/models/todo_model.dart';

class TodoDetailScreen extends StatelessWidget {
  final TodoModel todo;

  const TodoDetailScreen({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      title: todo.title,
      body: Center(
        child: todo.description == null ? Container() : Text(todo.description!),
      ),
    );
  }
}
