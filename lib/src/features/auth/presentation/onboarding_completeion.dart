import 'dart:ui';
import 'dart:async';
import 'package:adhd_0_1/src/data/domain/firestore_initializer.dart';
import 'package:adhd_0_1/src/features/auth/presentation/app_bg_coldstart.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adhd_0_1/src/common/presentation/blocking_loader.dart';

import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCompletion extends StatefulWidget {
  const OnboardingCompletion({super.key});

  @override
  State<OnboardingCompletion> createState() => _OnboardingCompletionState();
}

class _OnboardingCompletionState extends State<OnboardingCompletion> {
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
                    Text(
                      'One last thing!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(58, 12, 58, 0),
                      child: Text(
                        'Would you like a short tutorial for the app?',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Text(
                        'You can always access it later by clicking the Organic Interface button',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 82,
                      width: 46,
                      child: Image.asset(
                        'assets/img/sidebar/oi.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(height: 52),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            debugPrint(
                              '🎬 OnboardingCompletion: confirm tapped (no tutorial)',
                            );
                            await showBlockingLoaderDuring(context, () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              debugPrint('🧭 Setting onboardingComplete=true');
                              await prefs.setBool('onboardingComplete', true);

                              final storage = FlutterSecureStorage();
                              String? userId = await storage.read(
                                key: 'userId',
                              );
                              debugPrint(
                                '🧭 Initializing Firestore defaults for userId=$userId',
                              );
                              try {
                                await FirestoreInitializer.initializeDefaults(
                                  userId,
                                ).timeout(const Duration(seconds: 5));
                                debugPrint('✅ Firestore defaults initialized');
                              } on TimeoutException {
                                debugPrint(
                                  '⏱️ Firestore defaults init timed out; continuing',
                                );
                              } catch (e) {
                                debugPrint(
                                  '⚠️ Firestore defaults init error: $e',
                                );
                              }
                            });

                            if (context.mounted) {
                              debugPrint(
                                '🧭 Navigating to MainScreen (no tutorial)',
                              );
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushAndRemoveUntil(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => MainScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },

                          child: Image.asset(
                            'assets/img/buttons/cancel_big.png',
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            debugPrint(
                              '🎬 OnboardingCompletion: confirm tapped (with tutorial)',
                            );
                            await showBlockingLoaderDuring(context, () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              debugPrint('🧭 Setting onboardingComplete=true');
                              await prefs.setBool('onboardingComplete', true);

                              final storage = FlutterSecureStorage();
                              String? userId = await storage.read(
                                key: 'userId',
                              );
                              debugPrint(
                                '🧭 Initializing Firestore defaults for userId=$userId',
                              );
                              try {
                                await FirestoreInitializer.initializeDefaults(
                                  userId,
                                ).timeout(const Duration(seconds: 5));
                                debugPrint('✅ Firestore defaults initialized');
                              } on TimeoutException {
                                debugPrint(
                                  '⏱️ Firestore defaults init timed out; continuing',
                                );
                              } catch (e) {
                                debugPrint(
                                  '⚠️ Firestore defaults init error: $e',
                                );
                              }
                            });

                            if (context.mounted) {
                              debugPrint(
                                '🧭 Navigating to MainScreen (with tutorial)',
                              );
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushAndRemoveUntil(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (_, __, ___) =>
                                          const MainScreen(showTutorial: true),
                                ),
                                (route) => false,
                              );
                            }
                          },

                          child: Image.asset('assets/img/buttons/confirm.png'),
                        ),
                      ],
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


// ConfirmButton(
//                         onPressed: () async {
//                           final prefs = await SharedPreferences.getInstance();
//                           await prefs.setBool('onboardingComplete', true);

//                           Navigator.of(
//                             context,
//                             rootNavigator: true,
//                           ).pushReplacement(
//                             MaterialPageRoute(
//                               builder: (_) => MainScreen(repository, auth),
//                             ),
//                           );
//                         },
//                       ),