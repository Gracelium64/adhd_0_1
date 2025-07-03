import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/skin_overlay.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class NameOverlayConfirmation extends StatelessWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;
  final String userName;

  const NameOverlayConfirmation({
    super.key,
    required this.repository,
    required this.auth,
    required this.userName,
  });

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
                                  (_, __, ___) => SkinOverlay(repository),
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

//navigate to next

// WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (!mounted) return;

//                         Navigator.of(
//                           context,
//                           rootNavigator: true,
//                         ).pushReplacement(
//                           PageRouteBuilder(
//                             opaque: false,
//                             pageBuilder:
//                                 (_, __, ___) => NEXT_SCREEN/OVERLAY(
//                                   repository: widget.repository,
//                                   auth: widget.auth,
//                                   userName: userName.text,
//                                 ),
//                             transitionsBuilder: (_, animation, __, child) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               );
//                             },
//                           ),
//                         );
//                       });



///finish setting up the onboarding
// ConfirmButton(
                      //   onPressed: () async {
                      //     final prefs = await SharedPreferences.getInstance();
                      //     await prefs.setBool('onboardingComplete', true);

                      //     Navigator.of(
                      //       context,
                      //       rootNavigator: true,
                      //     ).pushReplacement(
                      //       MaterialPageRoute(
                      //         builder: (_) => MainScreen(repository, auth),
                      //       ),
                      //     );
                      //   },
                      // ),