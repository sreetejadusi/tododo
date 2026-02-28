import 'package:hive/hive.dart';

import '../../core/services/hive_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  TaskRepository({required HiveService hiveService})
    : _hiveService = hiveService;

  final HiveService _hiveService;

  Box<Task> get _taskBox => _hiveService.taskBox;

  Future<void> createTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<List<Task>> getTasks() async {
    return _taskBox.values.toList(growable: false);
  }

  Future<Task?> getTaskById(String id) async {
    return _taskBox.get(id);
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  Future<void> clearTasks() async {
    await _taskBox.clear();
  }
}
