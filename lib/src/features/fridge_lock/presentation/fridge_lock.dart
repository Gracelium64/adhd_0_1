import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:adhd_0_1/src/features/task_management/domain/task.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeLock extends StatefulWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;
  final Task task;
  final void Function() onClose;

  const FridgeLock(
    this.repository,
    this.auth, {
    super.key,
    required this.task,
    required this.onClose,
  });

  @override
  State<FridgeLock> createState() => _FridgeLockState();
}

class _FridgeLockState extends State<FridgeLock> {
  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            SubTitle(sub: 'Fridge Lock'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 492,
                    width: 304,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 150),
                        Text(
                          'Not available',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          'Planned for next update',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        SizedBox(height: 50),
                        Text('[v.0.1 SPRINT 1.1]'),
                        SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('onboardingComplete', false);
                            debugPrint('Reset complete');
                          },
                          child: Text('Reset Cold Start Flag'),
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            await widget.auth.signOut();
                          },
                          child: Text('Log Out'),
                        ),
                      ],
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
                    widget.repository,
                    overlayController,
                    taskType: TaskType.daily,
                    task: widget.task,
                    onClose: () {},
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
