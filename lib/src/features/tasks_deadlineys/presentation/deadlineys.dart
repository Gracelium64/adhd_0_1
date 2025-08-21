import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/common/presentation/title_gaps.dart';
import 'package:gap/gap.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_deadlineys/presentation/widgets/deadline_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Deadlineys extends StatefulWidget {
  const Deadlineys({super.key});

  @override
  State<Deadlineys> createState() => _DeadlineysState();
}

class _DeadlineysState extends State<Deadlineys> {
  late DataBaseRepository _repository;
  bool _loading = true;
  List<Task> _items = [];
  void _showAddTaskOverlay() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          elevation: 8,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: AddTaskWidget(
            taskType: TaskType.deadline,
            onClose: () async {
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext, rootNavigator: true).pop();
              await _refresh();
              if (!mounted) return;
              debugPrint(
                'Navigator stack closing from ${Navigator.of(context)}',
              );
            },
          ),
        );
      },
    );
  }

  DateTime? _parseDeadline(Task t) {
    final date = t.deadlineDate;
    final time = t.deadlineTime ?? '00:00';
    if (date == null) return null;
    try {
      final parts = date.split('-'); // expect YYYY-MM-DD
      final tparts = time.split(':');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      final hh = int.parse(tparts[0]);
      final mm = int.parse(tparts[1]);
      return DateTime(y, m, d, hh, mm);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    final items = await _repository.getDeadlineTasks();
    final now = DateTime.now();
    items.sort((a, b) {
      final da = _parseDeadline(a);
      final db = _parseDeadline(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      final diffA = da.difference(now).inMilliseconds;
      final diffB = db.difference(now).inMilliseconds;
      return diffA.compareTo(diffB);
    });
    if (!mounted) return;
    setState(() {
      _items = List<Task>.from(items);
      _loading = false;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    _repository = context.read<DataBaseRepository>();
    if (_loading && _items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Column(
                  children: [
                    Gap(subtitleTopGap(context)),
                    SubTitle(sub: 'Deadlineys'),
                    Gap(subtitleBottomGap(context)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 48, 0, 0),
                        child: SizedBox(
                          height: 492,
                          width: MediaQuery.of(context).size.width - 85,
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final task = _items[index];
                              return DeadlineTaskWidget(
                                task: task,
                                repository: _repository,
                                onClose: () async {
                                  debugPrint('deadline onClose triggered');
                                  await _refresh();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddTaskOverlay,
                      child: AddTaskButton(),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
      ),
    );
  }
}
