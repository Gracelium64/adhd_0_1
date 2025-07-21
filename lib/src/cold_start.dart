import 'package:adhd_0_1/src/features/auth/presentation/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/register.dart';
import 'package:flutter/material.dart';

class ColdStart extends StatelessWidget {
  const ColdStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBgColdstart(),
        Scaffold(backgroundColor: Colors.transparent, body: Register()),
      ],
    );
  }
}
