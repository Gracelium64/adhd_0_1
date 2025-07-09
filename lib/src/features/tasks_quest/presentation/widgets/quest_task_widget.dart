import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class QuestTaskWidget extends StatefulWidget {
  final Task task;
  final DataBaseRepository repository;
  final VoidCallback onDelete;

  const QuestTaskWidget({
    super.key,
    required this.task,
    required this.repository,
    required this.onDelete,
  });

  @override
  State<QuestTaskWidget> createState() => _QuestTaskWidgetState();
}

class _QuestTaskWidgetState extends State<QuestTaskWidget> {
  late bool isDone;
  bool goodGirl = false;
  double spreadEm = -2;
  String taskStatus = 'assets/img/buttons/task_not_done.png';

  @override
  void initState() {
    super.initState();
    isDone = widget.task.isDone;
  }

  void _toggleTask() async {
    final newStatus = !widget.task.isDone;

    await widget.repository.completeQuest(widget.task.taskId);
    widget.onDelete();

    setState(() {
      isDone = newStatus;
      widget.task.isDone = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double spreadEm = isDone ? -0.1 : -2;
    final String taskStatus =
        isDone
            ? 'assets/img/buttons/task_done.png'
            : 'assets/img/buttons/task_not_done.png';

    return Row(
      children: [
        GestureDetector(
          onTap: _toggleTask,
          child: Container(
            width: 46,
            height: 60,
            decoration: ShapeDecoration(
              shadows: [
                BoxShadow(color: Palette.boxShadow1),
                BoxShadow(
                  color: Palette.monarchPurple2,
                  blurRadius: 11.8,
                  spreadRadius: spreadEm,
                  blurStyle: BlurStyle.inner,
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
              ),
            ),
            child: Image.asset(taskStatus),
          ),
        ),
        SizedBox(width: 1),
        Container(
          width: 257,
          height: 60,
          decoration: ShapeDecoration(
            shadows: [
              BoxShadow(color: Palette.boxShadow1),
              BoxShadow(
                color: Palette.monarchPurple2,
                blurRadius: 11.8,
                spreadRadius: -0.1,
                blurStyle: BlurStyle.inner,
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 8),
              Text(
                widget.task.taskDesctiption,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
