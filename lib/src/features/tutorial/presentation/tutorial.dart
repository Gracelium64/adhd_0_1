import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tutorial extends StatelessWidget {
  final DataBaseRepository repository;

  const Tutorial(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isColdStart', true);
          print('Reset complete');
        },
        child: Text('Reset Cold Start Flag'),
      ),
    );
  }
}
