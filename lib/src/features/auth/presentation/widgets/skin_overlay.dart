import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/skin_overlay_choose.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class SkinOverlay extends StatelessWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const SkinOverlay(this.repository, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                      child: Text(
                        'Please choose your Flesh Prison',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      width: 98,

                      child: GestureDetector(
                        onTap: () {
                          overlayController.toggle();
                        },

                        child: OverlayPortal(
                          controller: overlayController,
                          overlayChildBuilder: (BuildContext context) {
                            return SkinOverlayChoose(repository, auth);
                          },
                          child: Image.asset(
                            'assets/img/buttons/skin_null.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You can always change it later',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 72),
                    ConfirmButton(onPressed: () {}),
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
