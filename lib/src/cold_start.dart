import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/app_bg_coldstart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColdStart extends StatelessWidget {
  final DataBaseRepository repository;

  const ColdStart(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBgColdstart(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isColdStart', false);
              },
              child: Text('Reset Cold Start Flag'),
            ),
          ),
        ),
      ],
    );
  }
}
