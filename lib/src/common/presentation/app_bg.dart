import 'package:adhd_0_1/src/common/presentation/progress_bar_daily.dart';
import 'package:adhd_0_1/src/common/presentation/progress_bar_weekly.dart';
import 'package:adhd_0_1/src/common/domain/skin.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class AppBg extends StatefulWidget {
  final DataBaseRepository repository;

  const AppBg(this.repository, {super.key});

  @override
  State<AppBg> createState() => _AppBgState();
}

class _AppBgState extends State<AppBg> {
  late Future<String?> mySkin;

  @override
  void initState() {
    super.initState();
    mySkin = loadSkin();
  }

  Future<String?> loadSkin() async {
    try {
      final settings = await widget.repository.getSettings();
      final skin = settings?.appSkinColor;
      return appBgSkin(skin);
    } catch (e) {
      return appBgSkin(true);
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
      },
    );
  }
}
