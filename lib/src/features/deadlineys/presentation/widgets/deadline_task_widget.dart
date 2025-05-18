import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class DeadlineTaskWidget extends StatefulWidget {
  final String taskDesctiption;
  final String? deadlineDate;
  final String? deadlineTime;

  const DeadlineTaskWidget({
    super.key,
    required this.taskDesctiption,
    this.deadlineDate,
    this.deadlineTime,
  });

  @override
  State<DeadlineTaskWidget> createState() => _DeadlineTaskWidgetState();
}

class _DeadlineTaskWidgetState extends State<DeadlineTaskWidget> {
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  widget.taskDesctiption,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(flex: 1, child: SizedBox(width: 8)),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.deadlineDate}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),

                    Text(
                      '${widget.deadlineTime}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    SizedBox(height: 6),
                  ],
                ),
              ),
              SizedBox(width: 0.2),
            ],
          ),
        ),
      ],
    );
  }
}
