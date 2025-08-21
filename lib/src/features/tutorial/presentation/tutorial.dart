import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/features/tutorial/presentation/widgets/tutorial_item.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Tutorial extends StatefulWidget {
  final OverlayPortalController controller;

  const Tutorial(this.controller, {super.key});

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  int currentPage = 0;

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
            height: 578 * 1.05,
            width: 300 * 1.05,
            child:
                currentPage == 0
                    ? Column(
                      children: [
                        SizedBox(height: 28),
                        Image.asset(
                          'assets/img/app_bg/png/cold_start_icon.png',
                          scale: 1.2,
                        ),
                        SizedBox(
                          height: 400,
                          child: Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  0,
                                ),
                                child: Column(
                                  children: [
                                    Gap(16),
                                    Text(
                                      "Disclaimer: I'm not like other apps",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Gap(32),
                                    Text(
                                      "I am is not here to replace your calendar, I'm also not here to send you constant reminders and notification.",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Gap(16),
                                    Text(
                                      "I will not be holding my user's hand through the process, I want to treat you as a grown adult and for you to do the work.",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "I'm here to help you gamify your life - but I can only show you the door, you're the one that has to walk through it.",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Gap(16),
                                    Text(
                                      "I aim to help you build healthier habits and keep up with your tasks and goals through the power of Magic (and Neuroplasticity).",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "In best case scenario you will delete me within a year because you will no longer require me (you don't have to though, you make your own adventure and I am not your supervisor).",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Gap(16),
                                    Text(
                                      "This will not happen if I trap you endlessly in here or try to replace as many apps as possible on your phone. ",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displayMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Gap(50),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              currentPage = 1;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.chevron_right_rounded,
                                            size: 50,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : currentPage == 1
                    ? Column(
                      children: [
                        SizedBox(height: 28),
                        Image.asset(
                          'assets/img/app_bg/png/cold_start_icon.png',
                          scale: 1.2,
                        ),
                        Column(
                          children: [
                            TutorialItem(
                              title: 'These are your Daily Tasks',
                              imgUrl: 'assets/img/sidebar/daily.png',
                              subTitle: 'They reset each day',
                            ),
                            TutorialItem(
                              title: 'These are your Weekly Tasks',
                              imgUrl: 'assets/img/sidebar/week.png',
                              subTitle: 'They reset in the weekly summery',
                            ),
                            TutorialItem(
                              title: 'These are your Deadlines',
                              imgUrl: 'assets/img/sidebar/clock.png',
                              subTitle: 'They reward you with a point',
                            ),
                            TutorialItem(
                              title: 'This is your Main Quest',
                              imgUrl: 'assets/img/sidebar/star.png',
                              subTitle: 'They reward you with a point as well',
                            ),
                            TutorialItem(
                              title: "Comes in future update",
                              imgUrl: 'assets/img/sidebar/fridge.png',
                              subTitle: "Can't tell you everything",
                            ),
                            TutorialItem(
                              title: 'Fidget screen!',
                              imgUrl: 'assets/img/sidebar/fidget.png',
                              subTitle: 'Good luck with that...',
                            ),
                            TutorialItem(
                              title: "See what you've won so far",
                              imgUrl: 'assets/img/sidebar/prize.png',
                              subTitle: 'AI made Abominations',
                            ),
                            TutorialItem(
                              title: 'Burger Menu',
                              imgUrl: 'assets/img/sidebar/hamburger.png',
                              subTitle: 'App Settings',
                            ),
                            Gap(12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      currentPage = 0;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.chevron_left_rounded,
                                    size: 36,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      currentPage = 2;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        SizedBox(height: 28),
                        Image.asset(
                          'assets/img/app_bg/png/cold_start_icon.png',
                          scale: 1.2,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Click on the + button in the bottom of the screen to add a task to your adventure.",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Gap(16),
                                  Text(
                                    "You can choose which task type you want to add, the default is to the task type you're currently navigating to.",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Gap(16),
                                  Text(
                                    "Click on an existing task to edit or delete it. Hold a task to move it around in the list, click on the button on it's left side to mark it completed.",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Gap(16),
                                  Text(
                                    "You will be alreated about deadline the week before, the day before, and on the day.",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Gap(16),
                                  Text(
                                    "Don't forget to have some fun out there",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Gap(32),

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
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
