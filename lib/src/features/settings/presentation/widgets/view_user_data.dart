import 'dart:ui';

import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/domain/functions.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class ViewUserData extends StatelessWidget {
  final void Function() onClose;

  const ViewUserData({super.key, required this.onClose});

  Future<String> getUserName(FlutterSecureStorage storage) async {
    return await storage.read(key: 'userId') ?? 'No User';
  }

  Future<String> getUserPassword(FlutterSecureStorage storage) async {
    return await storage.read(key: 'password') ?? 'No User';
  }

  Widget grayscaleImage(String assetPath, {BoxFit fit = BoxFit.fill}) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
      child: Image.asset(assetPath, fit: fit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();

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
                height: 293,
                width: 300,
                child: FutureBuilder(
                  future: Future.wait([
                    getUserName(storage),
                    getUserPassword(storage),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final data = snapshot.data as List<String>;
                      final userName = data[0];
                      final userPassword = data[1];

                      return Column(
                        children: [
                          SizedBox(height: 20),
                          SizedBox(
                            height: 95,
                            width: 95,
                            child: Image.asset(
                              'assets/img/icons/icon_bw.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'User Name: $userName',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                          Text(
                            'Password: $userPassword',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      'User Name: $userName\nPassword: $userPassword',
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Copied to Clipboard!',
                                    style:
                                        Theme.of(
                                          context,
                                        ).snackBarTheme.contentTextStyle,
                                  ),
                                ),
                              );
                              onClose();
                            },
                            child: Text(
                              'Copy to Clipboard',
                              style: TextStyle(color: Palette.basicBitchWhite),
                            ),
                          ),
                          SizedBox(height: 14),
                          ConfirmButton(
                            onPressed: () {
                              onClose();
                            },
                          ),
                        ],
                      );
                    } else {
                      return Center(child: Text('No data available'));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
