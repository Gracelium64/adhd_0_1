import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/features/fridge_lock/presentation/widgets/debug_prefs_overlay.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeLock extends StatefulWidget {
  const FridgeLock({super.key});

  @override
  State<FridgeLock> createState() => _FridgeLockState();
}

class _FridgeLockState extends State<FridgeLock> {
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();
    final auth = context.read<FirebaseAuthRepository>();

    OverlayPortalController overlayController = OverlayPortalController();
    OverlayPortalController overlayControllerDebug = OverlayPortalController();

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
                            await storage.write(key: 'userId', value: null);

                            debugPrint('Reset complete');
                          },
                          child: Text('Reset userId to null'),
                        ),
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
                            await auth.signOut();
                          },
                          child: Text('Log Out'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            repository.addPrize(
                              001,
                              'assets/img/prizes/Sticker1.png',
                            );
                          },
                          child: Text('prize'),
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
                    overlayController,
                    taskType: TaskType.daily,
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
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [const DebugPrefsOverlay()],
      ),
    );
  }
}
