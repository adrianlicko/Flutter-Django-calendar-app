import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';

class TodoService {
  // mocked data
  final List<TodoModel> _todos = [
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
    TodoModel(
        id: "132343",
        title: "S casom",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 8, 30))),
    TodoModel(
        id: "132343",
        title: "S cas",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 8, 32))),
    TodoModel(
        id: "13233432432",
        title: "S caskkds",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 10, 32))),
    TodoModel(
        id: "13233423232432",
        title: "S asdasasd",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 10, 33))),
    TodoModel(
        id: "132343",
        title: "S casomsdsdsd",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 11, 23))),
    TodoModel(
        id: "132343",
        title: "S casomsdasdasdsadasdasdasd",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 11, 50))),
    TodoModel(
        id: "13234323",
        title: "S adsad",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 11, 52))),
    TodoModel(
        id: "13234323",
        title: "S adsad",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 7, 52))),
    TodoModel(
        id: "13234323",
        title: "S adsad",
        description: "Nejaky popis",
        date: DateTime(2024, 12, 23),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 30))),
    TodoModel(
      id: "13234323",
      title: "Romannn",
      description: "Nejaky popis",
      date: DateTime(2024, 12, 23),
      // time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 30))
    ),
    TodoModel(
        id: "13234323",
        title: "S adsad",
        description: "Nejaky popis",
        // date: DateTime(2024, 12, 9),
        time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 32))),
    TodoModel(
      id: "13234323",
      title: "S adsad",
      description: "Nejaky popis",
      // date: DateTime(2024, 12, 9),
      // time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 30))
    ),
  ];

  final String baseUrl = 'http://127.0.0.1:8000/api/todos/';

  List<TodoModel> getTodos() {
    return _todos;
  }

  List<TodoModel> getNotCompletedTodos() {
    return getTodos().where((todo) => !todo.isCompleted).toList();
  }

  List<TodoModel> getTodosForDate(DateTime date) {
    return getNotCompletedTodos().where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(date);
    }).toList();
  }

  List<TodoModel> getTodosForDateWithTime(DateTime date) {
    return getNotCompletedTodos().where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(date) && todo.time != null;
    }).toList();
  }

  List<TodoModel> getTodosForDateWithoutTime(DateTime date) {
    return getNotCompletedTodos().where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(date) && todo.time == null;
    }).toList();
  }

  void addTodo(TodoModel todo) {
    _todos.add(todo);
  }

  void deleteTodos(List<TodoModel> todos) {
    _todos.removeWhere((todo) => todos.contains(todo));
  }

  void deleteTodo(TodoModel todo) {
    _todos.remove(todo);
  }
}
