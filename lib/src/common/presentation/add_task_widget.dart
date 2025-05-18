import 'package:adhd_0_1/src/common/presentation/cancel_button.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/delete_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class AddTaskWidget extends StatelessWidget {
  final DataBaseRepository repository;

  const AddTaskWidget(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 82),
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
              height: 578,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task name',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(maxLength: 36),

                    Text(
                      'Day of the week',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Click here'),
                        ),
                        ////// TODO: DayPick Overlay
                      ],
                    ),
                    Text(
                      'Deadline',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              side: BorderSide(
                                color: Palette.basicBitchWhite,
                                width: 1,
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'DAY',
                            style: TextStyle(color: Palette.basicBitchWhite),
                          ),
                        ),

                        ////// TODO: replace textbutton with DropdownMenu
                        TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              side: BorderSide(
                                color: Palette.basicBitchWhite,
                                width: 1,
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'HH:MM',
                            style: TextStyle(color: Palette.basicBitchWhite),
                          ),
                        ),
                        ////// TODO: replace textbutton with TimeInput
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Palette.darkTeal,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Dailys',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Palette.lightTeal,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Weeklys',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Palette.lightTeal,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Deadlineys',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 40,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Palette.lightTeal,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                'Quest',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        DeleteButton(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: CancelButton(),
                        ),
                        ConfirmButton(),
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
