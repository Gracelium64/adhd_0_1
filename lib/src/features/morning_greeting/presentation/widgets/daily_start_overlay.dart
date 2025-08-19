import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyStartOverlay extends StatelessWidget {
  final OverlayPortalController controller;
  final DataBaseRepository repository;

  const DailyStartOverlay({
    super.key,
    required this.controller,
    required this.repository,
  });

  Future<double> _compositeProgressFraction() async {
    // Weekly ratio from current weekly tasks
    final weeklyTasks = await repository.getWeeklyTasks();
    final weeklyTotal = weeklyTasks.length;
    final weeklyCompleted = weeklyTasks.where((t) => t.isDone).length;
    final weeklyRatio =
        weeklyTotal == 0 ? 0.0 : (weeklyCompleted / weeklyTotal);

    // Daily average completion across the current week
    final prefs = await SharedPreferences.getInstance();
    final dailyWeekSum = prefs.getDouble('dailyWeekSum') ?? 0.0;
    final dailyWeekCount = prefs.getInt('dailyWeekCount') ?? 0;
    final dailyAvg =
        dailyWeekCount == 0 ? 0.0 : (dailyWeekSum / dailyWeekCount);

    // Composite progress: average of weeklyRatio and dailyAvg
    final composite = (weeklyRatio + dailyAvg) / 2.0;
    return composite.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeHeight =
        media.size.height - media.padding.top - media.padding.bottom - 32;
    final double containerHeight =
        safeHeight < 300 ? 300 : (safeHeight > 350 ? 350 : safeHeight);

    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          width: 320,
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Palette.basicBitchWhite.withAlpha(175),
                offset: const Offset(-0, -0),
                blurRadius: 5,
                blurStyle: BlurStyle.inner,
              ),
              BoxShadow(
                color: Palette.basicBitchBlack.withAlpha(125),
                offset: const Offset(4, 4),
                blurRadius: 5,
              ),
              BoxShadow(
                color: Palette.monarchPurple1Opacity,
                offset: const Offset(0, 0),
                blurRadius: 20,
                blurStyle: BlurStyle.solid,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  height: 96,
                  width: 96,
                  child: Image.asset('assets/img/icons/icon_transparent.png'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Good Morning',
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's your weekly progress so far:",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Composite progress bar (weekly tasks + daily average) — plain white bar, no icon
                FutureBuilder<double>(
                  future: _compositeProgressFraction(),
                  builder: (context, snapshot) {
                    final fraction = (snapshot.data ?? 0.0).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth - 4;
                          final fillWidth = barWidth * fraction;
                          return Stack(
                            children: [
                              Container(
                                width: barWidth,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(64),
                                  borderRadius: BorderRadius.circular(34),
                                ),
                              ),
                              Container(
                                width: fillWidth,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(34),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
                const Spacer(),
                SizedBox(
                  height: 48,
                  width: 64,
                  child: ConfirmButton(
                    onPressed: () => controller.toggle(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
