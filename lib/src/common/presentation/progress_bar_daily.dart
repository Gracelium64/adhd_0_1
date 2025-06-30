import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class ProgressBarDaily extends StatelessWidget {
  final DataBaseRepository repository;
  final double progressBarStatus;
  // 0 - 272

  const ProgressBarDaily({
    super.key,
    required this.progressBarStatus,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(height: 35, width: 35, 'assets/img/sidebar/daily.png'),
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
                color: Palette.neonGreen,
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
