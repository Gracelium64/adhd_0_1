import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prizes_widget.dart';
import 'package:flutter/material.dart';

class Prizes extends StatefulWidget {
  final Task task;
  final DataBaseRepository repository;
  final void Function() onClose;

  const Prizes(
    this.repository, {
    super.key,
    required this.task,
    required this.onClose,
  });

  @override
  State<Prizes> createState() => _PrizesState();
}

class _PrizesState extends State<Prizes> {
  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            SubTitle(sub: 'Prizes'),
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
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: PrizesWidget(widget.repository),
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
        ),
      ),
    );
  }
}
