import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/os_build.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/dailys/presentation/widgets/daily_task_widget.dart';
import 'package:flutter/material.dart';

class Dailys extends StatelessWidget {
  final DataBaseRepository repository;
  
  const Dailys(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftBuild, topBuild, 0, 0),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SubTitle(sub: 'Dailys'),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 548,
                    width: 304,
                    child: Column(children: [DailyTaskWidget(repository), Placeholder()]),
                    /////  ^^^^^^ ListView comes here
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
