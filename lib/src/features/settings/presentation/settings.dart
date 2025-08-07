import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/features/settings/presentation/widgets/view_user_data.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void _showAddTaskOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          elevation: 8,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: AddTaskWidget(
            taskType: TaskType.daily,
            onClose: () {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {
                myList = context.read<DataBaseRepository>().getDailyTasks();
              });
              debugPrint(
                'Navigator stack closing from ${Navigator.of(context)}',
              );
            },
          ),
        );
      },
    );
  }

  late Future<List<Task>> myList;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();
    final auth = context.read<FirebaseAuthRepository>();

    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            SubTitle(sub: 'Settings'),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 550,
                    width: 304,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        spacing: 24,
                        children: [
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Choose your Flesh Prison',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
                              Image.asset('assets/img/buttons/skin_true.png'),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'When does your week start?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
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
                                  style: TextStyle(
                                    color: Palette.basicBitchWhite,
                                  ),
                                ),
                              ),
                              ////// TODO: replace textbutton with DropdownMenu
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'When does your day start?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
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
                                  style: TextStyle(
                                    color: Palette.basicBitchWhite,
                                  ),
                                ),
                              ),
                              ////// TODO: replace textbutton with TimeInput
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Where do you live? ;)',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
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
                                  'Berlin',
                                  style: TextStyle(
                                    color: Palette.basicBitchWhite,
                                  ),
                                ),
                              ),
                              ////// TODO: replace textbutton with DropdownMenu
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       'Language',
                          //       style: Theme.of(context).textTheme.bodyMedium,
                          //     ),
                          //     Spacer(),
                          //     TextButton(
                          //       style: TextButton.styleFrom(
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.all(
                          //             Radius.circular(8),
                          //           ),
                          //           side: BorderSide(
                          //             color: Palette.basicBitchWhite,
                          //             width: 1,
                          //           ),
                          //         ),
                          //       ),
                          //       onPressed: () {},
                          //       child: Text(
                          //         'English',
                          //         style: TextStyle(
                          //           color: Palette.basicBitchWhite,
                          //         ),
                          //       ),
                          //     ),
                          //     ////// TODO: replace textbutton with DropdownMenu
                          //   ],
                          // ),
                          OverlayPortal(
                            controller: overlayController,
                            overlayChildBuilder: (BuildContext context) {
                              return ViewUserData(
                                onClose: () {
                                  overlayController.toggle();
                                },
                              );
                            },
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  overlayController.toggle();
                                },
                                child: Text(
                                  'View User Data',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Palette.lightTeal),
                                ),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     GestureDetector(
                          //       onTap: () {},
                          //       child: Text(
                          //         'Check for updates',
                          //         style: Theme.of(context).textTheme.bodyMedium
                          //             ?.copyWith(color: Palette.lightTeal),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Stack(
                                  children: [
                                    Text(
                                      'About',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: Palette.basicBitchBlack,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Opacity(
                                      opacity: 0.8,
                                      child: GradientText(
                                        'About',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,

                                        colors: [
                                          Palette.basicBitchBlack,
                                          Palette.lightTeal,
                                        ],
                                        gradientDirection:
                                            GradientDirection.btt,
                                        stops: [0.1, 0.6],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(onTap: _showAddTaskOverlay, child: AddTaskButton()),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
