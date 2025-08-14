import 'package:adhd_0_1/src/features/auth/presentation/onboarding_second_skin_selection.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/onboarding_third_day_hour.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SkinChooseAuth extends StatefulWidget {
  final bool? appSkin;
  final String bGPath;

  const SkinChooseAuth({
    super.key,

    this.appSkin,
    required this.bGPath,

    required this.widget,
    required this.mounted,
  });

  final OnboardingSecondSkinSelection widget;
  final bool mounted;

  @override
  State<SkinChooseAuth> createState() => _SkinChooseAuthState();
}

class _SkinChooseAuthState extends State<SkinChooseAuth> {
  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await showBlockingLoaderDuring(context, () async {
          final currentSettings = await repository.getSettings();
          // ignore: unused_local_variable
          final updatedSettings = await repository.setSettings(
            widget.appSkin,
            currentSettings?.language ?? 'en',
            currentSettings?.location ?? 'default_location',
            currentSettings?.startOfDay ?? TimeOfDay(hour: 8, minute: 0),
            currentSettings?.startOfWeek ?? Weekday.any,
          );
        });

        if (!context.mounted) return;

        Navigator.of(context, rootNavigator: true).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => OnboardingThirdDayHour(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },

      child: Image.asset(widget.bGPath),
    );
  }
}
