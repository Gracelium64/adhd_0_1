import 'package:adhd_0_1/src/common/presentation/progress_bar_daily.dart';
import 'package:adhd_0_1/src/common/presentation/progress_bar_weekly.dart';
import 'package:adhd_0_1/src/common/domain/skin.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:flutter/material.dart';

class AppBg extends StatelessWidget {
  final DataBaseRepository repository;

  const AppBg(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset(
            appBgSkin(repository.getSettings()?.appSkinColor).toString(),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(48, 44, 0, 0),
            child: Text('Attention Deficit oH Dear', style: Theme.of(context).textTheme.headlineLarge),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(80, 116, 0, 0),
          child: ProgressBarDaily(progressBarStatus: 170),
          // 0 - 272
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(80, 140, 0, 0),
          child: ProgressBarWeekly(progressBarStatus: 200),
          // 0 - 272
        ),
      ],
    );
  }
}
