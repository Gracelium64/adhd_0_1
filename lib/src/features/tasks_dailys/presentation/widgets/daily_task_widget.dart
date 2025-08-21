import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/edit_task_widget.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class DailyTaskWidget extends StatefulWidget {
  final Task task;
  final DataBaseRepository repository;
  final void Function() onClose;

  const DailyTaskWidget({
    super.key,
    required this.task,
    required this.repository,
    required this.onClose,
  });

  @override
  State<DailyTaskWidget> createState() => _DailyTaskWidgetState();
}

class _DailyTaskWidgetState extends State<DailyTaskWidget> {
  late bool isDone;
  bool goodGirl = false;
  double spreadEm = -2;
  String taskStatus = 'assets/img/buttons/task_not_done.png';

  @override
  void initState() {
    super.initState();
    isDone = widget.task.isDone;
  }

  @override
  void didUpdateWidget(covariant DailyTaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with external changes (e.g., daily reset or data reload)
    if (oldWidget.task.isDone != widget.task.isDone) {
      setState(() {
        isDone = widget.task.isDone;
      });
    }
  }

  void _toggleTask() async {
    final newStatus = !widget.task.isDone;

    await widget.repository.toggleDaily(widget.task.taskId, newStatus);

    setState(() {
      isDone = newStatus;
      widget.task.isDone = newStatus;
    });

    await refreshDailyProgress(widget.repository);
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
        Expanded(
          child: GestureDetector(
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
                        taskType: TaskType.daily,
                        onClose: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          widget.onClose();
                        },
                      ),
                    ),
              );
            },
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 60,
              ),
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
                  Expanded(
                    child: Text(
                      widget.task.taskDesctiption,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
