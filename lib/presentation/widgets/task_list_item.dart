import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    required this.task,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
    required this.dragHandle,
    super.key,
  });

  final Task task;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = isCompleted
        ? colorScheme.onSurface.withValues(alpha: 0.55)
        : colorScheme.onSurface;
    final backgroundColor = isCompleted
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
        : colorScheme.surface;

    return Card(
      elevation: isCompleted ? 0 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RadioStyleToggle(
                isCompleted: task.isCompleted,
                onTap: () => onToggleCompleted(!task.isCompleted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _PriorityChip(
                          priority: task.priority,
                          isCompleted: isCompleted,
                        ),
                        _InfoChip(
                          label: 'Due ${_formatDate(task.dueDate)}',
                          isCompleted: isCompleted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              dragHandle,
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute $suffix';
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority, required this.isCompleted});

  final TaskPriority? priority;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (priority == null) {
      return Container();
    }

    final resolvedPriority = priority!;
    final color = isCompleted
        ? Colors.grey
        : switch (resolvedPriority) {
            TaskPriority.low => Colors.green,
            TaskPriority.medium => Colors.orange,
            TaskPriority.high => Colors.red,
          };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        resolvedPriority.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: isCompleted ? 0.5 : 1,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isCompleted
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
              : null,
        ),
      ),
    );
  }
}

class _RadioStyleToggle extends StatelessWidget {
  const _RadioStyleToggle({required this.isCompleted, required this.onTap});

  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Icon(
        isCompleted ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isCompleted ? color : Theme.of(context).colorScheme.outline,
        size: 24,
      ),
    );
  }
}
