import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/edit_task_widget.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
  late Task _task;
  late bool isDone;
  bool goodGirl = false;
  double spreadEm = -2;
  String taskStatus = 'assets/img/buttons/task_not_done.png';
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    isDone = _task.isDone;
  }

  void _toggleTask() async {
    if (_task.subTasks.any((sub) => !sub.isDone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish all subtasks before completing.')),
      );
      return;
    }

    try {
      await showBlockingLoaderDuring(context, () async {
        await widget.repository.completeDeadline(_task.taskId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not complete task: $e',
            style: Theme.of(context).snackBarTheme.contentTextStyle,
          ),
        ),
      );
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Great Job!')),
      );
    }
    setState(() {
      isDone = true;
      _task.isDone = true;
      goodGirl = true;
      _dismissing = true;
    });
    await Future.delayed(const Duration(milliseconds: 666));
    if (mounted) widget.onClose();
  }

  Future<void> _toggleSubTask(SubTask subTask) async {
    final updated = await widget.repository.toggleSubTask(
      _task,
      subTask.subTaskId,
      !subTask.isDone,
    );
    if (!mounted) return;
    setState(() {
      _task.subTasks
        ..clear()
        ..addAll(updated.subTasks);
      _task.isDone = updated.isDone;
    });
  }

  Widget _buildSubTaskTile(SubTask subTask) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleSubTask(subTask),
        child: Row(
          children: [
            Checkbox(
              value: subTask.isDone,
              onChanged: (_) => _toggleSubTask(subTask),
              activeColor: Palette.lightTeal,
            ),
            Expanded(
              child: Text(
                subTask.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  decoration:
                      subTask.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left toggle button
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
                          color: Palette.lightTeal.withAlpha(204),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                    ],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                  child: Image.asset(taskStatus),
                ),
              ),
              const SizedBox(width: 1),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(16),
                            child: EditTaskWidget(
                              task: widget.task,
                              taskType: TaskType.deadline,
                              onClose: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                widget.onClose();
                              },
                            ),
                          ),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 60),
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
                            color: Palette.lightTeal.withAlpha(153),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                      ],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _task.taskDesctiption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${_task.deadlineTime}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                '${_task.deadlineDate}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Gap(8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_task.subTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 62.0, top: 8, right: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Palette.monarchPurple2.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: _task.subTasks.map(_buildSubTaskTile).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
