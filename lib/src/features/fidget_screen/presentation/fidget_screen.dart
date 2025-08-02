import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FidgetScreen extends StatefulWidget {
  const FidgetScreen({super.key});

  @override
  State<FidgetScreen> createState() => _FidgetScreenState();
}

class _FidgetScreenState extends State<FidgetScreen> {
OverlayEntry? _overlayEntry;
  void _showAddTaskOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {}, // absorb taps
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                ModalBarrier(dismissible: false),
                Center(
                  child: AddTaskWidget(
                    taskType: TaskType.daily,
                    onClose: _closeAddTaskOverlay,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(milliseconds: 50), () {
      Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    });
  }

  void _closeAddTaskOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      myList = context.read<DataBaseRepository>().getDailyTasks();
    });
  }

  late Future<List<Task>> myList;



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
                  onTap: _showAddTaskOverlay,
                  child: AddTaskButton(),
                ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
