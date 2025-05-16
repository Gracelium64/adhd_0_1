import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class SkinOverlay extends StatelessWidget {
  const SkinOverlay({
    super.key,
  });

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
                  style: TextStyle(
                    color: Palette.basicBitchWhite,
                    fontFamily: 'Marvel',
                    fontSize: 40,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                  child: Text(
                    'Please choose your Flesh Prison',
                    style: TextStyle(
                      color: Palette.basicBitchWhite,
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  width: 98,
    
                  child: Image.asset(
                    'assets/img/buttons/skin_null.png',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You can always change it later',
                  style: TextStyle(
                    color: Palette.basicBitchWhite,
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 72),
                ConfirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
