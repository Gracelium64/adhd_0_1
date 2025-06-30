import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class Settings extends StatelessWidget {
  final DataBaseRepository repository;

  const Settings(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            SubTitle(sub: 'Prizes'),

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
                          Row(
                            children: [
                              Text(
                                'Language',
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
                                  'English',
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
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Check for updates',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Palette.lightTeal),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Backup your data',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Palette.lightTeal),
                                ),
                              ),
                            ],
                          ),
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
            GestureDetector(
              onTap: () {
                overlayController.toggle();
              },
              child: OverlayPortal(
                controller: overlayController,
                overlayChildBuilder: (BuildContext context) {
                  return AddTaskWidget(
                    repository,
                    overlayController,
                    taskType: TaskType.daily,
                  );
                },
                child: AddTaskButton(),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
