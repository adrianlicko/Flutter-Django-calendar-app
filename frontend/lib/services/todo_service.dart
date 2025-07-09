import 'package:flutter/material.dart';
import 'package:frontend/components/notifiers/error_notifier.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'dart:convert';
import 'package:frontend/l10n/app_localizations.dart';

class TodoService {
  final AuthService _authService = locator<AuthService>();
  List<TodoModel> _todos = [];

  Future<List<TodoModel>> getTodos(BuildContext context) async {
    if (_todos.isNotEmpty) {
      return Future.value(_todos);
    }

    final response = await _authService.authenticatedRequest(
      method: 'GET',
      endpoint: 'todos/',
    );

    if (response != null && response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _todos = data.map((json) => TodoModel.fromJson(json)).toList();
      return _todos;
    } else {
      if (response?.statusCode != 200) {
        ErrorNotifier.show(context: context, message: AppLocalizations.of(context)!.failedToGetTodos);
      }
      return List<TodoModel>.empty();
    }
  }

  Future<List<TodoModel>> getNotCompletedTodos(BuildContext context) async {
    final todos = await getTodos(context);
    return todos.where((todo) => !todo.isCompleted).toList();
  }

  Future<List<TodoModel>> getTodosForDate(BuildContext context, DateTime date, {bool onlyNotCompleted = true}) async {
    List<TodoModel> todos = [];
    if (onlyNotCompleted) {
      todos = await getNotCompletedTodos(context);
    } else {
      todos = await getTodos(context);
    }
    final givenDate = DateTime(date.year, date.month, date.day);
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(givenDate);
    }).toList();
  }

  Future<List<TodoModel>> getTodosForDateWithTime(BuildContext context, DateTime date,
      {bool onlyNotCompleted = true}) async {
    List<TodoModel> todos = [];
    if (onlyNotCompleted) {
      todos = await getNotCompletedTodos(context);
    } else {
      todos = await getTodos(context);
    }
    final givenDate = DateTime(date.year, date.month, date.day);
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(givenDate) && todo.time != null;
    }).toList();
  }

  Future<List<TodoModel>> getTodosForDateWithoutTime(BuildContext context, DateTime date,
      {bool onlyNotCompleted = true}) async {
    List<TodoModel> todos = [];
    if (onlyNotCompleted) {
      todos = await getNotCompletedTodos(context);
    } else {
      todos = await getTodos(context);
    }
    final givenDate = DateTime(date.year, date.month, date.day);
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(givenDate) && todo.time == null;
    }).toList();
  }

  Future<TodoModel?> addTodo(BuildContext context, TodoModel todo) async {
    final response = await _authService.authenticatedRequest(
      method: 'POST',
      endpoint: 'todos/',
      body: json.encode(todo.toJson()),
    );

    if (response != null && response.statusCode == 201) {
      final newTodo = TodoModel.fromJson(jsonDecode(response.body));
      _todos.add(newTodo);
      return newTodo;
    } else {
      ErrorNotifier.show(context: context, message: AppLocalizations.of(context)!.failedToAddTodo);
      return null;
    }
  }

  Future<void> deleteTodo(BuildContext context, int todoId) async {
    final response = await _authService.authenticatedRequest(
      method: 'DELETE',
      endpoint: 'todos/$todoId/',
    );

    if (response != null && response.statusCode == 204) {
      _todos.removeWhere((todo) => todo.id == todoId);
    } else {
      ErrorNotifier.show(context: context, message: AppLocalizations.of(context)!.failedToDeleteTodo);
    }
  }

  Future<TodoModel?> updateTodo(BuildContext context, TodoModel todo) async {
    final response = await _authService.authenticatedRequest(
      method: 'PATCH',
      endpoint: 'todos/${todo.id}/',
      body: json.encode(todo.toJson()),
    );

    if (response != null && response.statusCode == 200) {
      final updatedTodo = TodoModel.fromJson(jsonDecode(response.body));
      int index = _todos.indexWhere((t) => t.id == updatedTodo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }
      return updatedTodo;
    } else {
      ErrorNotifier.show(context: context, message: AppLocalizations.of(context)!.failedToUpdateTodo);
      return null;
    }
  }
}
