import 'dart:ui';
import 'package:adhd_0_1/src/features/auth/presentation/onboarding_second_skin_selection.dart';
import 'package:adhd_0_1/src/features/auth/presentation/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class OnboardingFirstSkin extends StatelessWidget {
  const OnboardingFirstSkin({super.key});

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
                            return OnboardingSecondSkinSelection();
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
