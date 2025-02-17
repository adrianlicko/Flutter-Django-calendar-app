import 'package:frontend/models/todo_model.dart';
import 'package:frontend/screens/calendar_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/todo/todo_detail_screen.dart';
import 'package:frontend/screens/todo/todo_screen.dart';
import 'package:frontend/screens/auth/auth_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthProvider authProvider) => GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/auth';

        if (!isLoggedIn && !isLoggingIn) return '/auth';
        if (isLoggedIn && isLoggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          name: 'auth',
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
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
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );