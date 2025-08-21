import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/common/presentation/title_gaps.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_dailys/presentation/widgets/daily_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/common/domain/refresh_bus.dart';

class Dailys extends StatefulWidget {
  const Dailys({super.key});

  @override
  State<Dailys> createState() => _DailysState();
}

class _DailysState extends State<Dailys> {
  late DataBaseRepository _repository;
  bool _loading = true;
  List<Task> _items = [];
  int _refreshTick = 0;

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
            taskType: TaskType.daily,
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

  Future<void> _refresh() async {
    final items = await _repository.getDailyTasks();
    if (!mounted) return;
    setState(() {
      _items = List<Task>.from(items);
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _repository = context.read<DataBaseRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;
    final tick = context.watch<RefreshBus>().tick;
    if (tick != _refreshTick) {
      _refreshTick = tick;
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
                    SubTitle(sub: 'Dailys'),
                    Gap(subtitleBottomGap(context)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 48, 0, 0),
                        child: SizedBox(
                          height: 492,
                          width: MediaQuery.of(context).size.width - 85,
                          child: ReorderableListView.builder(
                            itemCount: _items.length,
                            onReorder: (oldIndex, newIndex) async {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final item = _items.removeAt(oldIndex);
                                _items.insert(newIndex, item);
                              });
                              // persist order
                              final ids = _items.map((e) => e.taskId).toList();
                              await repository.saveDailyOrder(ids);
                            },
                            buildDefaultDragHandles: true,
                            itemBuilder: (context, index) {
                              final task = _items[index];
                              return Container(
                                key: ValueKey(task.taskId),
                                child: DailyTaskWidget(
                                  task: task,
                                  repository: repository,
                                  onClose: () async {
                                    debugPrint('dailys onClose triggered');
                                    await _refresh();
                                  },
                                ),
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
