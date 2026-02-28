import 'package:flutter/material.dart';

import 'core/services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  runApp(const Tododo());
}

class Tododo extends StatelessWidget {
  const Tododo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
