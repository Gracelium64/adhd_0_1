import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class ProgressBarWeekly extends StatelessWidget {
  final double progressBarStatus;
  // 0 - 272

  const ProgressBarWeekly({super.key, required this.progressBarStatus});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(height: 35, width: 35, 'assets/img/sidebar/week.png'),
        Stack(
          children: [
            Container(
              width: 272,
              height: 16,
              decoration: ShapeDecoration(
                color: Palette.peasantGrey2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
            ),
            Container(
              width: progressBarStatus,
              height: 16,
              decoration: ShapeDecoration(
                color: Palette.neonPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
