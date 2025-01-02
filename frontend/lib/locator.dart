import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/calendar_service.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<TodoService>(() => TodoService());
  locator.registerLazySingleton<CalendarService>(() => CalendarService());
}