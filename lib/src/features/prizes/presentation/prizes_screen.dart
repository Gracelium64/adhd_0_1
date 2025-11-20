import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prize_overlay.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/common/presentation/title_gaps.dart';
import 'package:gap/gap.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/widgets/prizes_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrizesScreen extends StatefulWidget {
  const PrizesScreen({super.key});

  @override
  State<PrizesScreen> createState() => _PrizesScreenState();
}

class _PrizesScreenState extends State<PrizesScreen> {
  final GlobalKey _captureKey = GlobalKey();

  Future<void> _sharePrizeImageAndClose(String imagePath) async {
    if (!mounted) return;
    // Try capturing the composited image (with duplicate badge)
    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        if (!mounted) return;
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (!mounted) return;
        if (byteData != null) {
          final Uint8List pngBytes = byteData.buffer.asUint8List();
          final tempDir = Directory.systemTemp;
          final file = File('${tempDir.path}/shared_prize.png');
          await file.writeAsBytes(pngBytes);
          await Future.delayed(const Duration(milliseconds: 150));
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
          return;
        }
      }
    } catch (_) {
      // fall through to asset fallback
    }

    // Fallback: share the raw asset (avoid context after awaits)
    final byteData = await rootBundle.load(imagePath);
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
  Prizes? selectedPrize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              children: [
                Gap(subtitleTopGap(context)),
                SubTitle(sub: 'Prizes'),
                Gap(subtitleBottomGap(context)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 48, 0, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 492,
                            width: MediaQuery.of(context).size.width - 85,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: PrizesWidget((prize) {
                                setState(() {
                                  selectedPrize = prize;
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
              (_) =>
                  selectedPrize == null
                      ? const SizedBox.shrink()
                      : PrizeOverlay(
                        prizeId: selectedPrize!.prizeId,
                        prizeImageUrl: selectedPrize!.prizeUrl,
                        captureKey: _captureKey,
                        onShare: () async {
                          debugPrint('SHARE TAP ✅: ${selectedPrize!.prizeUrl}');
                          await _sharePrizeImageAndClose(
                            selectedPrize!.prizeUrl,
                          );
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
