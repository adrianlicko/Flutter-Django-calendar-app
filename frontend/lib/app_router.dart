import 'package:frontend/models/todo_model.dart';
import 'package:frontend/screens/calendar_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/todo/todo_detail_screen.dart';
import 'package:frontend/screens/todo/todo_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'calendar',
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      name: 'todo',
      path: '/todo',
      builder: (context, state) {
        final todos = state.extra as List<TodoModel>?;
        return TodoScreen(todos: todos);
      },
    ),
    GoRoute(
      name: 'todoDetail',
      path: '/todo_detail',
      builder: (context, state) {
        final todo = state.extra as TodoModel;
        return TodoDetailScreen(todo: todo);
      },
    ),
  ],
);
