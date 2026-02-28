import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/hive_service.dart';
import 'core/services/service_locator.dart';
import 'presentation/bloc/task_bloc.dart';
import 'presentation/bloc/task_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  await setupServiceLocator();
  runApp(const Tododo());
}

class Tododo extends StatelessWidget {
  const Tododo({super.key});

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<TaskBloc>()) {
      return const Placeholder();
    }

    return BlocProvider<TaskBloc>.value(
      value: getIt<TaskBloc>()..add(const LoadTasks()),
      child: const Placeholder(),
    );
  }
}
