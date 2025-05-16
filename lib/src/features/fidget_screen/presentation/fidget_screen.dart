import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/os_build.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class FidgetScreen extends StatelessWidget {
  final DataBaseRepository repository;

  const FidgetScreen(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftBuild, topBuild, 0, 0),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SubTitle(sub: 'Fidget Screen'),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 548,
                    width: 304,
                    child: Column(
                      children: [
                        SizedBox(height: 150),
                        Text(
                          'Not available',
                          style: TextStyle(
                            color: Palette.basicBitchWhite,
                            fontFamily: 'Marvel',
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Planned for next update',
                          style: TextStyle(
                            color: Palette.basicBitchWhite,
                            fontFamily: 'Marvel',
                            fontSize: 24,
                          ),
                        ),
                      ],
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
