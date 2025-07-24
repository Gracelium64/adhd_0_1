import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
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
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(4, 4),
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
              Text('Daily Completion: ${mockData['dailyRatio']}%'),
              Text('Weekly Completion: ${mockData['weeklyRatio']}%'),
              if (mockData['questCompleted']! > 0)
                Text('Quests Completed: ${mockData['questCompleted']}'),
              if (mockData['deadlineCompleted']! > 0)
                Text('Deadlines Completed: ${mockData['deadlineCompleted']}'),
              const SizedBox(height: 16),
              const Text('🎁 Prizes Received:'),
              const SizedBox(height: 8),
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
              IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 36),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
