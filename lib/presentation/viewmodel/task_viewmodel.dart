import 'package:flutter/foundation.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  TaskViewModel({required TaskRepository taskRepository})
    : _taskRepository = taskRepository;

  final TaskRepository _taskRepository;

  List<Task> _tasks = const [];
  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await _taskRepository.getTasks();
    notifyListeners();
  }

  Future<void> addOrUpdateTask(Task task) async {
    await _taskRepository.saveTask(task);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskRepository.saveTask(updatedTask);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await loadTasks();
  }
}
