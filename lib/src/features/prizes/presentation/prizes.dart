import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prize_overlay.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prizes_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Prizes extends StatefulWidget {
  const Prizes({super.key});

  @override
  State<Prizes> createState() => _PrizesState();
}

class _PrizesState extends State<Prizes> {
  final overlayController = OverlayPortalController();
  final overlayControllerPrize = OverlayPortalController();
  String selectedPrizeUrl = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                      child: Column(
                        children: [
                          SizedBox(
                            height: 492,
                            width: 304,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: PrizesWidget((prize) {
                                setState(() {
                                  selectedPrizeUrl = prize.prizeUrl;
                                });

                                Future.delayed(Duration(milliseconds: 10), () {
                                  if (!overlayControllerPrize.isShowing) {
                                    overlayControllerPrize.show();
                                  }
                                });
                              }),
                            ),
                          ),
                        ],
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
                    overlayChildBuilder:
                        (_) => AddTaskWidget(
                          overlayController,
                          taskType: TaskType.daily,
                          onClose: () => overlayController.hide(),
                        ),
                    child: AddTaskButton(),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        
        OverlayPortal(
          controller: overlayControllerPrize,
          overlayChildBuilder:
              (_) => PrizeOverlay(
                prizeImageUrl: selectedPrizeUrl,
                onShare: () {
                  debugPrint('SHARE TAP ✅: $selectedPrizeUrl');
                  // Implement actual share logic
                },
                onClose: () {
                  debugPrint('OVERLAY CLOSED');
                  overlayControllerPrize.hide();
                },
              ),
        ),
      ],
    );
  }
}
