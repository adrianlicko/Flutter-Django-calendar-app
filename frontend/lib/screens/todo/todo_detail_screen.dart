import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/services/todo_service.dart';

class TodoDetailScreen extends StatelessWidget {
  final String todoId;

  const TodoDetailScreen({
    super.key,
    required this.todoId,
  });

  @override
  Widget build(BuildContext context) {
    final todo = TodoService.getTodoById(todoId);

    return AppScaffold(
      title: todo.title,
      body: Center(
        child: todo.description == null ? Container() : Text(todo.description!),
      ),
    );
  }
}
