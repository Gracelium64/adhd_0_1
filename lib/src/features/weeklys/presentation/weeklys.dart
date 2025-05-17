import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/weeklys/presentation/widgets/weekly_task_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class Weeklys extends StatelessWidget {
  final DataBaseRepository repository;
  
  const Weeklys(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    double? leftBuild;
    double? topBuild;

    if (Platform.isAndroid) {
      leftBuild = 4.toDouble(); // Android
      topBuild = 10.toDouble(); // Android
    } else if (Platform.isIOS) {
      leftBuild = 0.toDouble(); // iPhone
      topBuild = 0.toDouble(); // iPhone
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(leftBuild!, topBuild!, 0, 0),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SubTitle(sub: 'Weeklys'),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 548,
                    width: 304,
                    child: Column(
                      children: [WeeklyTaskWidget(repository), Placeholder()],
                      /////  ^^^^^^ ListView comes here
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(onTap: () {}, child: AddTaskButton()),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
