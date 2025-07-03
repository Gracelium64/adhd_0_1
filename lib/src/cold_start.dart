import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/name_overlay.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColdStart extends StatelessWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const ColdStart(this.repository, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    // OverlayPortalController overlayController = OverlayPortalController();

    return Stack(
      children: [
        AppBgColdstart(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: NameOverlay(repository, auth),
        ),
      ],
    );
  }
}
