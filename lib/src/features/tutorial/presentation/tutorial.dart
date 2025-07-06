import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tutorial extends StatelessWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const Tutorial(this.repository, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
       
        ],
      ),
    );
  }
}
