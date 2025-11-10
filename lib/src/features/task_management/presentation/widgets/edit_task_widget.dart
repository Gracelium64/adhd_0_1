import 'dart:math' as math;

import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';
import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/delete_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/sub_task_draft.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

enum TaskType { daily, weekly, deadline, quest }

class EditTaskWidget extends StatefulWidget {
  final Task task;
  final TaskType taskType;
  final VoidCallback onClose;

  const EditTaskWidget({
    super.key,
    required this.task,
    required this.taskType,
    required this.onClose,
  });

  @override
  State<EditTaskWidget> createState() => _EditTaskWidgetState();
}

class _EditTaskWidgetState extends State<EditTaskWidget> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController userInput;
  final List<SubTaskFormDraft> _subTaskDrafts = [];
  late Map<String, SubTask> _originalSubTasksById;

  late TaskType selectedType;
  Weekday? selectedWeekday;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool _formValid = false;
  bool _isSaving = false;

  Color get _activeButtonColor => Palette.basicBitchWhite;
  Color get _passiveButtonColor => Palette.basicBitchBlack;

  @override
  void initState() {
    super.initState();
    userInput = TextEditingController(text: widget.task.taskDesctiption);
    selectedType = widget.taskType;
    selectedWeekday =
        selectedType == TaskType.weekly
            ? _weekdayFromString(widget.task.dayOfWeek) ?? Weekday.any
            : null;
    selectedDate =
        selectedType == TaskType.deadline
            ? _parseDate(widget.task.deadlineDate)
            : null;
    selectedTime =
        selectedType == TaskType.deadline
            ? _parseTime(widget.task.deadlineTime)
            : null;

    _originalSubTasksById = {
      for (final subTask in widget.task.subTasks)
        subTask.subTaskId: _cloneSubTask(subTask),
    };
    for (final subTask in widget.task.subTasks) {
      _subTaskDrafts.add(SubTaskFormDraft.fromSubTask(subTask));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onFormChanged();
    });
  }

  @override
  void dispose() {
    userInput.dispose();
    for (final draft in _subTaskDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _onFormChanged() {
    final valid = formKey.currentState?.validate() ?? false;
    if (valid != _formValid) {
      setState(() => _formValid = valid);
    }
  }

  bool get _requiresWeekday => selectedType == TaskType.weekly;
  bool get _requiresDeadline => selectedType == TaskType.deadline;

  bool get _confirmEnabled {
    if (_isSaving || !_formValid) return false;
    if (_requiresWeekday && selectedWeekday == null) return false;
    if (_requiresDeadline && (selectedDate == null || selectedTime == null)) {
      return false;
    }
    return true;
  }

  void _handleTypeSelection(TaskType type) {
    if (selectedType == type) return;
    setState(() {
      selectedType = type;
      if (type == TaskType.weekly) {
        selectedWeekday ??= Weekday.any;
        selectedDate = null;
        selectedTime = null;
      } else if (type == TaskType.deadline) {
        selectedDate ??= DateTime.now();
        selectedTime ??= TimeOfDay.now();
        selectedWeekday = null;
      } else {
        selectedWeekday = null;
        selectedDate = null;
        selectedTime = null;
      }
    });
  }

  void _addSubTaskDraft() {
    setState(() {
      _subTaskDrafts.add(SubTaskFormDraft.empty());
    });
  }

  void _removeDraft(SubTaskFormDraft draft) {
    setState(() {
      if (draft.id == null) {
        _subTaskDrafts.remove(draft);
        draft.dispose();
      } else {
        draft.removed = true;
      }
    });
  }

  void _restoreDraft(SubTaskFormDraft draft) {
    setState(() => draft.removed = false);
  }

  Widget _buildSubTaskEditor(SubTaskFormDraft draft) {
    if (draft.removed) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Palette.monarchPurple2.withAlpha(60),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.basicBitchWhite.withAlpha(120)),
        ),
        child: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Marked for deletion',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Palette.lightTeal),
              ),
            ),
            TextButton(
              onPressed: () => _restoreDraft(draft),
              child: const Text('Undo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final index = _subTaskDrafts.indexOf(draft) + 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: draft.isDone,
            activeColor: Palette.lightTeal,
            onChanged: (value) {
              setState(() => draft.isDone = value ?? false);
            },
          ),
          Expanded(
            child: TextField(
              controller: draft.controller,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Subtask $index',
                filled: true,
                fillColor: Palette.monarchPurple2.withAlpha(90),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              cursorColor: Palette.basicBitchWhite,
              style: TextStyle(color: Palette.basicBitchWhite),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Palette.basicBitchWhite,
            tooltip: 'Remove subtask',
            onPressed: () => _removeDraft(draft),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Day';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year % 100;
    return '$day/$month/${year.toString().padLeft(2, '0')}';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return 'HH:MM';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _weekdayLabel(Weekday? day) {
    if (day == null) return 'Select day';
    final label = day.label;
    return '${label[0].toUpperCase()}${label.substring(1)}';
  }

  Weekday? _weekdayFromString(String? name) {
    if (name == null || name.isEmpty) return null;
    return Weekday.values.firstWhere(
      (w) => w.name == name,
      orElse: () => Weekday.any,
    );
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    final fullYear = year < 100 ? 2000 + year : year;
    return DateTime(fullYear, month, day);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  SubTask _cloneSubTask(SubTask subTask) => SubTask(
    subTaskId: subTask.subTaskId,
    description: subTask.description,
    isDone: subTask.isDone,
    orderIndex: subTask.orderIndex,
  );

  String _categoryLabelForType(TaskType type) {
    switch (type) {
      case TaskType.daily:
        return 'daily';
      case TaskType.weekly:
        return 'weekly';
      case TaskType.deadline:
        return 'deadline';
      case TaskType.quest:
        return 'quest';
    }
  }

  Future<void> _refreshProgressForType(
    DataBaseRepository repository,
    TaskType type,
  ) async {
    switch (type) {
      case TaskType.daily:
        await refreshDailyProgress(repository);
        break;
      case TaskType.weekly:
        await refreshWeeklyProgress(repository);
        break;
      case TaskType.deadline:
      case TaskType.quest:
        break;
    }
  }

  Future<void> _deleteTask() async {
    final repository = context.read<DataBaseRepository>();
    try {
      await showBlockingLoaderDuring(
        context,
        () async {
          switch (widget.taskType) {
            case TaskType.daily:
              await repository.deleteDaily(widget.task.taskId);
              await refreshDailyProgress(repository);
              break;
            case TaskType.weekly:
              await repository.deleteWeekly(widget.task.taskId);
              await refreshWeeklyProgress(repository);
              break;
            case TaskType.deadline:
              await repository.deleteDeadline(widget.task.taskId);
              break;
            case TaskType.quest:
              await repository.deleteQuest(widget.task.taskId);
              break;
          }
        },
      );
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete task: $e',
            style: Theme.of(context).snackBarTheme.contentTextStyle,
          ),
        ),
      );
    }
  }

  String? _taskNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Every adventure needs a name';
    }
    if (value.trim().length >= 30) {
      return 'But not a name that long!';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_confirmEnabled) return;
    setState(() => _isSaving = true);
    final repository = context.read<DataBaseRepository>();
    final String newName = userInput.text.trim();
    final TaskType originalType = widget.taskType;
    final TaskType targetType = selectedType;
    final bool isWeeklyTarget = selectedType == TaskType.weekly;
    final bool isDeadlineTarget = selectedType == TaskType.deadline;

    Weekday? targetWeekday =
        isWeeklyTarget ? (selectedWeekday ?? Weekday.any) : null;
    DateTime? targetDate = isDeadlineTarget ? selectedDate : null;
    TimeOfDay? targetTime = isDeadlineTarget ? selectedTime : null;

    try {
      await showBlockingLoaderDuring(
        context,
        () async {
          Task currentTask = widget.task;

          if (targetType != originalType) {
            final replacement = Task(
              currentTask.taskId,
              _categoryLabelForType(targetType),
              newName,
              targetType == TaskType.deadline ? formatDate(targetDate) : null,
              targetType == TaskType.deadline ? formatTime(targetTime) : null,
              targetType == TaskType.weekly ? targetWeekday?.name : null,
              currentTask.isDone,
              orderIndex: currentTask.orderIndex,
              subTasks: currentTask.subTasks.map(_cloneSubTask).toList(),
            );
            currentTask = await repository.replaceTask(
              currentTask,
              replacement,
            );
            await _refreshProgressForType(repository, originalType);
            await _refreshProgressForType(repository, targetType);
          }

          switch (targetType) {
            case TaskType.daily:
              if (newName != widget.task.taskDesctiption) {
                await repository.editDaily(currentTask.taskId, newName);
                await refreshDailyProgress(repository);
              }
              break;
            case TaskType.weekly:
              final Weekday effectiveWeekday = targetWeekday ?? Weekday.any;
              if (newName != widget.task.taskDesctiption ||
                  effectiveWeekday.name !=
                      (widget.task.dayOfWeek ?? Weekday.any.name)) {
                await repository.editWeekly(
                  currentTask.taskId,
                  newName,
                  effectiveWeekday,
                );
                await refreshWeeklyProgress(repository);
              }
              break;
            case TaskType.deadline:
              targetDate ??=
                  selectedDate ?? _parseDate(widget.task.deadlineDate);
              targetTime ??=
                  selectedTime ?? _parseTime(widget.task.deadlineTime);
              if (targetDate == null || targetTime == null) {
                throw StateError('Deadline tasks require both date and time');
              }
              final formattedDate = formatDate(targetDate);
              final formattedTime = formatTime(targetTime);
              if (formattedDate != widget.task.deadlineDate ||
                  formattedTime != widget.task.deadlineTime ||
                  newName != widget.task.taskDesctiption ||
                  targetType != originalType) {
                await repository.editDeadline(
                  currentTask.taskId,
                  newName,
                  formattedDate,
                  formattedTime,
                );
              }
              break;
            case TaskType.quest:
              if (newName != widget.task.taskDesctiption) {
                await repository.editQuest(currentTask.taskId, newName);
              }
              break;
          }

          final Map<String, SubTask> originalById = Map.of(
            _originalSubTasksById,
          );
          for (final draft in _subTaskDrafts) {
            final String? draftId = draft.id;
            final String description = draft.description;

            if (draft.removed) {
              if (draftId != null) {
                currentTask = await repository.deleteSubTask(
                  currentTask,
                  draftId,
                );
              }
              continue;
            }

            if (draftId == null) {
              if (description.isEmpty) continue;
              currentTask = await repository.addSubTask(
                currentTask,
                description,
              );
              if (draft.isDone && currentTask.subTasks.isNotEmpty) {
                final added = currentTask.subTasks.last;
                currentTask = await repository.toggleSubTask(
                  currentTask,
                  added.subTaskId,
                  true,
                );
              }
              continue;
            }

            final SubTask? original = originalById.remove(draftId);
            if (original == null) continue;

            if (description.isEmpty) {
              currentTask = await repository.deleteSubTask(
                currentTask,
                draftId,
              );
              continue;
            }

            if (original.description != description) {
              currentTask = await repository.editSubTask(
                currentTask,
                draftId,
                description,
              );
            }

            if (original.isDone != draft.isDone) {
              currentTask = await repository.toggleSubTask(
                currentTask,
                draftId,
                draft.isDone,
              );
            }
          }

          for (final leftover in originalById.values) {
            currentTask = await repository.deleteSubTask(
              currentTask,
              leftover.subTaskId,
            );
          }
        },
      );

      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save changes: $e',
            style: Theme.of(context).snackBarTheme.contentTextStyle,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final maxWidth = math.min(360.0, media.size.width - 32);

    final isWeekly = _requiresWeekday;
    final isDeadline = _requiresDeadline;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: bottomInset > 0 ? bottomInset + 16 : 24,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = math.min(
                constraints.maxHeight,
                media.size.height - 48,
              );
              final maxHeight = math.min(availableHeight, 640.0);
              final minHeight = math.min(availableHeight, 540.0);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Palette.monarchPurple1Opacity,
                      border: Border.all(
                        color: Palette.basicBitchWhite,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.basicBitchBlack.withAlpha(120),
                          blurRadius: 12,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Form(
                              key: formKey,
                              onChanged: _onFormChanged,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Task name',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: userInput,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    textAlign: TextAlign.center,
                                    validator: _taskNameValidator,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Palette.monarchPurple2
                                          .withAlpha(110),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 12,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: Palette.basicBitchWhite,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Day of the week',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AbsorbPointer(
                                          absorbing: !isWeekly,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  isWeekly
                                                      ? Palette.monarchPurple2
                                                          .withAlpha(110)
                                                      : Palette.monarchPurple2
                                                          .withAlpha(60),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color:
                                                    isWeekly
                                                        ? Palette
                                                            .basicBitchBlack
                                                        : Palette
                                                            .basicBitchBlack
                                                            .withAlpha(85),
                                              ),
                                            ),
                                            child: PopupMenuButton<Weekday>(
                                              enabled: isWeekly,
                                              initialValue: selectedWeekday,
                                              color: Palette.monarchPurple2,
                                              onSelected: (weekday) {
                                                setState(() {
                                                  selectedWeekday = weekday;
                                                });
                                              },
                                              itemBuilder: (context) {
                                                return Weekday.values
                                                    .map(
                                                      (day) => PopupMenuItem<
                                                        Weekday
                                                      >(
                                                        value: day,
                                                        child: Text(
                                                          _weekdayLabel(day),
                                                          style: TextStyle(
                                                            color:
                                                                Palette
                                                                    .basicBitchWhite,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList();
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      _weekdayLabel(
                                                        selectedWeekday,
                                                      ),
                                                      style: TextStyle(
                                                        color: Palette
                                                            .basicBitchWhite
                                                            .withAlpha(
                                                              isWeekly
                                                                  ? 255
                                                                  : 140,
                                                            ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Palette
                                                          .basicBitchWhite
                                                          .withAlpha(
                                                            isWeekly
                                                                ? 255
                                                                : 140,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Deadline',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            side: BorderSide(
                                              color:
                                                  isDeadline
                                                      ? Palette.basicBitchWhite
                                                      : Palette.basicBitchWhite
                                                          .withAlpha(120),
                                              width: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed:
                                              isDeadline ? _pickDate : null,
                                          child: Text(
                                            formatDate(selectedDate),
                                            style: TextStyle(
                                              color: Palette.basicBitchWhite
                                                  .withAlpha(
                                                    isDeadline ? 255 : 160,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            side: BorderSide(
                                              color:
                                                  isDeadline
                                                      ? Palette.basicBitchWhite
                                                      : Palette.basicBitchWhite
                                                          .withAlpha(120),
                                              width: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed:
                                              isDeadline ? _pickTime : null,
                                          child: Text(
                                            formatTime(selectedTime),
                                            style: TextStyle(
                                              color: Palette.basicBitchWhite
                                                  .withAlpha(
                                                    isDeadline ? 255 : 160,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Subtasks',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (_subTaskDrafts
                                      .where((d) => !d.removed)
                                      .isEmpty)
                                    Text(
                                      'No subtasks yet – add one below to break this quest down.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Palette.lightTeal),
                                    ),
                                  ..._subTaskDrafts.map(_buildSubTaskEditor),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _addSubTaskDraft,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add subtask'),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Task type',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          runSpacing: 8,
                                          children: [
                                            _TypeChip(
                                              label: 'Dailys',
                                              selected:
                                                  selectedType ==
                                                  TaskType.daily,
                                              onTap:
                                                  () => _handleTypeSelection(
                                                    TaskType.daily,
                                                  ),
                                              activeColor: _activeButtonColor,
                                              passiveColor: _passiveButtonColor,
                                            ),
                                            Gap(8),
                                            _TypeChip(
                                              label: 'Weeklys',
                                              selected:
                                                  selectedType ==
                                                  TaskType.weekly,
                                              onTap:
                                                  () => _handleTypeSelection(
                                                    TaskType.weekly,
                                                  ),
                                              activeColor: _activeButtonColor,
                                              passiveColor: _passiveButtonColor,
                                            ),
                                            Gap(8),
                                            _TypeChip(
                                              label: 'Deadlineys',
                                              selected:
                                                  selectedType ==
                                                  TaskType.deadline,
                                              onTap:
                                                  () => _handleTypeSelection(
                                                    TaskType.deadline,
                                                  ),
                                              activeColor: _activeButtonColor,
                                              passiveColor: _passiveButtonColor,
                                            ),
                                            Gap(8),
                                            _TypeChip(
                                              label: 'Quest',
                                              selected:
                                                  selectedType ==
                                                  TaskType.quest,
                                              onTap:
                                                  () => _handleTypeSelection(
                                                    TaskType.quest,
                                                  ),
                                              activeColor: _activeButtonColor,
                                              passiveColor: _passiveButtonColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          decoration: BoxDecoration(
                            color: Palette.monarchPurple1Opacity.withAlpha(200),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              DeleteButton(
                                onPressed: () {
                                  if (_isSaving) return;
                                  _deleteTask();
                                },
                              ),
                              CancelButton(
                                onPressed: () {
                                  if (_isSaving) return;
                                  widget.onClose();
                                },
                              ),
                              ConfirmButton(
                                onPressed:
                                    _confirmEnabled
                                        ? () {
                                          _save();
                                        }
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color passiveColor;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.passiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : passiveColor;
    final textColor =
        color.computeLuminance() > 0.5
            ? Palette.basicBitchBlack
            : Palette.basicBitchWhite;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
