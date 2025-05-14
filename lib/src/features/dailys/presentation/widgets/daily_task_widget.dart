import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class DailyTaskWidget extends StatefulWidget {
  const DailyTaskWidget({super.key});

  @override
  State<DailyTaskWidget> createState() => _DailyTaskWidgetState();
}

class _DailyTaskWidgetState extends State<DailyTaskWidget> {
  bool goodGirl = false;
  double spreadEm = -2;
  String taskStatus = 'assets/img/buttons/task_not_done.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              goodGirl = !goodGirl;
              if (!goodGirl) {
                spreadEm = -2;
                taskStatus = 'assets/img/buttons/task_not_done.png';
              } else if (goodGirl) {
                spreadEm = -0.1;
                taskStatus = 'assets/img/buttons/task_done.png';
              }
            });
          },
          child: Container(
            width: 46,
            height: 60,
            decoration: ShapeDecoration(
              shadows: [
                BoxShadow(color: Palette.boxShadow1),
                BoxShadow(
                  color: Palette.monarchPurple2,
                  blurRadius: 11.8,
                  spreadRadius: spreadEm,
                  blurStyle: BlurStyle.inner,
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
              ),
            ),
            child: Image.asset(taskStatus),
          ),
        ),
        SizedBox(width: 1),
        Container(
          width: 257,
          height: 60,
          decoration: ShapeDecoration(
            shadows: [
              BoxShadow(color: Palette.boxShadow1),
              BoxShadow(
                color: Palette.monarchPurple2,
                blurRadius: 11.8,
                spreadRadius: -0.1,
                blurStyle: BlurStyle.inner,
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Daily task',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Palette.basicBitchWhite,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
