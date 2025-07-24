import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';

class WeeklySummaryOverlay extends StatelessWidget {
  final List<Prizes> prizes;
  final VoidCallback onClose;

  const WeeklySummaryOverlay({
    super.key,
    required this.prizes,
    required this.onClose,
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
                borderRadius: BorderRadius.circular(25),
                color: Palette.peasantGrey1Opacity,
                boxShadow: [
                  BoxShadow(
                    color: Palette.basicBitchBlack.withAlpha(100),
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    'Weekly Summary',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Daily Completion: ${data['dailyRatio']}%'),
                  Text('Weekly Completion: ${data['weeklyRatio']}%'),
                  if (data['questCompleted'] > 0)
                    Text('Quests Completed: ${data['questCompleted']}'),
                  if (data['deadlineCompleted'] > 0)
                    Text('Deadlines Completed: ${data['deadlineCompleted']}'),
                  const SizedBox(height: 16),
                  const Text('🎁 Prizes Received:'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: prizes
                          .map((prize) => Image.asset(prize.prizeUrl))
                          .toList(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 36),
                    onPressed: onClose,
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