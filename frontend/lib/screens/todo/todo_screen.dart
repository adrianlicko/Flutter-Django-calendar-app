import 'package:flutter/material.dart';
import 'package:frontend/app_scaffold.dart';
import 'package:frontend/components/todo_card.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/todo_service.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<TodoModel> todos = TodoService.todos;

    return AppScaffold(
        body: Column(
      children: todos
          .map((todo) => TodoCard(todoId: todo.id, todoTitle: todo.title, todoDescription: todo.description))
          .toList(),
    ));
  }
}
