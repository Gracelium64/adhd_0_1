import 'package:adhd_0_1/src/common/add_task_button.dart';
import 'package:adhd_0_1/os_build.dart';
import 'package:adhd_0_1/src/common/sub_title.dart';
import 'package:adhd_0_1/src/features/Deadlineys/presentation/widgets/deadline_task_widget.dart';
import 'package:flutter/material.dart';

class Deadlineys extends StatelessWidget {
  const Deadlineys({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftBuild, topBuild, 0, 0),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SubTitle(sub: 'Deadlineys'),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 548,
                    width: 304,
                    child: Column(
                      children: [DeadlineTaskWidget(), Placeholder()],
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
