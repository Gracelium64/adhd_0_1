import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
// import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  final void Function() onClose;

  const About({super.key, required this.onClose});

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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  boxShadow: [BoxShadow(color: Palette.basicBitchBlack)],
                  border: Border.all(color: Palette.basicBitchWhite, width: 2),
                ),
                height: 578,
                width: 300,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    SizedBox(
                      height: 120,
                      width: 65,
                      child: Image.asset(
                        'assets/img/sidebar/oi.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Text(
                      'Organic Interface Studios',
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(fontSize: 28),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "is an ethical development studio set with the goal to develop software that doesn't enslave the user, doesn't just slap inclusivity on the cover just to virtue signal, and believes that the product should speak for itself. Unlike the current state of things.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Samantha Fox once said 'naughty girls need love too', and developers need that as well, but also to eat.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "This app is completely free and we would appreciate any donation.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(),
                        CancelButton(
                          onPressed: () {
                            onClose();
                          },
                        ),
                        SizedBox(),
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(
                              'https://www.paypal.com/paypalme/gracelium64',
                            );
                            try {
                              final ok = await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not open browser',
                                      style:
                                          Theme.of(
                                            context,
                                          ).snackBarTheme.contentTextStyle,
                                    ),
                                    duration: Duration(milliseconds: 1200),
                                  ),
                                );
                              } else {
                                onClose();
                              }
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not open browser',
                                    style:
                                        Theme.of(
                                          context,
                                        ).snackBarTheme.contentTextStyle,
                                  ),
                                  duration: Duration(milliseconds: 1200),
                                ),
                              );
                            }
                          },
                          child: Image.asset(
                            'assets/img/buttons/credit_card.png',
                          ),
                        ),
                        SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
