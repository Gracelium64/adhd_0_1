import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/edit_task_widget.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class QuestTaskWidget extends StatefulWidget {
  final Task task;
  final DataBaseRepository repository;
  final void Function() onClose;

  const QuestTaskWidget({
    super.key,
    required this.task,
    required this.repository,
    required this.onClose,
  });

  @override
  State<QuestTaskWidget> createState() => _QuestTaskWidgetState();
}

class _QuestTaskWidgetState extends State<QuestTaskWidget> {
  late bool isDone;
  bool goodGirl = false;
  double spreadEm = -2;
  String taskStatus = 'assets/img/buttons/task_not_done.png';
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    isDone = widget.task.isDone;
  }

  void _toggleTask() async {
    await showBlockingLoaderDuring(context, () async {
      await widget.repository.completeQuest(widget.task.taskId);
    });

    // Congratulate and animate out
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Great Job!')),
      );
    }
    setState(() {
      isDone = true;
      widget.task.isDone = true;
      goodGirl = true; // trigger glow
      _dismissing = true; // trigger fade-out
    });
    await Future.delayed(const Duration(milliseconds: 666));
    if (mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final double spreadEm = isDone ? -0.1 : -2;
    final String taskStatus =
        isDone
            ? 'assets/img/buttons/task_done.png'
            : 'assets/img/buttons/task_not_done.png';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 666),
      curve: Curves.easeOut,
      opacity: _dismissing ? 0.0 : 1.0,
      child: Row(
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
                  if (goodGirl)
                    BoxShadow(
                      color: Palette.lightTeal.withOpacity(0.8),
                      blurRadius: 18,
                      spreadRadius: 2,
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
                        taskType: TaskType.quest,
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
                  if (goodGirl)
                    BoxShadow(
                      color: Palette.lightTeal.withOpacity(0.6),
                      blurRadius: 18,
                      spreadRadius: 2,
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
          ),
        ],
      ),
    );
  }
}
