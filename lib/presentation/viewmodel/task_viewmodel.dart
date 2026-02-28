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
    final existingTask = await _taskRepository.getTaskById(task.id);
    if (existingTask == null) {
      await _taskRepository.createTask(task);
    } else {
      await _taskRepository.updateTask(task);
    }
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskRepository.updateTask(updatedTask);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await loadTasks();
  }
}
