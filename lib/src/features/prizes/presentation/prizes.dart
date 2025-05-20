import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prizes_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class Prizes extends StatelessWidget {
  final DataBaseRepository repository;

  const Prizes(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    double? leftBuild;
    double? topBuild;
    OverlayPortalController overlayController = OverlayPortalController();

    if (Platform.isAndroid) {
      leftBuild = 4.toDouble(); // Android
      topBuild = 10.toDouble(); // Android
    } else if (Platform.isIOS) {
      leftBuild = 0.toDouble(); // iPhone
      topBuild = 0.toDouble(); // iPhone
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(leftBuild ?? 0, topBuild ?? 0, 0, 0),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
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
                          child: PrizesWidget(repository),
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
      ),
    );
  }
}
