import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/edit_task_widget.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class WeeklyTaskWidget extends StatefulWidget {
  final Task task;
  final DataBaseRepository repository;
  final void Function() onClose;

  const WeeklyTaskWidget({
    super.key,
    required this.repository,
    required this.task,
    required this.onClose,
  });

  @override
  State<WeeklyTaskWidget> createState() => _WeeklyTaskWidgetState();
}

class _WeeklyTaskWidgetState extends State<WeeklyTaskWidget> {
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
  void didUpdateWidget(covariant WeeklyTaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with external changes (resets, deletions, reloads)
    if (oldWidget.task.isDone != widget.task.isDone) {
      setState(() {
        isDone = widget.task.isDone;
      });
    }
  }

  void _toggleTask() async {
    final newStatus = !widget.task.isDone;

    await widget.repository.toggleWeekly(widget.task.taskId, newStatus);

    setState(() {
      isDone = newStatus;
      widget.task.isDone = newStatus;
    });

    await refreshWeeklyProgress(widget.repository);
  }

  @override
  Widget build(BuildContext context) {
    final double spreadEm = isDone ? -0.1 : -2;
    final String taskStatus =
        isDone
            ? 'assets/img/buttons/task_done.png'
            : 'assets/img/buttons/task_not_done.png';

    // Normalize dayOfWeek for display: take last segment, lowercase, hide if 'any', capitalize first letter
    final String? displayDay =
        (() {
          final raw = widget.task.dayOfWeek;
          if (raw == null) return null;
          final s = raw.toString();
          final last = s.contains('.') ? s.split('.').last : s;
          final lc = last.toLowerCase();
          if (lc.isEmpty || lc == 'any') return null;
          return lc[0].toUpperCase() + lc.substring(1);
        })();

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
                      taskType: TaskType.weekly,
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
                Expanded(flex: 1, child: SizedBox(width: 100)),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (displayDay != null)
                        Row(
                          spacing: 8,
                          children: [
                            Text(
                              displayDay,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
