import 'package:equatable/equatable.dart';

import '../../data/models/task_model.dart';

enum TaskStatus { initial, loading, success, failure }

enum TaskSortType {
  none,
  dueDateAsc,
  dueDateDesc,
  priorityHighToLow,
  priorityLowToHigh,
}

class TaskState extends Equatable {
  const TaskState({
    required this.status,
    required this.allTasks,
    required this.visibleTasks,
    required this.searchQuery,
    required this.sortType,
    this.errorMessage,
  });

  factory TaskState.initial() {
    return const TaskState(
      status: TaskStatus.initial,
      allTasks: <Task>[],
      visibleTasks: <Task>[],
      searchQuery: '',
      sortType: TaskSortType.none,
      errorMessage: null,
    );
  }

  final TaskStatus status;
  final List<Task> allTasks;
  final List<Task> visibleTasks;
  final String searchQuery;
  final TaskSortType sortType;
  final String? errorMessage;

  TaskState copyWith({
    TaskStatus? status,
    List<Task>? allTasks,
    List<Task>? visibleTasks,
    String? searchQuery,
    TaskSortType? sortType,
    String? errorMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      visibleTasks: visibleTasks ?? this.visibleTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      allTasks,
      visibleTasks,
      searchQuery,
      sortType,
      errorMessage,
    ];
  }
}
