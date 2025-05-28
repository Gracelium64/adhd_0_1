import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:flutter/material.dart';

class FridgeLock extends StatelessWidget {
  final DataBaseRepository repository;

  const FridgeLock(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    OverlayPortalController overlayController = OverlayPortalController();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
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
                    spacing: 2,
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
    );
  }
}
