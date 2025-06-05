import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/delete_button.dart';
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
  Color activeButtonColor = Palette.darkTeal;
  Color passiveButtonColor = Palette.lightTeal;

  late TaskType selectedType;

  @override
  void initState() {
    super.initState();
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
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task name',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      TextFormField(maxLength: 36),

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
                              style: TextStyle(color: Palette.basicBitchWhite),
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
                              style: TextStyle(color: Palette.basicBitchWhite),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                          DeleteButton(onPressed: () {}),
                          CancelButton(
                            onPressed: () {
                              widget.controller.toggle();
                            },
                          ),
                          ConfirmButton(onPressed: () {}),
                        ],
                      ),
                    ],
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
