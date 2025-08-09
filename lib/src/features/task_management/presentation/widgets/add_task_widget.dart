import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum TaskType { daily, weekly, deadline, quest }

class AddTaskWidget extends StatefulWidget {
  // // final OverlayPortalController controller;

  final TaskType taskType;
  final void Function() onClose;

  const AddTaskWidget(
  // // this.controller,
  {super.key, required this.taskType, required this.onClose});

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
  Color passiveButtonColor = Palette.lightTeal;

  late TaskType selectedType;

  @override
  void initState() {
    super.initState();
    userInput = TextEditingController(text: '');
    selectedType = widget.taskType;
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    final isWeekly = selectedType == TaskType.weekly;
    final isDeadline = selectedType == TaskType.deadline;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Center(
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
                                          selectedWeekday != null
                                              ? selectedWeekday!.label[0]
                                                      .toUpperCase() +
                                                  selectedWeekday!.label
                                                      .substring(1)
                                              : 'Select Day',
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
                                  setState(() {
                                    selectedType = TaskType.daily;
                                  });
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
                                setState(() {
                                  selectedType = TaskType.weekly;
                                });
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
                                setState(() {
                                  selectedType = TaskType.deadline;
                                });
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
                                setState(() {
                                  selectedType = TaskType.quest;
                                });
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
                            CancelButton(
                              onPressed: () {
                                widget.onClose();
                              },
                            ),
                            ConfirmButton(
                              onPressed:
                                  isButtonEnabled
                                      ? () {}
                                      : () async {
                                        if (selectedType == TaskType.daily) {
                                          await repository.addDaily(
                                            userInput.text,
                                          );
                                          await refreshDailyProgress(
                                            repository,
                                          );
                                          widget.onClose();
                                          debugPrint(
                                            'add task daily widget onClose',
                                          );
                                        } else if (selectedType ==
                                                TaskType.weekly &&
                                            selectedWeekday != null) {
                                          await repository.addWeekly(
                                            userInput.text,
                                            selectedWeekday,
                                          );
                                          await refreshWeeklyProgress(
                                            repository,
                                          );
                                          widget.onClose();
                                          debugPrint(
                                            'add task weekly widget onClose',
                                          );
                                        } else if (selectedType ==
                                                TaskType.deadline &&
                                            selectedDate != null &&
                                            selectedTime != null) {
                                          final dateStr = formatDate(
                                            selectedDate,
                                          );
                                          final timeStr = formatTime(
                                            selectedTime,
                                          );

                                          await repository.addDeadline(
                                            userInput.text,
                                            dateStr,
                                            timeStr,
                                          );
                                          widget.onClose();
                                          debugPrint(
                                            'add task deadline widget onClose',
                                          );
                                        } else if (selectedType ==
                                            TaskType.quest) {
                                          await repository.addQuest(
                                            userInput.text,
                                          );
                                          widget.onClose();
                                          debugPrint('add task quest onClose');
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please complete all required fields',
                                                style:
                                                    Theme.of(context)
                                                        .snackBarTheme
                                                        .contentTextStyle,
                                              ),
                                            ),
                                          );
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

  @override
  void dispose() {
    debugPrint('AddTaskWidget disposed properly');
    userInput.dispose();
    super.dispose();
  }
}
