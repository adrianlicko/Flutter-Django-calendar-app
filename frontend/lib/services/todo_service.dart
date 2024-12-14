import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';

class TodoService {
  // mocked data
  static final List<TodoModel> _todos = [
    TodoModel(id: "123", title: "Neviem"),
    TodoModel(id: "11", title: "Neviem2", description: "Roman"),
    TodoModel(
        id: "122",
        title: "So vsetkym",
        description: "Nejaky popis",
        date: DateTime(2024),
        time: const TimeOfDay(hour: 4, minute: 13)),
    TodoModel(id: "132", title: "S datumom", description: "Nejaky popis", date: DateTime(2024)),
    TodoModel(
        id: "132333", title: "S casom", description: "Nejaky popis", time: TimeOfDay.fromDateTime(DateTime.now())),
  ];

  static List<TodoModel> getTodos() {
    return _todos;
  }

  static void addTodo(TodoModel todo) {
    _todos.add(todo);
  }

  static void deleteTodos(List<TodoModel> todos) {
    _todos.removeWhere((todo) => todos.contains(todo));
  }

  static void deleteTodo(TodoModel todo) {
    _todos.remove(todo);
  }
}
