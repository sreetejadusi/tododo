import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> clearTasks();
}
