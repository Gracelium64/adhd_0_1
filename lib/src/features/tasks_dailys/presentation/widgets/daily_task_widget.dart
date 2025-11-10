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
  late Task _task;
  late bool isDone;
  bool goodGirl = false;
  double spreadEm = -2;
  String taskStatus = 'assets/img/buttons/task_not_done.png';

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    isDone = _task.isDone;
  }

  @override
  void didUpdateWidget(covariant DailyTaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with external changes (e.g., daily reset or data reload)
    _task = widget.task;
    if (oldWidget.task.isDone != _task.isDone) {
      setState(() {
        isDone = _task.isDone;
      });
    }
  }

  void _toggleTask() async {
    final newStatus = !_task.isDone;

    if (newStatus && _task.subTasks.any((sub) => !sub.isDone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish all subtasks before completing.')),
      );
      return;
    }

    try {
      await widget.repository.toggleDaily(_task.taskId, newStatus);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update task: $e',
            style: Theme.of(context).snackBarTheme.contentTextStyle,
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      isDone = newStatus;
      _task.isDone = newStatus;
      if (!newStatus) {
        for (final sub in _task.subTasks) {
          sub.isDone = false;
        }
      }
    });

    await refreshDailyProgress(widget.repository);
  }

  Future<void> _toggleSubTask(SubTask subTask) async {
    final updated = await widget.repository.toggleSubTask(
      _task,
      subTask.subTaskId,
      !subTask.isDone,
    );
    setState(() {
      _task.isDone = updated.isDone;
      isDone = updated.isDone;
      _task.subTasks
        ..clear()
        ..addAll(updated.subTasks);
    });
    await refreshDailyProgress(widget.repository);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                          _task.taskDesctiption,
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
        ),
        if (_task.subTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 46 + 16.0, top: 8, right: 12),
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
        SizedBox(height: 12),
      ],
    );
  }
}
