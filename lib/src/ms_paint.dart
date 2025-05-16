import 'dart:ui';

import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/skin_overlay_choose.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/day_hour_settings_coldstart_overlay.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/lets_go_overlay.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/location_choose_overlay.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/name_overlay.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/name_overlay_confirmation.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/one_last_thing.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/skin_overlay.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class MsPaint extends StatelessWidget {
  final DataBaseRepository repository;

  const MsPaint(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBgColdstart(),
        OneLastThing(),
      ],
    );
  }
}
