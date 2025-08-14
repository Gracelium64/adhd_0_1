import 'dart:ui';

import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/features/settings/presentation/widgets/account_switching_screen.dart';

class LoadSaveGame extends StatefulWidget {
  const LoadSaveGame({super.key});

  @override
  State<LoadSaveGame> createState() => _LoadSaveGameState();
}

class _LoadSaveGameState extends State<LoadSaveGame> {
  final _formKey = GlobalKey<FormState>();
  final _userNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _identifierCtrl = TextEditingController();

  @override
  void dispose() {
    _userNameCtrl.dispose();
    _passwordCtrl.dispose();
    _identifierCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    final userName = _userNameCtrl.text.trim();
    final ownerPassword = _passwordCtrl.text.trim();
    final identifier = _identifierCtrl.text.trim();

    try {
      // Navigate to a dedicated screen that performs the switch while MainScreen is unmounted
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder:
              (_, __, ___) => AccountSwitchingScreen(
                userName: userName,
                ownerPassword: ownerPassword,
                identifier: identifier,
              ),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: Theme.of(context).snackBarTheme.contentTextStyle,
          ),
        ),
      );
    }
  }

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
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  boxShadow: const [BoxShadow(color: Colors.black)],
                  border: Border.all(color: Palette.basicBitchWhite, width: 2),
                ),
                height: 430,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 95,
                          width: 95,
                          child: Image.asset(
                            'assets/img/icons/icon_bw.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _userNameCtrl,
                          style: TextStyle(color: Palette.basicBitchWhite),
                          decoration: const InputDecoration(
                            labelText: 'User Name',
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          controller: _passwordCtrl,
                          style: TextStyle(color: Palette.basicBitchWhite),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          controller: _identifierCtrl,
                          style: TextStyle(color: Palette.basicBitchWhite),
                          decoration: const InputDecoration(
                            labelText: 'Identifier',
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CancelButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              },
                            ),
                            ConfirmButton(onPressed: _onConfirm),
                          ],
                        ),
                      ],
                    ),
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
