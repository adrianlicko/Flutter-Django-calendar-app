import 'package:frontend/locator.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoService {
  final AuthService _authService = locator<AuthService>();
  List<TodoModel> _todos = [];

  final String _baseUrl = 'http://127.0.0.1:8000/api/todos/';

  Future<List<TodoModel>> getTodos({bool forceFetch = false}) async {
    if (_todos.isNotEmpty && !forceFetch) {
      return Future.value(_todos);
    }
    final String token = _authService.accessToken!;
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _todos = data.map((json) => TodoModel.fromJson(json)).toList();
      return _todos;
    } else {
      return List<TodoModel>.empty();
    }
  }

  Future<List<TodoModel>> getNotCompletedTodos() async {
    final todos = await getTodos();
    return todos.where((todo) => !todo.isCompleted).toList();
  }

  Future<List<TodoModel>> getTodosForDate(DateTime date) async {
    final todos = await getNotCompletedTodos();
    final givenDate = DateTime(date.year, date.month, date.day);
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(givenDate);
    }).toList();
  }

  Future<List<TodoModel>> getTodosForDateWithTime(DateTime date) async {
    final todos = await getNotCompletedTodos();
    final givenDate = DateTime(date.year, date.month, date.day);
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(givenDate) && todo.time != null;
    }).toList();
  }

  Future<List<TodoModel>> getTodosForDateWithoutTime(DateTime date) async {
    final todos = await getNotCompletedTodos();
    final givenDate = DateTime(date.year, date.month, date.day);
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(givenDate) && todo.time == null;
    }).toList();
  }

  Future<TodoModel?> updateTodo(TodoModel todo) async {
  final String token = _authService.accessToken!;
  final response = await http.patch(
    Uri.parse('$_baseUrl${todo.id}/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(todo.toJson()),
  );

  if (response.statusCode == 200) {
    return TodoModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update todo');
  }
}

  Future<TodoModel?> addTodo(TodoModel todo) async {
    final String token = _authService.accessToken!;
    final response = await http.post(Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(todo.toJson()));

    if (response.statusCode == 201) {
      final newTodo = TodoModel.fromJson(jsonDecode(response.body));
      _todos.add(newTodo);
      return newTodo;
    } else {
      print('Failed to add todo: ${response.statusCode} ${response.body}');
      throw Exception('Failed add todo');
    }
  }

  Future<void> deleteTodos(List<int> todoIds) async {
    for (var todoId in todoIds) {
      deleteTodo(todoId);
    }
  }

  Future<bool> deleteTodo(int todoId) async {
    final String token = _authService.accessToken!;
    final response = await http.delete(Uri.parse('$_baseUrl$todoId/'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 204) {
      _todos.removeWhere((todo) => todo.id == todoId);
      return true;
    } else {
      throw Exception('Failed to delete todo');
    }
  }
}
