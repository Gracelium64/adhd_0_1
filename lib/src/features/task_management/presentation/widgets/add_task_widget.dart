import 'dart:math' as math;

import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';
import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/sub_task_draft.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

enum TaskType { daily, weekly, deadline, quest }

class AddTaskWidget extends StatefulWidget {
  final TaskType taskType;
  final VoidCallback onClose;

  const AddTaskWidget({
    super.key,
    required this.taskType,
    required this.onClose,
  });

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController userInput;
  final List<SubTaskFormDraft> _subTaskDrafts = [];

  TaskType selectedType = TaskType.daily;
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
    userInput = TextEditingController(text: '');
    selectedType = widget.taskType;
    if (selectedType == TaskType.weekly) {
      selectedWeekday = Weekday.any;
    }
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
      if (type == TaskType.weekly && selectedWeekday == null) {
        selectedWeekday = Weekday.any;
      }
      if (type != TaskType.weekly) {
        selectedWeekday = null;
      }
      if (type != TaskType.deadline) {
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
      _subTaskDrafts.remove(draft);
      draft.dispose();
    });
  }

  Widget _buildSubTaskEditor(SubTaskFormDraft draft) {
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
                fillColor: Palette.monarchPurple2.withAlpha(80),
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
    return '$day/$month/$year';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return 'HH:MM';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _weekdayLabel(Weekday? day) {
    if (day == null) return 'Select Day';
    final label = day.label;
    return '${label[0].toUpperCase()}${label.substring(1)}';
  }

  Future<void> _save() async {
    if (!_confirmEnabled) return;
    setState(() => _isSaving = true);
    final repository = context.read<DataBaseRepository>();
    final name = userInput.text.trim();
    final drafts = _subTaskDrafts
        .where((draft) => draft.description.isNotEmpty)
        .toList(growable: false);

    Future<Task?> detectCreatedTask(
      Future<List<Task>> Function() fetch,
      Set<String> before,
    ) async {
      final tasks = await fetch();
      for (final task in tasks) {
        if (!before.contains(task.taskId)) return task;
      }
      return null;
    }

    try {
      await showBlockingLoaderDuring(
        context,
        () async {
          Task? createdTask;
          if (selectedType == TaskType.daily) {
            Set<String> before = {};
            if (drafts.isNotEmpty) {
              final existing = await repository.getDailyTasks();
              before = existing.map((t) => t.taskId).toSet();
            }
            await repository.addDaily(name);
            await refreshDailyProgress(repository);
            if (drafts.isNotEmpty) {
              createdTask = await detectCreatedTask(
                repository.getDailyTasks,
                before,
              );
            }
          } else if (selectedType == TaskType.weekly) {
            final weekday = selectedWeekday ?? Weekday.any;
            Set<String> before = {};
            if (drafts.isNotEmpty) {
              final existing = await repository.getWeeklyTasks();
              before = existing.map((t) => t.taskId).toSet();
            }
            await repository.addWeekly(name, weekday.name);
            await refreshWeeklyProgress(repository);
            if (drafts.isNotEmpty) {
              createdTask = await detectCreatedTask(
                repository.getWeeklyTasks,
                before,
              );
            }
          } else if (selectedType == TaskType.deadline) {
            if (selectedDate == null || selectedTime == null) return;
            Set<String> before = {};
            if (drafts.isNotEmpty) {
              final existing = await repository.getDeadlineTasks();
              before = existing.map((t) => t.taskId).toSet();
            }
            final dateStr = formatDate(selectedDate);
            final timeStr = formatTime(selectedTime);
            await repository.addDeadline(name, dateStr, timeStr);
            if (drafts.isNotEmpty) {
              createdTask = await detectCreatedTask(
                repository.getDeadlineTasks,
                before,
              );
            }
          } else if (selectedType == TaskType.quest) {
            Set<String> before = {};
            if (drafts.isNotEmpty) {
              final existing = await repository.getQuestTasks();
              before = existing.map((t) => t.taskId).toSet();
            }
            await repository.addQuest(name);
            if (drafts.isNotEmpty) {
              createdTask = await detectCreatedTask(
                repository.getQuestTasks,
                before,
              );
            }
          }

          if (createdTask == null || drafts.isEmpty) {
            return;
          }

          Task current = createdTask;
          for (final draft in drafts) {
            current = await repository.addSubTask(current, draft.description);
            if (draft.isDone && current.subTasks.isNotEmpty) {
              final subTask = current.subTasks.last;
              current = await repository.toggleSubTask(
                current,
                subTask.subTaskId,
                true,
              );
            }
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
            'Could not save task: $e',
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
              final maxHeight = math.min(availableHeight, 620.0);
              final minHeight = math.min(availableHeight, 520.0);

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
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Every adventure needs a name';
                                      }
                                      if (value.trim().length >= 30) {
                                        return 'But not a name that long!';
                                      }
                                      return null;
                                    },
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
                                  if (_subTaskDrafts.isEmpty)
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
