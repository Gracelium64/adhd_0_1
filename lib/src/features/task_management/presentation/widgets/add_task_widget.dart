import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';


enum TaskType { daily, weekly, deadline, quest }

class AddTaskWidget extends StatefulWidget {
  final DataBaseRepository repository;
  final OverlayPortalController controller;
  final TaskType taskType;

  const AddTaskWidget(
    this.repository,
    this.controller, {
    super.key,
    required this.taskType,
  });

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController userInput;
  Weekday? selectedWeekday;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isButtonEnabled = false;
  late TaskType selectedType;

  Color activeButtonColor = Palette.darkTeal;
  Color passiveButtonColor = Palette.peasantGrey2;

  @override
  void initState() {
    super.initState();
    selectedType = widget.taskType;
    userInput = TextEditingController();
    userInput.addListener(() {
      final isValid = _taskLengthValidator(userInput.text) == null;
      setState(() {
        isButtonEnabled = isValid;
      });
    });
  }

  String? _taskLengthValidator(String? userInput) {
    if (userInput == null || userInput.isEmpty) {
      return 'Every adventure needs a name';
    }
    if (userInput.length >= 30) {
      return 'But not a name that long!';
    }
    return null;
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'DAY';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year % 100;
    return '$d/$m/$y';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return 'HH:MM';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitTask() async {
    final desc = userInput.text;

    if (selectedType == TaskType.daily) {
      await widget.repository.addDaily(desc);
    } else if (selectedType == TaskType.weekly && selectedWeekday != null) {
      await widget.repository.addWeekly(desc, selectedWeekday!);
    } else if (selectedType == TaskType.deadline &&
        selectedDate != null &&
        selectedTime != null) {
      await widget.repository.addDeadline(desc, formatDate(selectedDate), formatTime(selectedTime));
    } else if (selectedType == TaskType.quest) {
      await widget.repository.addQuest(desc);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    widget.controller.toggle(); // Close overlay
  }

  @override
  Widget build(BuildContext context) {
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
                height: 578,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Palette.basicBitchWhite.withAlpha(175), blurRadius: 5, blurStyle: BlurStyle.inner),
                    BoxShadow(color: Palette.basicBitchBlack.withAlpha(125), offset: Offset(4, 4), blurRadius: 5),
                    BoxShadow(color: Palette.monarchPurple1Opacity, blurStyle: BlurStyle.solid),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Task name', style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
                        TextFormField(
                          controller: userInput,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _taskLengthValidator,
                          style: TextStyle(color: Palette.basicBitchWhite),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Palette.monarchPurple2.withAlpha(100),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Palette.basicBitchBlack, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintStyle: TextStyle(color: Palette.basicBitchBlack),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text('Day of the week', style: Theme.of(context).textTheme.displayMedium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Palette.monarchPurple2.withAlpha(100),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Palette.basicBitchBlack),
                              ),
                              child: PopupMenuButton<Weekday>(
                                initialValue: selectedWeekday,
                                onSelected: (value) => setState(() => selectedWeekday = value),
                                color: Palette.monarchPurple2,
                                itemBuilder: (context) => Weekday.values
                                    .map((day) => PopupMenuItem(
                                          value: day,
                                          child: Text(day.label, style: TextStyle(color: Palette.basicBitchWhite)),
                                        ))
                                    .toList(),
                                child: Row(
                                  children: [
                                    Text(
                                      selectedWeekday?.label ?? 'Select Day',
                                      style: TextStyle(color: Palette.basicBitchWhite),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: Palette.basicBitchWhite),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text('Deadline', style: Theme.of(context).textTheme.displayMedium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
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
                              child: Text(formatDate(selectedDate), style: TextStyle(color: Palette.basicBitchWhite)),
                            ),
                            TextButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() => selectedTime = picked);
                                }
                              },
                              child: Text(formatTime(selectedTime), style: TextStyle(color: Palette.basicBitchWhite)),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _taskTypeSelectorRow(TaskType.daily, 'Dailys'),
                        _taskTypeSelectorRow(TaskType.weekly, 'Weeklys'),
                        _taskTypeSelectorRow(TaskType.deadline, 'Deadlineys'),
                        _taskTypeSelectorRow(TaskType.quest, 'Quest'),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CancelButton(onPressed: () => widget.controller.toggle()),
                            ConfirmButton(onPressed: isButtonEnabled ? _submitTask : null),
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

  Widget _taskTypeSelectorRow(TaskType type, String label) {
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 40,
        width: 130,
        decoration: BoxDecoration(
          color: selectedType == type ? activeButtonColor : passiveButtonColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ),
    );
  }
}