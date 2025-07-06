import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/widgets/skin_choose.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class SkinOverlayChoose extends StatefulWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const SkinOverlayChoose(this.repository, this.auth, {super.key});

  @override
  State<SkinOverlayChoose> createState() => _SkinOverlayChooseState();
}

class _SkinOverlayChooseState extends State<SkinOverlayChoose> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  height: 293,
                  width: 300,
                  child: Column(
                    children: [
                      SizedBox(height: 4),
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Image.asset(
                          'assets/img/app_bg/png/cold_start_icon.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Text(
                        'Choose your Flesh Prison',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SkinChoose(
                            widget: widget,
                            mounted: mounted,
                            appSkin: true,
                            bGPath: 'assets/img/buttons/skin_true.png',
                            auth: widget.auth,
                          ),
                          SkinChoose(
                            widget: widget,
                            mounted: mounted,
                            appSkin: null,
                            bGPath: 'assets/img/buttons/skin_null.png',
                            auth: widget.auth,
                          ),
                          SkinChoose(
                            widget: widget,
                            mounted: mounted,
                            appSkin: false,
                            bGPath: 'assets/img/buttons/skin_false.png',
                            auth: widget.auth,
                          ),
                        ],
                      ),
                      SizedBox(height: 36),
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
