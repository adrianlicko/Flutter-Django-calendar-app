import 'package:frontend/models/todo_model.dart';

class TodoService {
  // mocked data
  static final List<TodoModel> _todos = [
    TodoModel(id: "123", title: "Neviem"),
    TodoModel(id: "11", title: "Neviem2", description: "Roman")
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
