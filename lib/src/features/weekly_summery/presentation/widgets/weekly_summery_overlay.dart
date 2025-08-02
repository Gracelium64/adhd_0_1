import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';

class WeeklySummaryOverlay extends StatelessWidget {
  final List<Prizes> prizes;
  final OverlayPortalController controller;

  const WeeklySummaryOverlay({
    super.key,
    required this.prizes,
    required this.controller,
  });

  Future<Map<String, dynamic>> _fetchSummaryData() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyCompleted = prefs.getInt('dailyCompleted') ?? 0;
    final dailyTotal = prefs.getInt('dailyTotal') ?? 1;
    final weeklyCompleted = prefs.getInt('weeklyCompleted') ?? 0;
    final weeklyTotal = prefs.getInt('weeklyTotal') ?? 1;
    final questCompleted = prefs.getInt('questCompleted') ?? 0;
    final deadlineCompleted = prefs.getInt('deadlineCompleted') ?? 0;

    return {
      'dailyRatio': (dailyCompleted / dailyTotal * 100).round(),
      'weeklyRatio': (weeklyCompleted / weeklyTotal * 100).round(),
      'questCompleted': questCompleted,
      'deadlineCompleted': deadlineCompleted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchSummaryData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final data = snapshot.data!;
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              width: 300,
              height: 560,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Palette.basicBitchWhite.withAlpha(175),
                    offset: Offset(-0, -0),
                    blurRadius: 5,
                    blurStyle: BlurStyle.inner,
                  ),
                  BoxShadow(
                    color: Palette.basicBitchBlack.withAlpha(125),
                    offset: Offset(4, 4),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: Palette.monarchPurple1Opacity,
                    offset: Offset(0, 0),
                    blurRadius: 20,
                    blurStyle: BlurStyle.solid,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Weekly Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text('Daily Completion: ${data['dailyRatio']}%'),
                  Text('Weekly Completion: ${data['weeklyRatio']}%'),
                  if (data['questCompleted'] > 0)
                    Text('Quests Completed: ${data['questCompleted']}'),
                  if (data['deadlineCompleted'] > 0)
                    Text('Deadlines Completed: ${data['deadlineCompleted']}'),
                  SizedBox(height: 16),
                  Text("For this you're earned:"),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children:
                          prizes
                              .map((prize) => Image.asset(prize.prizeUrl))
                              .toList(),
                    ),
                  ),
                  ConfirmButton(
                    onPressed: () {
                      controller.toggle();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
