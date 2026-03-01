import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/notification_service.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required TaskRepository taskRepository,
    required NotificationService notificationService,
  }) : _taskRepository = taskRepository,
       _notificationService = notificationService,
       super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<SortTasks>(_onSortTasks);
    on<SearchTasks>(_onSearchTasks);
    on<ReorderTasks>(_onReorderTasks);
  }

  final TaskRepository _taskRepository;
  final NotificationService _notificationService;

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    final previousState = state;
    if (previousState is! TaskLoaded) {
      emit(const TaskLoading());
    }

    try {
      final storedTasks = await _taskRepository.getTasks();
      final sortType = previousState is TaskLoaded
          ? previousState.sortType
          : TaskSortType.createdNewest;
      final searchQuery = previousState is TaskLoaded
          ? previousState.searchQuery
          : '';

      final visibleTasks = _applySearchAndSort(
        tasks: storedTasks,
        query: searchQuery,
        sortType: sortType,
      );

      await _notificationService.syncAllTaskReminders(storedTasks);

      emit(
        TaskLoaded(
          tasks: visibleTasks,
          allTasks: storedTasks,
          sortType: sortType,
          searchQuery: searchQuery,
        ),
      );
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.createTask(event.task);
      await _notificationService.scheduleTaskReminder(event.task);
      add(const LoadTasks());
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task);
      await _notificationService.scheduleTaskReminder(event.task);
      add(const LoadTasks());
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.id);
      await _notificationService.cancelTaskReminder(event.id);
      add(const LoadTasks());
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  void _onSortTasks(SortTasks event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is! TaskLoaded) {
      return;
    }

    final tasks = _applySearchAndSort(
      tasks: currentState.allTasks,
      query: currentState.searchQuery,
      sortType: event.sortType,
    );

    emit(currentState.copyWith(tasks: tasks, sortType: event.sortType));
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is! TaskLoaded) {
      return;
    }

    final query = event.query.trim();
    final tasks = _applySearchAndSort(
      tasks: currentState.allTasks,
      query: query,
      sortType: currentState.sortType,
    );

    emit(currentState.copyWith(tasks: tasks, searchQuery: query));
  }

  void _onReorderTasks(ReorderTasks event, Emitter<TaskState> emit) {
    final currentState = state;
    if (currentState is! TaskLoaded) {
      return;
    }

    final tasks = currentState.tasks.toList(growable: false);
    if (tasks.isEmpty) {
      return;
    }

    var targetIndex = event.newIndex;
    if (event.oldIndex < targetIndex) {
      targetIndex -= 1;
    }

    if (event.oldIndex < 0 ||
        event.oldIndex >= tasks.length ||
        targetIndex < 0 ||
        targetIndex >= tasks.length) {
      return;
    }

    final reorderedVisible = tasks.toList(growable: false);
    final moved = reorderedVisible.removeAt(event.oldIndex);
    reorderedVisible.insert(targetIndex, moved);

    final reorderedAll = _reorderAllTasks(
      allTasks: currentState.allTasks,
      previousVisible: currentState.tasks,
      reorderedVisible: reorderedVisible,
    );

    emit(
      currentState.copyWith(
        tasks: reorderedVisible,
        allTasks: reorderedAll,
        sortType: TaskSortType.manual,
      ),
    );
  }

  List<Task> _applySearchAndSort({
    required List<Task> tasks,
    required String query,
    required TaskSortType sortType,
  }) {
    final normalized = query.toLowerCase();

    final filtered = normalized.isEmpty
        ? tasks.toList(growable: false)
        : tasks
              .where((task) {
                return task.title.toLowerCase().contains(normalized) ||
                    task.description.toLowerCase().contains(normalized);
              })
              .toList(growable: false);

    if (sortType != TaskSortType.manual) {
      filtered.sort((a, b) {
        switch (sortType) {
          case TaskSortType.manual:
            return 0;
          case TaskSortType.createdNewest:
            return b.createdAt.compareTo(a.createdAt);
          case TaskSortType.createdOldest:
            return a.createdAt.compareTo(b.createdAt);
          case TaskSortType.dueDateAsc:
            return a.dueDate.compareTo(b.dueDate);
          case TaskSortType.dueDateDesc:
            return b.dueDate.compareTo(a.dueDate);
          case TaskSortType.priorityHighToLow:
            return _priorityRank(
              b.priority,
            ).compareTo(_priorityRank(a.priority));
          case TaskSortType.priorityLowToHigh:
            return _priorityRank(
              a.priority,
            ).compareTo(_priorityRank(b.priority));
        }
      });
    }

    return filtered;
  }

  List<Task> _reorderAllTasks({
    required List<Task> allTasks,
    required List<Task> previousVisible,
    required List<Task> reorderedVisible,
  }) {
    final visibleIds = previousVisible.map((task) => task.id).toSet();
    final reorderedQueue = reorderedVisible.toList(growable: false);
    var reorderIndex = 0;

    final reorderedAll = <Task>[];
    for (final task in allTasks) {
      if (visibleIds.contains(task.id)) {
        reorderedAll.add(reorderedQueue[reorderIndex]);
        reorderIndex += 1;
      } else {
        reorderedAll.add(task);
      }
    }

    return reorderedAll;
  }

  int _priorityRank(TaskPriority? priority) {
    if (priority == null) {
      return -1;
    }

    switch (priority) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
    }
  }
}
