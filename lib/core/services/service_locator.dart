import 'package:get_it/get_it.dart';

import '../../data/repositories/task_repository.dart';
import '../../presentation/bloc/task_bloc.dart';
import 'hive_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!getIt.isRegistered<HiveService>()) {
    getIt.registerLazySingleton<HiveService>(HiveService.new);
  }

  if (!getIt.isRegistered<TaskRepository>()) {
    getIt.registerLazySingleton<TaskRepository>(
      () => TaskRepository(hiveService: getIt<HiveService>()),
    );
  }

  if (!getIt.isRegistered<TaskBloc>()) {
    getIt.registerLazySingleton<TaskBloc>(
      () => TaskBloc(taskRepository: getIt<TaskRepository>()),
    );
  }
}
