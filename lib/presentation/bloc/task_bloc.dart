import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(TaskState.initial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<SortTasks>(_onSortTasks);
    on<SearchTasks>(_onSearchTasks);
  }

  final TaskRepository _taskRepository;

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));

    try {
      final storedTasks = await _taskRepository.getTasks();
      final visibleTasks = _applyFiltersAndSorting(
        tasks: storedTasks,
        query: state.searchQuery,
        sortType: state.sortType,
      );

      emit(
        state.copyWith(
          status: TaskStatus.success,
          allTasks: storedTasks,
          visibleTasks: visibleTasks,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.createTask(event.task);
      add(const LoadTasks());
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task);
      add(const LoadTasks());
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.id);
      add(const LoadTasks());
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onSortTasks(SortTasks event, Emitter<TaskState> emit) {
    final visibleTasks = _applyFiltersAndSorting(
      tasks: state.allTasks,
      query: state.searchQuery,
      sortType: event.sortType,
    );

    emit(state.copyWith(sortType: event.sortType, visibleTasks: visibleTasks));
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    final query = event.query.trim();
    final visibleTasks = _applyFiltersAndSorting(
      tasks: state.allTasks,
      query: query,
      sortType: state.sortType,
    );

    emit(state.copyWith(searchQuery: query, visibleTasks: visibleTasks));
  }

  List<Task> _applyFiltersAndSorting({
    required List<Task> tasks,
    required String query,
    required TaskSortType sortType,
  }) {
    final normalizedQuery = query.toLowerCase();

    final filteredTasks = normalizedQuery.isEmpty
        ? tasks.toList(growable: false)
        : tasks
              .where((task) {
                return task.title.toLowerCase().contains(normalizedQuery) ||
                    task.description.toLowerCase().contains(normalizedQuery);
              })
              .toList(growable: false);

    filteredTasks.sort((a, b) {
      switch (sortType) {
        case TaskSortType.none:
          return a.createdAt.compareTo(b.createdAt);
        case TaskSortType.dueDateAsc:
          return a.dueDate.compareTo(b.dueDate);
        case TaskSortType.dueDateDesc:
          return b.dueDate.compareTo(a.dueDate);
        case TaskSortType.priorityHighToLow:
          return _priorityValue(
            b.priority,
          ).compareTo(_priorityValue(a.priority));
        case TaskSortType.priorityLowToHigh:
          return _priorityValue(
            a.priority,
          ).compareTo(_priorityValue(b.priority));
      }
    });

    return filteredTasks;
  }

  int _priorityValue(TaskPriority priority) {
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
