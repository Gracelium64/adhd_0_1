import 'package:adhd_0_1/src/common/skin.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class AppBg extends StatelessWidget {
  const AppBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset(appBgSkin(appBg).toString()),
          // child: Image.asset('assets/img/app_bg/png/app_bg_pink.png'),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(52, 44, 0, 0),
            child: Text(
              'Attention Deficit oH Dear',
              style: TextStyle(
                fontFamily: 'Lobster',
                fontSize: 30,
                color: Palette.basicBitchWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
