import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/lets_go_overlay.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class LocationChooseOverlay extends StatefulWidget {
  final DataBaseRepository repository;

  const LocationChooseOverlay(this.repository, {super.key});

  @override
  State<LocationChooseOverlay> createState() => _LocationChooseOverlayState();
}

class _LocationChooseOverlayState extends State<LocationChooseOverlay> {
  WorldCapital selectedCapital = WorldCapital.berlin;

  @override
  Widget build(BuildContext context) {
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
                      child: Text(
                        'I need it only for your daily weather report, I promise :)',
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
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
                        final currentSettings =
                            await widget.repository.getSettings();

                        await widget.repository.setSettings(
                          currentSettings?.appSkinColor,
                          currentSettings?.language ?? 'en',
                          selectedCapital.label,
                          currentSettings?.startOfDay ??
                              TimeOfDay(hour: 8, minute: 0),
                          currentSettings?.startOfWeek ?? Weekday.any,
                        );

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushReplacement(
                            // MaterialPageRoute(builder: (_) => LetsGoOverlay(widget.repository)),
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (_, __, ___) =>
                                      LetsGoOverlay(widget.repository),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        });
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
