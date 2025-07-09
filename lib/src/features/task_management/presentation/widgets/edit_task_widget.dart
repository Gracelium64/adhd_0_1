import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/delete_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

enum TaskType { daily, weekly, deadline, quest }

class EditTaskWidget extends StatefulWidget {
  final DataBaseRepository repository;
  final OverlayPortalController controller;
  final Task task;
  final TaskType taskType;
  final void Function() onClose;

  const EditTaskWidget(
    this.repository,
    this.controller, {
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
    userInput = TextEditingController(text: widget.task.taskDesctiption);
    selectedType = widget.taskType;
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
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('Click here'),
                            ),
                            ////// TODO: DayPick Overlay
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
                            TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: Palette.basicBitchWhite,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                'DAY',
                                style: TextStyle(
                                  color: Palette.basicBitchWhite,
                                ),
                              ),
                            ),

                            ////// TODO: replace textbutton with DropdownMenu
                            TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: Palette.basicBitchWhite,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                'HH:MM',
                                style: TextStyle(
                                  color: Palette.basicBitchWhite,
                                ),
                              ),
                            ),
                            ////// TODO: replace textbutton with TimeInput
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            GestureDetector(
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
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
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
                            DeleteButton(
                              onPressed: () {
                                if (selectedType == TaskType.daily) {
                                  widget.repository.deleteDaily(
                                    widget.task.taskId,
                                  );
                                  widget.controller.toggle();
                                  setState(() {
                                    debugPrint(
                                      'delete daily task widget onClose',
                                    );
                                    widget.onClose();
                                  });
                                }
                                if (selectedType == TaskType.weekly) {
                                  widget.repository.deleteWeekly(
                                    widget.task.taskId,
                                  );
                                  widget.controller.toggle();
                                  setState(() {
                                    debugPrint(
                                      'delete daily task widget onClose',
                                    );
                                    widget.onClose();
                                  });
                                }
                                if (selectedType == TaskType.deadline) {
                                  widget.repository.deleteDeadline(
                                    widget.task.taskId,
                                  );
                                  widget.controller.toggle();
                                  setState(() {
                                    debugPrint(
                                      'delete daily task widget onClose',
                                    );
                                    widget.onClose();
                                  });
                                }
                                if (selectedType == TaskType.quest) {
                                  widget.repository.deleteQuest(
                                    widget.task.taskId,
                                  );
                                  widget.controller.toggle();
                                  setState(() {
                                    debugPrint(
                                      'delete daily task widget onClose',
                                    );
                                    widget.onClose();
                                  });
                                }
                              },
                            ),
                            CancelButton(
                              onPressed: () {
                                widget.controller.toggle();
                              },
                            ),
                            ConfirmButton(
                              onPressed:
                                  isButtonEnabled
                                      ? () {}
                                      : () {
                                        if (selectedType == TaskType.daily) {
                                          widget.repository.editDaily(
                                            widget.task.taskId,
                                            userInput.text,
                                          );
                                          widget.controller.toggle();
                                          setState(() {
                                            debugPrint(
                                              'edit task widget onClose',
                                            );
                                            widget.onClose();
                                          });
                                        }
                                        // if (selectedType == TaskType.weekly) {
                                        //   widget.repository.editWeekly(widget.task.taskId, data, day);
                                        // }
                                        // if (selectedType == TaskType.deadline) {
                                        //   widget.repository.editDeadline(widget.task.taskId, data, date, time);
                                        // }
                                        // if (selectedType == TaskType.quest) {
                                        //   widget.repository.editQuest(widget.task.taskId, userInput.text);
                                        // }
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
