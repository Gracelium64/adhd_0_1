import 'dart:ui';

import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class NameOverlay extends StatelessWidget {
  final DataBaseRepository repository;

  const NameOverlay(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
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
                Container(
                  height: 43,
                  width: 242,
                  decoration: BoxDecoration(
                    color: Palette.basicBitchWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter name here to start',

                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        hintStyle: TextStyle(
                          color: Palette.basicBitchBlack,
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
                SizedBox(height: 84),
                ConfirmButton(onPressed: () {  },),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
