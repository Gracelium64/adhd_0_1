import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/dailys/presentation/widgets/daily_task_widget.dart';
import 'package:flutter/material.dart';
// import 'dart:io' show Platform;

class Dailys extends StatelessWidget {
  final DataBaseRepository repository;

  const Dailys(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
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
                        itemCount: repository.getDailyTasks().length,
                        itemBuilder: (context, index) {
                          final task = repository.getDailyTasks()[index];
                          return DailyTaskWidget(
                            taskDesctiption: task.taskDesctiption,
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
            onTap: () {
              overlayController.toggle();
            },
            child: OverlayPortal(
              controller: overlayController,
              overlayChildBuilder: (BuildContext context) {
                return AddTaskWidget(
                  repository,
                  overlayController,
                  taskType: TaskType.daily,
                );
              },
              child: AddTaskButton(),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
