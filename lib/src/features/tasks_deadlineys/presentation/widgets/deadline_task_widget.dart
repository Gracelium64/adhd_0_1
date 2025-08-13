import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/edit_task_widget.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class DeadlineTaskWidget extends StatefulWidget {
  final Task task;
  final DataBaseRepository repository;
  final void Function() onClose;

  const DeadlineTaskWidget({
    super.key,
    required this.task,
    required this.repository,
    required this.onClose,
  });

  @override
  State<DeadlineTaskWidget> createState() => _DeadlineTaskWidgetState();
}

class _DeadlineTaskWidgetState extends State<DeadlineTaskWidget> {
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
    await widget.repository.completeDeadline(widget.task.taskId);
    widget.task.isDone = true;
    widget.onClose();
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
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(16),
                    child: EditTaskWidget(
                      task: widget.task,
                      taskType: TaskType.deadline,
                      onClose: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        widget.onClose();
                      },
                    ),
                  ),
            );
          },
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.task.taskDesctiption,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(flex: 1, child: SizedBox(width: 8)),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.task.deadlineDate}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),

                      Text(
                        '${widget.task.deadlineTime}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                ),
                SizedBox(width: 0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
