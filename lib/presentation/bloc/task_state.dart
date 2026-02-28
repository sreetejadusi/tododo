import 'package:equatable/equatable.dart';

import '../../data/models/task_model.dart';

enum TaskSortType {
  manual,
  createdNewest,
  createdOldest,
  dueDateAsc,
  dueDateDesc,
  priorityHighToLow,
  priorityLowToHigh,
}

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => const [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  const TaskLoaded({
    required this.tasks,
    required this.allTasks,
    required this.sortType,
    required this.searchQuery,
  });

  final List<Task> tasks;
  final List<Task> allTasks;
  final TaskSortType sortType;
  final String searchQuery;

  TaskLoaded copyWith({
    List<Task>? tasks,
    List<Task>? allTasks,
    TaskSortType? sortType,
    String? searchQuery,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      allTasks: allTasks ?? this.allTasks,
      sortType: sortType ?? this.sortType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [tasks, allTasks, sortType, searchQuery];
}

class TaskError extends TaskState {
  const TaskError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
