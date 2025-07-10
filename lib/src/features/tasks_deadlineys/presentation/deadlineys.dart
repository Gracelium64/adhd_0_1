import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_deadlineys/presentation/widgets/deadline_task_widget.dart';
import 'package:flutter/material.dart';

class Deadlineys extends StatefulWidget {
  final DataBaseRepository repository;

  const Deadlineys(this.repository, {super.key});

  @override
  State<Deadlineys> createState() => _DeadlineysState();
}

class _DeadlineysState extends State<Deadlineys> {
  late Future<List<Task>> myList;

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    myList = widget.repository.getDeadlineTasks();
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
                SubTitle(sub: 'Deadlineys'),
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
                            return DeadlineTaskWidget(
                              task: task,
                              repository: widget.repository,
                              onClose: () {
                                debugPrint('dailys onClose triggered');
                                setState(() {
                                  myList = widget.repository.getDeadlineTasks();
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
                        onClose: () {
                          debugPrint('dailys onClose triggered');
                          setState(() {
                            myList = widget.repository.getDeadlineTasks();
                          });
                        },
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
