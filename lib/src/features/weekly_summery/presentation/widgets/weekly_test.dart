import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/theme/app_theme.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      home: Scaffold(
        backgroundColor: Colors.grey,
        body: WeeklySummaryOverlayMock(),
      ),
    ),
  );
}

class WeeklySummaryOverlayMock extends StatelessWidget {
  const WeeklySummaryOverlayMock({super.key});

  @override
  Widget build(BuildContext context) {
    final mockPrizes = [
      'assets/img/prizes/Sticker15.png',
      'assets/img/prizes/Sticker16.png',
      'assets/img/prizes/Sticker17.png',
      'assets/img/prizes/Sticker17.png',
    ];

    final mockData = {
      'dailyRatio': 83,
      'weeklyRatio': 75,
      'questCompleted': 2,
      'deadlineCompleted': 1,
    };

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
              Text('Daily Completion: ${mockData['dailyRatio']}%'),
              Text('Weekly Completion: ${mockData['weeklyRatio']}%'),
              if (mockData['questCompleted']! > 0)
                Text('Quests Completed: ${mockData['questCompleted']}'),
              if (mockData['deadlineCompleted']! > 0)
                Text('Deadlines Completed: ${mockData['deadlineCompleted']}'),
              SizedBox(height: 16),
              Text("For this you're earned:"),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children:
                      mockPrizes
                          .map((url) => Image.asset(url, fit: BoxFit.cover))
                          .toList(),
                ),
              ),
              ConfirmButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
