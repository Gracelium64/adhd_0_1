import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tutorial extends StatelessWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const Tutorial(this.repository, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isColdStart', true);
              debugPrint('Reset complete');
            },
            child: Text('Reset Cold Start Flag'),
          ),

          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
