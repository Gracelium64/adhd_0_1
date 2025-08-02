import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/features/tutorial/presentation/widgets/tutorial_item.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class Tutorial extends StatefulWidget {
  final OverlayPortalController controller;

  const Tutorial(this.controller, {super.key});

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
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
            height: 578,
            width: 300,
            child: Column(
              children: [
                SizedBox(height: 28),
                Image.asset(
                  'assets/img/app_bg/png/cold_start_icon.png',
                  scale: 1.2,
                ),
                TutorialItem(
                  title: 'These are your Daily Tasks',
                  imgUrl: 'assets/img/sidebar/daily.png',
                ),
                TutorialItem(
                  title: 'These are your Weekly Tasks',
                  imgUrl: 'assets/img/sidebar/week.png',
                ),
                TutorialItem(
                  title: 'These are your Deadlines',
                  imgUrl: 'assets/img/sidebar/clock.png',
                ),
                TutorialItem(
                  title: 'This is your Main Quest',
                  imgUrl: 'assets/img/sidebar/star.png',
                ),
                TutorialItem(
                  title: 'Here you block Apps',
                  imgUrl: 'assets/img/sidebar/fridge.png',
                ),
                TutorialItem(
                  title: 'Fidget screen! Good luck with that...',
                  imgUrl: 'assets/img/sidebar/fidget.png',
                ),
                TutorialItem(
                  title: "See what you've won so far",
                  imgUrl: 'assets/img/sidebar/prize.png',
                ),
                TutorialItem(
                  title: 'App Settings',
                  imgUrl: 'assets/img/sidebar/hamburger.png',
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    "Click on the + button in the bottom to add a task, you can do it from every screen. Default is daily task, but when you go between task types it will default to the screen you’re on. Click on an existing task to edit or delete it. Click on the glowing button left to a task to mark it as completed. ",
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 20),
                  child: Text(
                    'The rest will be a surprise :)',
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
                ConfirmButton(
                  onPressed: () {
                    widget.controller.toggle();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
