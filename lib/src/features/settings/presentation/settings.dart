import 'package:adhd_0_1/src/common/domain/task.dart';
import 'package:adhd_0_1/src/common/presentation/add_task_button.dart';
import 'package:adhd_0_1/src/features/settings/presentation/widgets/about.dart';
import 'package:adhd_0_1/src/features/settings/presentation/widgets/view_user_data.dart';
import 'package:adhd_0_1/src/features/task_management/presentation/widgets/add_task_widget.dart';
import 'package:adhd_0_1/src/common/presentation/sub_title.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/data/domain/reset_scheduler.dart';
import 'package:adhd_0_1/src/features/weekly_summery/presentation/widgets/weekly_summery_overlay.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/common/domain/skin.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/daily_quote_notifier.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/deadline_notifier.dart';

class _SkinOpt {
  final bool? value;
  final String label;
  const _SkinOpt(this.value, this.label);
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Saved settings bits we care about here
  String? _location;
  Weekday? _startOfWeek;
  TimeOfDay? _startOfDay;
  bool? _appSkinColor;
  final GlobalKey _locationBtnKey = GlobalKey();
  final GlobalKey _weekBtnKey = GlobalKey();
  final GlobalKey _dayBtnKey = GlobalKey();
  final GlobalKey _skinBtnKey = GlobalKey();
  final OverlayPortalController overlayControllerSummery =
      OverlayPortalController();
  final List<Prizes> weeklyPrizes = [];

