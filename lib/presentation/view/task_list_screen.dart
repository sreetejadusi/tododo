import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_list_item.dart';
import 'create_edit_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('TodoDo'),
        actions: [
          PopupMenuButton<TaskSortType>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort tasks',
            onSelected: (sortType) {
              context.read<TaskBloc>().add(SortTasks(sortType));
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: TaskSortType.priorityHighToLow,
                child: Text('Priority: High to Low'),
              ),
              PopupMenuItem(
                value: TaskSortType.priorityLowToHigh,
                child: Text('Priority: Low to High'),
              ),
              PopupMenuItem(
                value: TaskSortType.dueDateAsc,
                child: Text('Due Date: Earliest'),
              ),
              PopupMenuItem(
                value: TaskSortType.dueDateDesc,
                child: Text('Due Date: Latest'),
              ),
              PopupMenuItem(
                value: TaskSortType.createdNewest,
                child: Text('Created: Newest'),
              ),
              PopupMenuItem(
                value: TaskSortType.createdOldest,
                child: Text('Created: Oldest'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            onChanged: (value) {
              context.read<TaskBloc>().add(SearchTasks(value));
            },
          ),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading || state is TaskInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TaskError) {
                  return Center(child: Text(state.message));
                }

                if (state is TaskLoaded) {
                  if (state.tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 42,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No tasks available',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create a task to get started',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding = constraints.maxWidth > 700
                          ? constraints.maxWidth * 0.18
                          : 16.0;

                      return ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          12,
                          horizontalPadding,
                          24,
                        ),
                        itemCount: state.tasks.length,
                        onReorder: (oldIndex, newIndex) {
                          context.read<TaskBloc>().add(
                            ReorderTasks(
                              oldIndex: oldIndex,
                              newIndex: newIndex,
                            ),
                          );
                        },
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(16),
                            child: child,
                          );
                        },
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];
                          return Padding(
                            key: ValueKey(task.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Dismissible(
                                key: ValueKey('dismiss-${task.id}'),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    context.read<TaskBloc>().add(
                                      DeleteTask(task.id),
                                    );
                                    return true;
                                  }

                                  final toggled = task.copyWith(
                                    isCompleted: !task.isCompleted,
                                  );
                                  context.read<TaskBloc>().add(
                                    UpdateTask(toggled),
                                  );
                                  return false;
                                },
                                background: _SwipeActionBackground(
                                  alignment: Alignment.centerLeft,
                                  label: 'Delete',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.errorContainer,
                                ),
                                secondaryBackground: _SwipeActionBackground(
                                  alignment: Alignment.centerRight,
                                  label: task.isCompleted
                                      ? 'Mark Pending'
                                      : 'Mark Complete',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                ),
                                child: TaskListItem(
                                  task: task,
                                  onToggleCompleted: (isCompleted) {
                                    context.read<TaskBloc>().add(
                                      UpdateTask(
                                        task.copyWith(isCompleted: isCompleted),
                                      ),
                                    );
                                  },
                                  onEdit: () =>
                                      _openEditor(context, task: task),
                                  onDelete: () {
                                    context.read<TaskBloc>().add(
                                      DeleteTask(task.id),
                                    );
                                  },
                                  dragHandle: ReorderableDragStartListener(
                                    index: index,
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.menu),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Task'),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {Task? task}) {
    return showTaskEditorSheet(context, initialTask: task);
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SearchBar(
        hintText: 'Search by title or keyword',
        leading: const Icon(Icons.search),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 12),
        ),
        elevation: const WidgetStatePropertyAll<double>(0),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.alignment,
    required this.label,
    required this.color,
  });

  final Alignment alignment;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label, style: Theme.of(context).textTheme.labelLarge)],
      ),
    );
  }
}
