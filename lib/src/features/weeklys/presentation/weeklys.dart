import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/weeklys/presentation/widgets/weekly_task_widget.dart';
import 'package:flutter/material.dart';

class Weeklys extends StatefulWidget {
  final DataBaseRepository repository;

  const Weeklys(this.repository, {super.key});

  @override
  State<Weeklys> createState() => _WeeklysState();
}

class _WeeklysState extends State<Weeklys> {
  late Future<List<Task>> myList;

  @override
  void initState() {
    super.initState();
    myList = widget.repository.getWeeklyTasks();
  }

  @override
  Widget build(BuildContext context) {
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
                        taskType: TaskType.weekly,
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
