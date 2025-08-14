import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/onboarding_fifth.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingFourthLocation extends StatefulWidget {
  const OnboardingFourthLocation({super.key});

  @override
  State<OnboardingFourthLocation> createState() =>
      _OnboardingFourthLocationState();
}

class _OnboardingFourthLocationState extends State<OnboardingFourthLocation> {
  WorldCapital selectedCapital = WorldCapital.berlin;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    return Stack(
      children: [
        AppBgColdstart(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Container(
                decoration: BoxDecoration(
                  color: Palette.peasantGrey1Opacity,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                height: 578,
                width: 300,
                child: Column(
                  children: [
                    SizedBox(height: 28),
                    Image.asset('assets/img/app_bg/png/cold_start_icon.png'),
                    Text(
                      'Hello Adventurer!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Where do you live?',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(42, 0, 42, 0),
                      child: Column(
                        children: [
                          Text(
                            'I need it only for your daily weather report, I promise :)',
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '[Testing version, limited choices available]',
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    DropdownButton<WorldCapital>(
                      value: selectedCapital,
                      dropdownColor: Palette.basicBitchBlack,
                      style: TextStyle(color: Palette.basicBitchWhite),
                      onChanged: (WorldCapital? newCapital) {
                        if (newCapital != null) {
                          setState(() {
                            selectedCapital = newCapital;
                          });
                        }
                      },
                      items:
                          WorldCapital.values.map((capital) {
                            return DropdownMenuItem(
                              value: capital,
                              child: Text(capital.label),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 108),
                    ConfirmButton(
                      onPressed: () async {
                        await showBlockingLoaderDuring(context, () async {
                          final currentSettings =
                              await repository.getSettings();

                          await repository.setSettings(
                            currentSettings?.appSkinColor,
                            currentSettings?.language ?? 'en',
                            selectedCapital.label,
                            currentSettings?.startOfDay ??
                                TimeOfDay(hour: 8, minute: 0),
                            currentSettings?.startOfWeek ?? Weekday.mon,
                          );
                        });

                        if (!context.mounted) return;

                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => OnboardingFifth(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
