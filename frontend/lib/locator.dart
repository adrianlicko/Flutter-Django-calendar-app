import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/schedule_service.dart';
import 'package:frontend/services/todo_service.dart';
import 'package:frontend/services/user_data_service.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<UserDataService>(() => UserDataService());
  locator.registerLazySingleton<TodoService>(() => TodoService());
  locator.registerLazySingleton<ScheduleService>(() => ScheduleService());
}
