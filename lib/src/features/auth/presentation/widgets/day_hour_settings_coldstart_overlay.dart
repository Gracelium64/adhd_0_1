import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/location_choose_overlay.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class DayHourSettingsColdstartOverlay extends StatefulWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const DayHourSettingsColdstartOverlay(
    this.repository,
    this.auth, {
    super.key,
  });

  @override
  State<DayHourSettingsColdstartOverlay> createState() =>
      _DayHourSettingsColdstartOverlayState();
}

class _DayHourSettingsColdstartOverlayState
    extends State<DayHourSettingsColdstartOverlay> {
  Weekday selectedWeekday = Weekday.mon;
  TimeOfDay? selectedTime;

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
                      'When does your week start?',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),

                    DropdownButton<Weekday>(
                      value: selectedWeekday,
                      dropdownColor: Palette.basicBitchBlack,
                      style: TextStyle(color: Palette.basicBitchWhite),
                      onChanged: (Weekday? newDay) {
                        if (newDay != null) {
                          setState(() {
                            selectedWeekday = newDay;
                          });
                        }
                      },
                      items:
                          Weekday.values.map((day) {
                            return DropdownMenuItem(
                              value: day,
                              child: Text(day.label),
                            );
                          }).toList(),
                    ),

                    SizedBox(height: 12),
                    Text(
                      'When does your day start?',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),

                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Palette.basicBitchWhite),
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              selectedTime ?? TimeOfDay(hour: 8, minute: 0),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Text(
                        selectedTime?.format(context) ?? 'HH:MM',
                        style: TextStyle(color: Palette.basicBitchWhite),
                      ),
                    ),

                    SizedBox(height: 36),
                    ConfirmButton(
                      onPressed: () async {
                        final currentSettings =
                            await widget.repository.getSettings();

                        await widget.repository.setSettings(
                          currentSettings?.appSkinColor ?? true,
                          currentSettings?.language ?? 'en',
                          currentSettings?.location ?? 'default_location',
                          selectedTime ?? TimeOfDay(hour: 8, minute: 0),
                          selectedWeekday,
                        );

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushReplacement(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (_, __, ___) =>
                                      LocationChooseOverlay(widget.repository, widget.auth),
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
