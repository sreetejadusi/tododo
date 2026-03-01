import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/service_locator.dart';
import 'presentation/bloc/task_bloc.dart';
import 'presentation/bloc/task_event.dart';
import 'presentation/view/task_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  await setupServiceLocator();
  await getIt<NotificationService>().init();
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4285f4)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}
