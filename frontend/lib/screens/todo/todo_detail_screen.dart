import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/todo_service.dart';

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
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            TodoService.deleteTodo(todo);
            router.pop(todo);
          },
        ),
      ],
      body: Center(
          child: Column(
        children: [
          if (todo.description != null) Text(todo.description!),
          if (todo.date != null) Text(todo.date!.toString()),
          if (todo.time != null) Text(todo.time!.toString()),
        ],
      )),
    );
  }
}