  @override
  void initState() {
    super.initState();
    // Load saved settings to display current location
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = context.read<DataBaseRepository>();
      final s = await repo.getSettings();
      setState(() {
        _appSkinColor = s?.appSkinColor;
        _location = s?.location ?? 'Berlin';
        _startOfWeek = s?.startOfWeek ?? Weekday.mon;
        _startOfDay = s?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15);
      });
    });
  }

  // Map skin setting to asset path
  String _skinAsset(bool? skin) {
    if (skin == true) return 'assets/img/buttons/skin_true.png';
    if (skin == false) return 'assets/img/buttons/skin_false.png';
    return 'assets/img/buttons/skin_null.png';
  }

  Future<void> _pickSkin() async {
    final repo = context.read<DataBaseRepository>();
    final current = await repo.getSettings();

    // Anchor to the image container
    final RenderBox button =
        _skinBtnKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      button.localToGlobal(Offset.zero, ancestor: overlay) & button.size,
      Offset.zero & overlay.size,
    );

    final options = const [
      _SkinOpt(true, 'Pink'),
      _SkinOpt(null, 'White'),
      _SkinOpt(false, 'Blue'),
    ];

    final selected = await showMenu<_SkinOpt>(
      context: context,
      position: position,
      items:
          options
              .map(
                (o) => PopupMenuItem<_SkinOpt>(
                  value: o,
                  child: Text(
                    o.label,
                    style: TextStyle(color: Palette.basicBitchWhite),
                  ),
                ),
              )
              .toList(),
      color: Palette.monarchPurple2,
    );

    if (selected != null) {
      if (!mounted) return;
      final updated = await repo.setSettings(
        selected.value, // appSkinColor
        current?.language ?? 'English',
        current?.location ?? 'Berlin',
        current?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15),
        current?.startOfWeek ?? Weekday.mon,
      );
      if (!mounted) return;
      // Update local UI and notify background to refresh instantly
      setState(() => _appSkinColor = updated.appSkinColor);
      updateAppBgAsset(updated.appSkinColor);
    }
  }

  Future<void> _pickLocation() async {
    final repo = context.read<DataBaseRepository>();
    final current = await repo.getSettings();

    // Compute popup position anchored to the button
    final RenderBox button =
        _locationBtnKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      button.localToGlobal(Offset.zero, ancestor: overlay) & button.size,
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<WorldCapital>(
      context: context,
      position: position,
      items:
          WorldCapital.values.map((wc) {
            return PopupMenuItem<WorldCapital>(
              value: wc,
              child: Text(
                wc.label,
                style: TextStyle(color: Palette.basicBitchWhite),
              ),
            );
          }).toList(),
      color: Palette.monarchPurple2,
    );

    if (selected != null) {
      if (!mounted) return;
      // Persist keeping other fields intact
      final updated = await repo.setSettings(
        current?.appSkinColor,
        current?.language ?? 'English',
        selected.label,
        current?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15),
        current?.startOfWeek ?? Weekday.mon,
      );
      if (!mounted) return;
      setState(() => _location = updated.location);
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickStartOfWeek() async {
    final repo = context.read<DataBaseRepository>();
    final current = await repo.getSettings();

    final RenderBox button =
        _weekBtnKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      button.localToGlobal(Offset.zero, ancestor: overlay) & button.size,
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<Weekday>(
      context: context,
      position: position,
      items:
          Weekday.values.map((d) {
            return PopupMenuItem<Weekday>(
              value: d,
              child: Text(
                d.label,
                style: TextStyle(color: Palette.basicBitchWhite),
              ),
            );
          }).toList(),
      color: Palette.monarchPurple2,
    );

    if (selected != null) {
      if (!mounted) return;
      final updated = await repo.setSettings(
        current?.appSkinColor,
        current?.language ?? 'English',
        current?.location ?? 'Berlin',
        current?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15),
        selected,
      );
      if (!mounted) return;
      setState(() => _startOfWeek = updated.startOfWeek);
      await _confirmAndApplyResets();
    }
  }

  Future<void> _pickStartOfDay() async {
    final repo = context.read<DataBaseRepository>();
    final current = await repo.getSettings();
    final picked = await showTimePicker(
      context: context,
      initialTime: _startOfDay ?? (current?.startOfDay ?? TimeOfDay.now()),
    );
    if (picked != null) {
      if (!mounted) return;
      final updated = await repo.setSettings(
        current?.appSkinColor,
        current?.language ?? 'English',
        current?.location ?? 'Berlin',
        picked,
        current?.startOfWeek ?? Weekday.mon,
      );
      if (!mounted) return;
      setState(() => _startOfDay = updated.startOfDay);
      await _confirmAndApplyResets();
      // Immediately reschedule notifications to reflect new start-of-day
      try {
        await DailyQuoteNotifier.instance.scheduleDailyQuote(
          updated.startOfDay,
        );
      } catch (_) {}
      try {
        await DeadlineNotifier.instance.scheduleRelativeToDaily(
          updated.startOfDay,
          repo,
        );
      } catch (_) {}
    }
  }

  Future<void> _confirmAndApplyResets() async {
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Palette.monarchPurple2,
            title: Text(
              'Apply schedule changes now?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content: Text(
              'This may immediately reset today\'s or this week\'s tasks and recalculate prizes based on your new schedule.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Not now',
                  style: TextStyle(color: Palette.basicBitchWhite),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Apply now',
                  style: TextStyle(color: Palette.lightTeal),
                ),
              ),
            ],
          ),
    );

    if (proceed == true) {
      final repo = context.read<DataBaseRepository>();
      final resetScheduler = ResetScheduler(
        repo,
        controller: overlayControllerSummery,
        awardedPrizesHolder: weeklyPrizes,
      );
      await resetScheduler.performResetsIfNeeded();
    }
  }

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
    // final repository = context.read<DataBaseRepository>();
    // final auth = context.read<FirebaseAuthRepository>();

    OverlayPortalController overlayControllerUserData =
        OverlayPortalController();
    OverlayPortalController overlayControllerAbout = OverlayPortalController();

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
                          OverlayPortal(
                            controller: overlayControllerSummery,
                            overlayChildBuilder:
                                (_) => WeeklySummaryOverlay(
                                  prizes: weeklyPrizes,
                                  controller: overlayControllerSummery,
                                ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Choose your Flesh Prison',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: _pickSkin,
                                child: Container(
                                  key: _skinBtnKey,
                                  child: Image.asset(_skinAsset(_appSkinColor)),
                                ),
                              ),
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
                                key: _weekBtnKey,
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
                                onPressed: _pickStartOfWeek,
                                child: Text(
                                  _startOfWeek?.label ?? 'DAY',
                                  style: TextStyle(
                                    color: Palette.basicBitchWhite,
                                  ),
                                ),
                              ),
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
                                key: _dayBtnKey,
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
                                onPressed: _pickStartOfDay,
                                child: Text(
                                  _startOfDay != null
                                      ? _formatTime(_startOfDay!)
                                      : 'HH:MM',
                                  style: TextStyle(
                                    color: Palette.basicBitchWhite,
                                  ),
                                ),
                              ),
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
                                key: _locationBtnKey,
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
                                onPressed: _pickLocation,
                                child: Text(
                                  _location ?? 'Berlin',
                                  style: TextStyle(
                                    color: Palette.basicBitchWhite,
                                  ),
                                ),
                              ),
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
                            controller: overlayControllerUserData,
                            overlayChildBuilder: (BuildContext context) {
                              return ViewUserData(
                                onClose: () {
                                  overlayControllerUserData.toggle();
                                },
                              );
                            },
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  overlayControllerUserData.toggle();
                                },
                                child: Text(
                                  'View User Data',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Palette.lightTeal),
                                ),
                              ),
                            ],
                          ),
                          // Debug: iOS sound test trigger
                          // // // // // Row(
                          // // // // //   children: [
                          // // // // //     GestureDetector(
                          // // // // //       onTap: () async {
                          // // // // //         await DailyQuoteNotifier.instance
                          // // // // //             .showIosSoundTestNow();
                          // // // // //       },
                          // // // // //       child: Text(
                          // // // // //         'Test iOS notification sound',
                          // // // // //         style: Theme.of(context).textTheme.bodyMedium
                          // // // // //             ?.copyWith(color: Palette.lightTeal),
                          // // // // //       ),
                          // // // // //     ),
                          // // // // //   ],
                          // // // // // ),
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
                          OverlayPortal(
                            controller: overlayControllerAbout,
                            overlayChildBuilder: (BuildContext context) {
                              return About(
                                onClose: () {
                                  overlayControllerAbout.toggle();
                                },
                              );
                            },
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  overlayControllerAbout.toggle();
                                },
                                child: Text(
                                  'About',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Palette.lightTeal),
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
