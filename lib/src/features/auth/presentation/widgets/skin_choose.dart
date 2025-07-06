import 'package:adhd_0_1/src/features/auth/presentation/skin_overlay_choose.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/onboarding_third_day_hour.dart';
import 'package:flutter/material.dart';

class SkinChooseAuth extends StatefulWidget {
  final AuthRepository auth;
  final bool? appSkin;
  final String bGPath;

  const SkinChooseAuth({
    super.key,
    required this.widget,
    required this.mounted,
    required this.appSkin,
    required this.bGPath,
    required this.auth,
  });

  final OnboardingSecondSkinSelection widget;
  final bool mounted;

  @override
  State<SkinChooseAuth> createState() => _SkinChooseAuthState();
}

class _SkinChooseAuthState extends State<SkinChooseAuth> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final currentSettings = await widget.widget.repository.getSettings();
        // ignore: unused_local_variable
        final updatedSettings = await widget.widget.repository.setSettings(
          widget.appSkin,
          currentSettings?.language ?? 'en',
          currentSettings?.location ?? 'default_location',
          currentSettings?.startOfDay ?? TimeOfDay(hour: 8, minute: 0),
          currentSettings?.startOfWeek ?? Weekday.any,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!widget.mounted) return;

          Navigator.of(context, rootNavigator: true).pushReplacement(
            PageRouteBuilder(
              opaque: false,
              pageBuilder:
                  (_, __, ___) => OnboardingThirdDayHour(
                    widget.widget.repository,
                    widget.auth,
                  ),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        });
        setState(() {});
      },

      child: Image.asset(widget.bGPath),
    );
  }
}
