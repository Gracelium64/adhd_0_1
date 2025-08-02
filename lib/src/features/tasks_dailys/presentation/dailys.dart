import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/tasks_dailys/presentation/widgets/daily_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dailys extends StatefulWidget {
  const Dailys({super.key});

  @override
  State<Dailys> createState() => _DailysState();
}

class _DailysState extends State<Dailys> {
  void _showAddTaskOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          elevation: 8,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: AddTaskWidget(
            taskType: TaskType.daily,
            onClose: () {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {
                myList = context.read<DataBaseRepository>().getDailyTasks();
              });
              debugPrint(
                'Navigator stack closing from ${Navigator.of(context)}',
              );
            },
          ),
        );
      },
    );
  }

  late Future<List<Task>> myList;

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    myList = repository.getDailyTasks();
    // // OverlayPortalController overlayController = OverlayPortalController();

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
            // else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //   return Text('No data available');
            // }

            final data = snapshot.data!;

            return Column(
              children: [
                SubTitle(sub: 'Dailys'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 492,
                            width: 304,
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final task = data[index];
                                return DailyTaskWidget(
                                  task: task,
                                  repository: repository,
                                  onClose: () {
                                    debugPrint('dailys onClose triggered');
                                    setState(() {
                                      myList = repository.getDailyTasks();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
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
