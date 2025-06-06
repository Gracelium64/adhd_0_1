import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class LocationChooseOverlay extends StatelessWidget {
  final DataBaseRepository repository;

  const LocationChooseOverlay(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge,
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(
                        color: Palette.basicBitchWhite,
                        width: 1,
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Berlin',
                    style: TextStyle(color: Palette.basicBitchWhite),
                  ),
                ),
                ////// TODO: replace textbutton with TextInput
                SizedBox(height: 108),
                ConfirmButton(onPressed: () {  },),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
