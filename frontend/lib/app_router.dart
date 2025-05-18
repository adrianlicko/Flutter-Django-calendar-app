import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/screens/calendar_screen.dart';
import 'package:frontend/screens/edge_detection_camera_screen.dart';
import 'package:frontend/screens/gallery_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/no_internet_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/todo/todo_detail_screen.dart';
import 'package:frontend/screens/todo/todo_screen.dart';
import 'package:frontend/screens/auth/auth_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/connectivity_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

FutureOr<String?> Function(BuildContext, GoRouterState)? redirectToNoInternet = (context, state) {
  final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
  if (!connectivityService.hasConnectionToBackend) {
    return '/no_internet';
  }
  return null;
};

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
          redirect: redirectToNoInternet,
        ),
        GoRoute(
          name: 'todo',
          path: '/todo',
          builder: (context, state) {
            final todos = state.extra as List<TodoModel>?;
            return TodoScreen(todos: todos);
          },
          redirect: redirectToNoInternet,
        ),
        GoRoute(
          name: 'todoDetail',
          path: '/todo_detail',
          builder: (context, state) {
            final todo = state.extra as TodoModel;
            return TodoDetailScreen(todo: todo);
          },
          redirect: redirectToNoInternet,
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          redirect: redirectToNoInternet,
        ),
        GoRoute(
          name: 'scan',
          path: '/scan',
          builder: (context, state) => const EdgeDetectionCameraScreen(),
        ),
        GoRoute(
          name: 'gallery',
          path: '/gallery',
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          name: 'no_internet',
          path: '/no_internet',
          builder: (context, state) => const NoInternetScreen(),
        ),
      ],
    );
