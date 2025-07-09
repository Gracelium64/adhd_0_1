import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_weeklys/presentation/widgets/weekly_task_widget.dart';
import 'package:flutter/material.dart';

class Weeklys extends StatefulWidget {
  final Task task;
  final DataBaseRepository repository;
  final void Function() onClose;

  const Weeklys(this.repository, {super.key, required this.task, required this.onClose});

  @override
  State<Weeklys> createState() => _WeeklysState();
}

class _WeeklysState extends State<Weeklys> {
  late Future<List<Task>> myList;

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    myList = widget.repository.getWeeklyTasks();
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
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No data available');
            }

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
                              repository: widget.repository,
                              task: task,
                              onClose: () {
                                    debugPrint('dailys onClose triggered');
                                    setState(() {
                                      myList =
                                          widget.repository.getDailyTasks();
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
                  onTap: () {
                    overlayController.toggle();
                  },
                  child: OverlayPortal(
                    controller: overlayController,
                    overlayChildBuilder: (BuildContext context) {
                      return AddTaskWidget(
                    widget.repository,
                    overlayController,
                    taskType: TaskType.daily,
                    task: widget.task,
                    onClose: () {},
                  );
                    },
                    child: AddTaskButton(),
                  ),
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
