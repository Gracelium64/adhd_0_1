import 'dart:ui';
import 'package:adhd_0_1/main.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/features/auth/presentation/widgets/one_last_thing.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class LetsGoOverlay extends StatelessWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;
  
  const LetsGoOverlay(this.repository, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
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

                    Container(
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
                              'Alright!',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            "Let's Go!",
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 72),
                          ConfirmButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushReplacement(
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder:
                                      (_, __, ___) =>
                                          OneLastThing(repository, auth),
                                  transitionsBuilder: (
                                    _,
                                    animation,
                                    __,
                                    child,
                                  ) {
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
