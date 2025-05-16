import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  final String sub;

  const SubTitle({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 40, 0),
      child: Text(
        sub,
        style: TextStyle(
          color: Palette.basicBitchWhite,
          fontFamily: 'Marvel',
          fontSize: 34,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
