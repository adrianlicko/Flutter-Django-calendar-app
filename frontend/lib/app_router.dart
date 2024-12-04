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
      builder: (context, state) => const TodoScreen(),
    ),
    GoRoute(
      name: 'todoDetail',
      path: '/todo/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return TodoDetailScreen(todoId: id!);
      },
    ),
  ],
);
