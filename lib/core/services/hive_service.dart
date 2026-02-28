import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/task_hive_adapter.dart';
import '../../data/models/task_model.dart';

class HiveService {
  HiveService._();

  static final HiveService _instance = HiveService._();

  factory HiveService() => _instance;

  static const String taskBoxName = 'tasks_box';

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }

    if (!Hive.isBoxOpen(taskBoxName)) {
      await Hive.openBox<Task>(taskBoxName);
    }
  }

  Box<Task> get taskBox => Hive.box<Task>(taskBoxName);

  Future<List<Task>> getTasks() async {
    return taskBox.values.toList(growable: false);
  }

  Future<void> saveTask(Task task) async {
    await taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  Future<void> clearTasks() async {
    await taskBox.clear();
  }
}
