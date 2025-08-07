import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/features/auth/domain/validators.dart';
import 'package:adhd_0_1/src/features/auth/presentation/register_confirmation.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController userName = TextEditingController(text: '');
  final storage = FlutterSecureStorage();

  Future<void> onSubmit(String userName, String pw) async {
    final auth = context.read<FirebaseAuthRepository>();
    await auth.createUserWithEmailAndPassword(userName, pw);
  }

  String generateUserId(String username) {
    final now = DateTime.now();
    final formatted =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final microTimestamp = now.microsecondsSinceEpoch;
    return '${username}_${formatted}_$microTimestamp';
  }

  int generateRandom8DigitNumber() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = 10000000 + (now % 90000000);
    return random;
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
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
                  padding: const EdgeInsets.fromLTRB(46, 36, 46, 0),
                  child: Text(
                    'Before we begin, could you tell me your name?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: userNameValidator,
                      controller: userName,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Palette.basicBitchWhite,
                        hintText: 'Enter name here to start',
                        contentPadding: EdgeInsets.only(bottom: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Palette.basicBitchBlack,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintStyle: TextStyle(
                          color: Palette.basicBitchBlack,
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                ),
                SizedBox(height: 84),
                OverlayPortal(
                  controller: overlayController,
                  overlayChildBuilder: (BuildContext context) {
                    return RegisterConfirmation(userName: userName.text);
                  },
                  child: ConfirmButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      try {
                        final userId = generateUserId(userName.text);
                        final userPassword =
                            generateRandom8DigitNumber().toString();
                        await storage.write(
                          key: 'email',
                          value: '$userId@adventurer.adhd',
                        );
                        await storage.write(
                          key: 'password',
                          value: userPassword,
                        );
                        await storage.write(key: 'userId', value: userId);
                        await storage.write(key: 'name', value: userName.text);

                        await onSubmit('$userId@adventurer.adhd', 'password');

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Welcome $userId!')),
                        );
                        overlayController.toggle();
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userName.dispose();
    super.dispose();
  }
}
