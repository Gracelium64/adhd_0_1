import 'package:adhd_0_1/src/common/presentation/progress_bar_daily.dart';
import 'package:adhd_0_1/src/common/presentation/progress_bar_weekly.dart';
import 'package:adhd_0_1/src/common/domain/skin.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:flutter/material.dart';
import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';

class AppBg extends StatefulWidget {
  final DataBaseRepository repository;

  const AppBg(this.repository, {super.key});

  @override
  State<AppBg> createState() => _AppBgState();
}

class _AppBgState extends State<AppBg> {
  late Future<String?> mySkin;
  Future<double> calculateDailyProgress() async {
    final allTasks = await widget.repository.getDailyTasks();
    final total = allTasks.length;
    if (total == 0) return 0;
    final completed = allTasks.where((task) => task.isDone).length;
    final percentage = completed / total;
    return 272 * percentage;
  }

  Future<double> calculateWeeklyProgress() async {
    final allTasks = await widget.repository.getWeeklyTasks();
    final total = allTasks.length;
    if (total == 0) return 0;
    final completed = allTasks.where((task) => task.isDone).length;
    final percentage = completed / total;
    return 272 * percentage;
  }

  @override
  void initState() {
    super.initState();
    mySkin = loadSkin();
    dailyProgressFuture.value = widget.repository.getDailyTasks().then((tasks) {
      final total = tasks.length;
      final completed = tasks.where((task) => task.isDone).length;
      return total == 0 ? 0.0 : 272.0 * (completed / total);
    });
  }

  Future<String?> loadSkin() async {
    try {
      final settings = await widget.repository.getSettings();
      final skin = settings?.appSkinColor;
      return appBgSkin(skin);
    } catch (e) {
      return appBgSkin(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: mySkin,
      builder: (context, snapshot) {
        final skinData =
            snapshot.data ?? 'assets/img/app_bg/png/app_bg_white.png';
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Image.asset(
                  'assets/img/app_bg/png/app_bg_load.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          );
        }

        return Stack(
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(skinData),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: const EdgeInsets.fromLTRB(48, 44, 0, 0),
                child: Text(
                  'Attention Deficit oH Dear',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 116, 0, 0),
              child: ValueListenableBuilder<Future<double>>(
                valueListenable: dailyProgressFuture,
                builder: (context, future, _) {
                  return FutureBuilder<double>(
                    future: future,
                    builder: (context, snapshot) {
                      final progress = snapshot.data ?? 0;
                      return ProgressBarDaily(
                        progressBarStatus: progress,
                        repository: widget.repository,
                      );
                    },
                  );
                },
              ),

              // 0 - 272 = 0% - 100% for ProgressBar
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 140, 0, 0),
              child: ValueListenableBuilder<Future<double>>(
                valueListenable: weeklyProgressFuture,
                builder: (context, future, _) {
                  return FutureBuilder<double>(
                    future: calculateWeeklyProgress(),
                    builder: (context, snapshot) {
                      final progress = snapshot.data ?? 0;
                      return ProgressBarWeekly(
                        progressBarStatus: progress,
                        repository: widget.repository,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
