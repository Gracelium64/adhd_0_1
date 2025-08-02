import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_weeklys/presentation/widgets/weekly_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Weeklys extends StatefulWidget {
  const Weeklys({super.key});

  @override
  State<Weeklys> createState() => _WeeklysState();
}

class _WeeklysState extends State<Weeklys> {
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
                    taskType: TaskType.weekly,
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

    myList = repository.getWeeklyTasks();
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
              return Text(('Error: ${snapshot.error}'));
            }
            //  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //   return Text('No data available');
            // }

            final data = snapshot.data!;

            return Column(
              children: [
                SubTitle(sub: 'Weeklys'),

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
                            return WeeklyTaskWidget(
                              repository: repository,
                              task: task,
                              onClose: () {
                                debugPrint('dailys onClose triggered');
                                setState(() {
                                  myList = repository.getWeeklyTasks();
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
