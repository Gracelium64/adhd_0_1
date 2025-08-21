import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/common/presentation/title_gaps.dart';
import 'package:gap/gap.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_quest/presentation/widgets/quest_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Quest extends StatefulWidget {
  const Quest({super.key});

  @override
  State<Quest> createState() => _QuestState();
}

class _QuestState extends State<Quest> {
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
            taskType: TaskType.quest,
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
    final items = await _repository.getQuestTasks();
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
                    SubTitle(sub: 'Quest'),
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
                              final ids = _items.map((e) => e.taskId).toList();
                              await _repository.saveQuestOrder(ids);
                            },
                            buildDefaultDragHandles: true,
                            itemBuilder: (context, index) {
                              final task = _items[index];
                              return Container(
                                key: ValueKey(task.taskId),
                                child: QuestTaskWidget(
                                  task: task,
                                  repository: _repository,
                                  onClose: () async {
                                    debugPrint('quest onClose triggered');
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
