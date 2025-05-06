import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class Tutorial extends StatelessWidget {
  const Tutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('tutorial', style: TextStyle(color: Palette.basicBitchWhite)),
    );
  }
}
