import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:flutter/material.dart';

class FidgetScreen extends StatefulWidget {
  const FidgetScreen({super.key});

  @override
  State<FidgetScreen> createState() => _FidgetScreenState();
}

class _FidgetScreenState extends State<FidgetScreen> {
  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            SubTitle(sub: 'Fidget Screen'),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 492,
                    width: 304,
                    child: Column(
                      spacing: 2,
                      children: [
                        SizedBox(height: 150),
                        Text(
                          'No fidget here',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          'Get back to work!',
                          style: Theme.of(context).textTheme.displayMedium,
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
    );
  }
}
