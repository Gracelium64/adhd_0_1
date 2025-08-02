import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
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
  OverlayEntry? _overlayEntry;
  void _showAddTaskOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {}, // absorb taps
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                ModalBarrier(dismissible: false),
                Center(
                  child: AddTaskWidget(
                    taskType: TaskType.quest,
                    onClose: _closeAddTaskOverlay,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(milliseconds: 50), () {
      Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    });
  }

  void _closeAddTaskOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      myList = context.read<DataBaseRepository>().getDailyTasks();
    });
  }

  late Future<List<Task>> myList;

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    myList = repository.getQuestTasks();
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FutureBuilder<List<Task>>(
          future: myList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final data = snapshot.data!;

            return Column(
              children: [
                SubTitle(sub: 'Quest'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        height: 492,
                        width: 304,
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final task = data[index];
                            return QuestTaskWidget(
                              task: task,
                              repository: repository,
                              onClose: () {
                                debugPrint('dailys onClose triggered');
                                setState(() {
                                  myList = repository.getQuestTasks();
                                });
                              },
                            );
                          },
                        ),
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
            );
          },
        ),
      ),
    );
  }
}
