import 'package:frontend/models/todo_model.dart';

class TodoService {
  static List<TodoModel> todos = [
    TodoModel(id: "123", title: "Neviem"),
    TodoModel(id: "11", title: "Neviem2", description: "Roman")
  ];

  static TodoModel getTodoById(String id) {
    return todos.firstWhere((todo) => todo.id == id);
  }
}