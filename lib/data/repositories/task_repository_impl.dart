import '../../core/services/hive_service.dart';
import '../models/task_model.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required HiveService hiveService})
    : _hiveService = hiveService;

  final HiveService _hiveService;

  @override
  Future<List<Task>> getTasks() {
    return _hiveService.getTasks();
  }

  @override
  Future<void> saveTask(Task task) {
    return _hiveService.saveTask(task);
  }

  @override
  Future<void> deleteTask(String id) {
    return _hiveService.deleteTask(id);
  }

  @override
  Future<void> clearTasks() {
    return _hiveService.clearTasks();
  }
}
