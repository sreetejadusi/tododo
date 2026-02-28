import 'package:equatable/equatable.dart';

import '../../data/models/task_model.dart';
import 'task_state.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => const [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class AddTask extends TaskEvent {
  const AddTask(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  const UpdateTask(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  const DeleteTask(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class SortTasks extends TaskEvent {
  const SortTasks(this.sortType);

  final TaskSortType sortType;

  @override
  List<Object?> get props => [sortType];
}

class SearchTasks extends TaskEvent {
  const SearchTasks(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
