import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/delete_button.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum TaskType { daily, weekly, deadline, quest }

class EditTaskWidget extends StatefulWidget {
  // final OverlayPortalController controller;
  final Task task;
  final TaskType taskType;
  final void Function() onClose;

  const EditTaskWidget(
  // this.controller,
  {
    super.key,
    required this.task,
    required this.taskType,
    required this.onClose,
  });

  @override
  State<EditTaskWidget> createState() => _EditTaskWidgetState();
}

class _EditTaskWidgetState extends State<EditTaskWidget> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    return DateTime(2000 + year, month, day);
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'DAY';
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

  Weekday? selectedWeekday;
  final formKey = GlobalKey<FormState>();
  bool isButtonEnabled = true;

  String? _taskLengthValidator(String? userInput) {
    if (userInput == null || userInput.isEmpty) {
      return 'Every adventure needs a name';
    }
    if (userInput.length >= 30) {
      return 'But not a name that long!';
    }
    return null;
  }

  late TextEditingController userInput;

  Color activeButtonColor = Palette.darkTeal;
  Color passiveButtonColor = Palette.peasantGrey2;

  late TaskType selectedType;

  Weekday? _weekdayFromString(String? raw) {
    if (raw == null) return null;
    final s = raw.toString();
    final last = s.contains('.') ? s.split('.').last : s;
    final lc = last.toLowerCase();
    try {
      return Weekday.values.firstWhere((w) => w.name == lc);
    } catch (_) {
      return null;
    }
  }

  String? _displayDayLabel(Weekday? day) {
    if (day == null || day == Weekday.any) return null;
    final label = day.name; // enum name like 'mon'
    return label[0].toUpperCase() + label.substring(1);
  }

  @override
  void initState() {
    super.initState();
    userInput = TextEditingController(text: widget.task.taskDesctiption);
    selectedType = widget.taskType;

    if (selectedType == TaskType.deadline) {
      selectedDate = _parseDate(widget.task.deadlineDate);
      selectedTime = _parseTime(widget.task.deadlineTime);
    }
    if (selectedType == TaskType.weekly) {
      selectedWeekday = _weekdayFromString(widget.task.dayOfWeek);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    final isWeekly = selectedType == TaskType.weekly;
    final isDeadline = selectedType == TaskType.deadline;

    final Weekday? initialWeeklyDay = _weekdayFromString(widget.task.dayOfWeek);
    final String weeklyButtonLabel =
        (() {
          if (selectedWeekday != null) {
            final l = selectedWeekday!.name;
            return l[0].toUpperCase() + l.substring(1);
          }
          final d = _displayDayLabel(initialWeeklyDay);
          return d ?? 'Select Day';
        })();

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(left: 25, bottom: bottomInset),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 82),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.basicBitchWhite.withAlpha(175),
                      blurRadius: 5,
                      blurStyle: BlurStyle.inner,
                    ),
                    BoxShadow(
                      color: Palette.basicBitchBlack.withAlpha(125),
                      offset: Offset(4, 4),
                      blurRadius: 5,
                    ),
                    BoxShadow(
                      color: Palette.monarchPurple1Opacity,
                      blurStyle: BlurStyle.solid,
                    ),
                  ],
                ),
                height: 578,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
                  child: Form(
                    key: formKey,
                    onChanged: () {
                      setState(() {
                        final bool isFormValid =
                            formKey.currentState!.validate();
                        isButtonEnabled = !isFormValid;
                      });
                    },

                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task name',
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _taskLengthValidator,
                          controller: userInput,
                          style: TextStyle(color: Palette.basicBitchWhite),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Palette.monarchPurple2.withAlpha(100),

                            contentPadding: EdgeInsets.only(bottom: 14),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Palette.basicBitchBlack,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintStyle: TextStyle(
                              color: Palette.basicBitchBlack,
                              fontFamily: 'Inter',
                              fontSize: 12,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                        ),

                        Text(
                          'Day of the week',
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: AbsorbPointer(
                                absorbing: !isWeekly,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isWeekly
                                            ? Palette.monarchPurple2.withAlpha(
                                              100,
                                            )
                                            : Palette.monarchPurple2.withAlpha(
                                              50,
                                            ),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color:
                                          isWeekly
                                              ? Palette.basicBitchBlack
                                              : Palette.basicBitchBlack
                                                  .withAlpha(85),
                                    ),
                                  ),
                                  child: PopupMenuButton<Weekday>(
                                    initialValue: selectedWeekday,
                                    onSelected: (Weekday value) {
                                      setState(() {
                                        selectedWeekday = value;
                                      });
                                    },
                                    color: Palette.monarchPurple2,
                                    itemBuilder: (context) {
                                      return Weekday.values.map((day) {
                                        final label =
                                            day.label[0].toUpperCase() +
                                            day.label.substring(1);
                                        return PopupMenuItem<Weekday>(
                                          value: day,
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              color: Palette.basicBitchWhite,
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          weeklyButtonLabel,
                                          style: TextStyle(
                                            color:
                                                isWeekly
                                                    ? Palette.basicBitchWhite
                                                    : Palette.basicBitchWhite
                                                        .withAlpha(85),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color:
                                              isWeekly
                                                  ? Palette.basicBitchWhite
                                                  : Palette.basicBitchWhite
                                                      .withAlpha(85),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Deadline',
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AbsorbPointer(
                              absorbing: !isDeadline,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    side: BorderSide(
                                      color:
                                          isDeadline
                                              ? Palette.basicBitchWhite
                                              : Palette.basicBitchWhite
                                                  .withAlpha(85),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() => selectedDate = picked);
                                  }
                                },
                                child: Text(
                                  formatDate(selectedDate),
                                  style: TextStyle(
                                    color:
                                        isDeadline
                                            ? Palette.basicBitchWhite
                                            : Palette.basicBitchWhite.withAlpha(
                                              127,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                            AbsorbPointer(
                              absorbing: !isDeadline,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    side: BorderSide(
                                      color:
                                          isDeadline
                                              ? Palette.basicBitchWhite
                                              : Palette.basicBitchWhite
                                                  .withAlpha(85),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        selectedTime ?? TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => selectedTime = picked);
                                  }
                                },
                                child: Text(
                                  formatTime(selectedTime),
                                  style: TextStyle(
                                    color:
                                        isDeadline
                                            ? Palette.basicBitchWhite
                                            : Palette.basicBitchWhite.withAlpha(
                                              127,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AbsorbPointer(
                              absorbing: selectedType == TaskType.daily,
                              child: GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  //   selectedType = TaskType.daily;
                                  // });
                                },
                                child: Container(
                                  height: 40,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color:
                                        selectedType == TaskType.daily
                                            ? activeButtonColor
                                            : passiveButtonColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      'Dailys',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   selectedType = TaskType.weekly;
                                // });
                              },
                              child: Container(
                                height: 40,
                                width: 130,
                                decoration: BoxDecoration(
                                  color:
                                      selectedType == TaskType.weekly
                                          ? activeButtonColor
                                          : passiveButtonColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Weeklys',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   selectedType = TaskType.deadline;
                                // });
                              },
                              child: Container(
                                height: 40,
                                width: 130,
                                decoration: BoxDecoration(
                                  color:
                                      selectedType == TaskType.deadline
                                          ? activeButtonColor
                                          : passiveButtonColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Deadlineys',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // setState(() {
                                //   selectedType = TaskType.quest;
                                // });
                              },
                              child: Container(
                                height: 40,
                                width: 130,
                                decoration: BoxDecoration(
                                  color:
                                      selectedType == TaskType.quest
                                          ? activeButtonColor
                                          : passiveButtonColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Quest',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 36),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DeleteButton(
                              onPressed: () async {
                                await showBlockingLoaderDuring(
                                  context,
                                  () async {
                                    if (selectedType == TaskType.daily) {
                                      await repository.deleteDaily(
                                        widget.task.taskId,
                                      );
                                      await refreshDailyProgress(repository);
                                      debugPrint('delete daily complete');
                                    } else if (selectedType ==
                                        TaskType.weekly) {
                                      await repository.deleteWeekly(
                                        widget.task.taskId,
                                      );
                                      await refreshWeeklyProgress(repository);
                                      debugPrint('delete weekly complete');
                                    } else if (selectedType ==
                                        TaskType.deadline) {
                                      await repository.deleteDeadline(
                                        widget.task.taskId,
                                      );
                                      debugPrint('delete deadline complete');
                                    } else if (selectedType == TaskType.quest) {
                                      await repository.deleteQuest(
                                        widget.task.taskId,
                                      );
                                      debugPrint('delete quest complete');
                                    }
                                  },
                                );
                                widget.onClose();
                              },
                            ),
                            CancelButton(
                              onPressed: () {
                                widget.onClose();
                              },
                            ),
                            ConfirmButton(
                              onPressed: () async {
                                // Determine changes by type
                                final originalName =
                                    widget.task.taskDesctiption;
                                final newName = userInput.text;
                                bool changed = false;

                                await showBlockingLoaderDuring(
                                  context,
                                  () async {
                                    if (selectedType == TaskType.daily) {
                                      if (newName != originalName) {
                                        await repository.editDaily(
                                          widget.task.taskId,
                                          newName,
                                        );
                                        await refreshDailyProgress(repository);
                                        changed = true;
                                      }
                                    } else if (selectedType ==
                                        TaskType.weekly) {
                                      final originalDay = _weekdayFromString(
                                        widget.task.dayOfWeek,
                                      );
                                      if (newName != originalName ||
                                          (selectedWeekday != null &&
                                              selectedWeekday != originalDay)) {
                                        await repository.editWeekly(
                                          widget.task.taskId,
                                          newName,
                                          selectedWeekday ?? originalDay!,
                                        );
                                        await refreshWeeklyProgress(repository);
                                        changed = true;
                                      }
                                    } else if (selectedType ==
                                        TaskType.deadline) {
                                      final originalDate = _parseDate(
                                        widget.task.deadlineDate,
                                      );
                                      final originalTime = _parseTime(
                                        widget.task.deadlineTime,
                                      );
                                      final dateChanged =
                                          selectedDate != null &&
                                          selectedDate != originalDate;
                                      final timeChanged =
                                          selectedTime != null &&
                                          selectedTime != originalTime;

                                      if (newName != originalName ||
                                          dateChanged ||
                                          timeChanged) {
                                        final dateStr = formatDate(
                                          selectedDate ?? originalDate,
                                        );
                                        final timeStr = formatTime(
                                          selectedTime ?? originalTime,
                                        );

                                        await repository.editDeadline(
                                          widget.task.taskId,
                                          newName,
                                          dateStr,
                                          timeStr,
                                        );

                                        widget.task.taskDesctiption = newName;
                                        widget.task.deadlineDate = dateStr;
                                        widget.task.deadlineTime = timeStr;

                                        changed = true;
                                      }
                                    } else if (selectedType == TaskType.quest) {
                                      if (newName != originalName) {
                                        await repository.editQuest(
                                          widget.task.taskId,
                                          newName,
                                        );
                                        changed = true;
                                      }
                                    }
                                  },
                                );

                                // Close regardless; only saved if changed
                                widget.onClose();

                                if (changed) {
                                  debugPrint('Edit saved and dialog closed');
                                } else {
                                  debugPrint('No changes; dialog closed');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
