import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

Future<void> showTaskEditorSheet(BuildContext context, {Task? initialTask}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    clipBehavior: Clip.antiAlias,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _TaskEditorSheet(initialTask: initialTask),
  );
}

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({this.initialTask});

  final Task? initialTask;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();

  static const List<int> _remindBeforeOptions = [5, 10, 15, 30];

  TaskPriority? _selectedPriority;
  late DateTime _selectedDueDate;
  late TimeOfDay _selectedDueTime;
  late int _selectedRemindBefore;

  bool get _isEditMode => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTask;
    _titleController.text = initial?.title ?? '';
    _descriptionController.text = initial?.description ?? '';
    _selectedPriority = initial?.priority;
    _selectedDueDate =
        initial?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedDueTime = TimeOfDay.fromDateTime(_selectedDueDate);
    _selectedRemindBefore = initial?.remindBeforeMinutes ?? 15;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: insets),
      child: SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12,
                  ),
                  child: Text(
                    _isEditMode ? 'Edit Task' : 'New Task',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  autofocus: !_isEditMode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 14),
                Text('Priority', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('None'),
                      selected: _selectedPriority == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedPriority = null;
                        });
                      },
                    ),
                    ...TaskPriority.values.map(
                      (priority) => ChoiceChip(
                        label: Text(priority.name.toUpperCase()),
                        selected: _selectedPriority == priority,
                        onSelected: (_) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _DateTimeTile(
                        label: 'Due Date',
                        value: _formatDate(_selectedDueDate),
                        onTap: _pickDueDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DateTimeTile(
                        label: 'Due Time',
                        value: _formatTime(_selectedDueTime),
                        onTap: _pickDueTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Remind Before',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _remindBeforeOptions
                      .map(
                        (minutes) => ChoiceChip(
                          label: Text('$minutes min'),
                          selected: _selectedRemindBefore == minutes,
                          onSelected: (_) {
                            setState(() {
                              _selectedRemindBefore = minutes;
                            });
                          },
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(_isEditMode ? 'Update Task' : 'Create Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDueDate = picked;
    });
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDueTime = picked;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existing = widget.initialTask;
    final now = DateTime.now();
    final dueDateTime = DateTime(
      _selectedDueDate.year,
      _selectedDueDate.month,
      _selectedDueDate.day,
      _selectedDueTime.hour,
      _selectedDueTime.minute,
    );

    final task = Task(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? _titleController.text.trim()
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
      dueDate: dueDateTime,
      createdAt: existing?.createdAt ?? now,
      remindBeforeMinutes: _selectedRemindBefore,
      isCompleted: existing?.isCompleted ?? false,
    );

    if (_isEditMode) {
      context.read<TaskBloc>().add(UpdateTask(task));
    } else {
      context.read<TaskBloc>().add(AddTask(task));
    }

    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
