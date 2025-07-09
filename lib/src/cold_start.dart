import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/register.dart';
import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
import 'package:flutter/material.dart';

class ColdStart extends StatelessWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;
  final Task task;

  const ColdStart(this.repository, this.auth, this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBgColdstart(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Register(repository, auth, task),
        ),
      ],
    );
  }
}
