import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/features/auth/presentation/onboarding_first_skin.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class RegisterConfirmation extends StatelessWidget {
  final String userName;

  const RegisterConfirmation({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 82),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
              child: Opacity(
                opacity: 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.basicBitchWhite.withAlpha(175),
                        offset: Offset(-0, -0),
                        blurRadius: 5,
                        blurStyle: BlurStyle.inner,
                      ),
                      BoxShadow(
                        color: Palette.basicBitchBlack.withAlpha(125),
                        offset: Offset(4, 4),
                        blurRadius: 5,
                      ),
                      BoxShadow(
                        color: Palette.monarchPurple1Opacity,
                        offset: Offset(0, 0),
                        blurRadius: 20,
                        blurStyle: BlurStyle.solid,
                      ),
                    ],
                  ),
                  height: 336,
                  width: 260,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 102),
                        child: Text(
                          'Awesome name!',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        "I've already forgotten it!",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 92),
                        child: Text(
                          "We won't be needing that anyway :)",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ConfirmButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushReplacement(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (_, __, ___) => OnboardingFirstSkin(),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
