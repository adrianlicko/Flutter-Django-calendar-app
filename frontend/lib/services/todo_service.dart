import 'package:frontend/locator.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TodoService {
  // mocked data
  // final List<TodoModel> _todos = [
  //   TodoModel(id: "123", title: "Neviem"),
  //   TodoModel(id: "11", title: "Neviem2", description: "Roman"),
  //   TodoModel(
  //       id: "122",
  //       title: "So vsetkym",
  //       description: "Nejaky popis",
  //       date: DateTime(2024),
  //       time: const TimeOfDay(hour: 4, minute: 13)),
  //   TodoModel(id: "132", title: "S datumom", description: "Nejaky popis", date: DateTime(2024)),
  //   TodoModel(
  //       id: "132333", title: "S casom", description: "Nejaky popis", time: TimeOfDay.fromDateTime(DateTime.now())),
  //   TodoModel(
  //       id: "132343",
  //       title: "S casom",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 8, 30))),
  //   TodoModel(
  //       id: "132343",
  //       title: "S cas",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 8, 32))),
  //   TodoModel(
  //       id: "13233432432",
  //       title: "S caskkds",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 10, 32))),
  //   TodoModel(
  //       id: "13233423232432",
  //       title: "S asdasasd",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 10, 33))),
  //   TodoModel(
  //       id: "132343",
  //       title: "S casomsdsdsd",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 11, 23))),
  //   TodoModel(
  //       id: "132343",
  //       title: "S casomsdasdasdsadasdasdasd",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 11, 50))),
  //   TodoModel(
  //       id: "13234323",
  //       title: "S adsad",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 11, 52))),
  //   TodoModel(
  //       id: "13234323",
  //       title: "S adsad",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 7, 52))),
  //   TodoModel(
  //       id: "13234323",
  //       title: "S adsad",
  //       description: "Nejaky popis",
  //       date: DateTime(2024, 12, 23),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 30))),
  //   TodoModel(
  //     id: "13234323",
  //     title: "Romannn",
  //     description: "Nejaky popis",
  //     date: DateTime(2024, 12, 23),
  //     // time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 30))
  //   ),
  //   TodoModel(
  //       id: "13234323",
  //       title: "S adsad",
  //       description: "Nejaky popis",
  //       // date: DateTime(2024, 12, 9),
  //       time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 32))),
  //   TodoModel(
  //     id: "13234323",
  //     title: "S adsad",
  //     description: "Nejaky popis",
  //     // date: DateTime(2024, 12, 9),
  //     // time: TimeOfDay.fromDateTime(DateTime(2024, 1, 1, 12, 30))
  //   ),
  // ];

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
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(date);
    }).toList();
  }

  Future<List<TodoModel>> getTodosForDateWithTime(DateTime date) async {
    final todos = await getNotCompletedTodos();
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(date) && todo.time != null;
    }).toList();
  }

  Future<List<TodoModel>> getTodosForDateWithoutTime(DateTime date) async {
    final todos = await getNotCompletedTodos();
    return todos.where((todo) {
      if (todo.date == null) return false;
      return todo.date!.isAtSameMomentAs(date) && todo.time == null;
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
      throw Exception('Failed add todo');
    }
  }

  Future<void> deleteTodos(List<int> todoIds) async {
    for (var todoId in todoIds) {
      deleteTodo(todoId);
    }
  }

  Future<void> deleteTodo(int todoId) async {
    final String token = _authService.accessToken!;
    final response = await http.delete(Uri.parse('$_baseUrl$todoId/'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 204) {
      _todos.removeWhere((todo) => todo.id == todoId);
    } else {
      throw Exception('Failed to delete todo');
    }
  }
}
