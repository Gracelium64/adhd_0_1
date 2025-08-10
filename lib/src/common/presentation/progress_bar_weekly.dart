import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class ProgressBarWeekly extends StatelessWidget {
  final DataBaseRepository repository;
  final double progressBarStatus;
  // 0 - 272

  const ProgressBarWeekly({
    super.key,
    required this.progressBarStatus,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    const double canonicalWidth = 272.0; // baseline used to compute fraction
    return Row(
      children: [
        Image.asset(height: 35, width: 35, 'assets/img/sidebar/week.png'),
        const SizedBox(width: 6),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth - 4;
              final double fraction =
                  (progressBarStatus.clamp(0, canonicalWidth)) / canonicalWidth;
              final double fillWidth = barWidth * fraction;
              return Stack(
                children: [
                  Container(
                    width: barWidth,
                    height: 16,
                    decoration: ShapeDecoration(
                      color: Palette.peasantGrey2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                  ),
                  Container(
                    width: fillWidth,
                    height: 16,
                    decoration: ShapeDecoration(
                      color: Palette.neonPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
