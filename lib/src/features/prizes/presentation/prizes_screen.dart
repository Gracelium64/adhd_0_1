import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prize_overlay.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prizes_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PrizesScreen extends StatefulWidget {
  const PrizesScreen({super.key});

  @override
  State<PrizesScreen> createState() => _PrizesScreenState();
}

class _PrizesScreenState extends State<PrizesScreen> {
  Future<void> _sharePrizeImageAndClose(String imagePath) async {
    if (!mounted) return;
    final byteData = await DefaultAssetBundle.of(context).load(imagePath);
    final buffer = byteData.buffer;
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/shared_prize.png');
    await file.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Look! A.. Not sure what this is actually...',
      ),
    );
    if (overlayControllerPrize.isShowing) {
      overlayControllerPrize.hide();
    }
  }

  void _showAddTaskOverlay() {
    if (!mounted) return;
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
                  onTap: _showAddTaskOverlay,
                  child: AddTaskButton(),
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
                onShare: () async {
                  debugPrint('SHARE TAP ✅: $selectedPrizeUrl');
                  await _sharePrizeImageAndClose(selectedPrizeUrl);
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
