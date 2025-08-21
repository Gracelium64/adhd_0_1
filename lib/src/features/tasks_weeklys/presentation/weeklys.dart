import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/common/presentation/title_gaps.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_weeklys/presentation/widgets/weekly_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:adhd_0_1/src/common/domain/refresh_bus.dart';

class Weeklys extends StatefulWidget {
  const Weeklys({super.key});

  @override
  State<Weeklys> createState() => _WeeklysState();
}

class _WeeklysState extends State<Weeklys> {
  late DataBaseRepository _repository;
  bool _loading = true;
  List<Task> _items = [];
  Weekday _startOfWeek = Weekday.mon;
  bool _settingsLoaded = false;
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
            taskType: TaskType.weekly,
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

  int _weekdayRank(String? day) {
    final d = (day ?? 'any').toLowerCase();
    if (d == 'any') return 8;
    // Build rotation starting at startOfWeek
    final order = [
      Weekday.mon,
      Weekday.tue,
      Weekday.wed,
      Weekday.thu,
      Weekday.fri,
      Weekday.sat,
      Weekday.sun,
    ];
    final startIndex = order.indexOf(_startOfWeek);
    final rotated = [
      ...order.sublist(startIndex),
      ...order.sublist(0, startIndex),
    ];
    final idx = rotated.indexWhere((w) => w.name == d);
    return (idx == -1) ? 8 : (idx + 1);
  }

  Future<void> _refresh() async {
    if (!_settingsLoaded) {
      final settings = await _repository.getSettings();
      if (settings != null) {
        _startOfWeek = settings.startOfWeek;
      }
      _settingsLoaded = true;
    }
    final items = await _repository.getWeeklyTasks();
    items.sort((a, b) {
      final ra = _weekdayRank(a.dayOfWeek);
      final rb = _weekdayRank(b.dayOfWeek);
      if (ra != rb) return ra.compareTo(rb);
      if (ra == 8) {
        final ai = a.orderIndex ?? 1 << 30;
        final bi = b.orderIndex ?? 1 << 30;
        return ai.compareTo(bi);
      }
      return 0; // keep relative order otherwise
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
    final tick = context.watch<RefreshBus>().tick;
    if (tick != _refreshTick) {
      _refreshTick = tick;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
    if (_loading && _items.isEmpty) {
      // first build
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
    // OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Column(
                  children: [
                    Gap(subtitleTopGap(context)),
                    SubTitle(sub: 'Weeklys'),
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
                              bool changed = false;
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final moving = _items[oldIndex];
                                final isAny =
                                    (moving.dayOfWeek == null) ||
                                    (moving.dayOfWeek!.toLowerCase() == 'any');
                                // Only allow reordering freely for 'any' items
                                if (!isAny) return;
                                _items.removeAt(oldIndex);
                                _items.insert(newIndex, moving);
                                changed = true;
                              });
                              if (changed) {
                                final anyIds =
                                    _items
                                        .where(
                                          (t) =>
                                              (t.dayOfWeek == null) ||
                                              (t.dayOfWeek!.toLowerCase() ==
                                                  'any'),
                                        )
                                        .map((e) => e.taskId)
                                        .toList();
                                await _repository.saveWeeklyAnyOrder(anyIds);
                              }
                            },
                            buildDefaultDragHandles: true,
                            itemBuilder: (context, index) {
                              final task = _items[index];
                              return Container(
                                key: ValueKey(task.taskId),
                                child: WeeklyTaskWidget(
                                  repository: _repository,
                                  task: task,
                                  onClose: () async {
                                    debugPrint('weekly onClose triggered');
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
