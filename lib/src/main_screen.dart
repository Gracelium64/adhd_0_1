import 'dart:async';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/presentation/app_bg.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/reset_scheduler.dart';
import 'package:adhd_0_1/src/features/tasks_dailys/presentation/dailys.dart';
import 'package:adhd_0_1/src/features/tasks_deadlineys/presentation/deadlineys.dart';
import 'package:adhd_0_1/src/features/fidget_screen/presentation/fidget_screen.dart';
import 'package:adhd_0_1/src/features/fridge_lock/presentation/fridge_lock.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/prizes_screen.dart';
import 'package:adhd_0_1/src/features/tasks_quest/presentation/quest.dart';
import 'package:adhd_0_1/src/features/settings/presentation/settings.dart';
import 'package:adhd_0_1/src/features/tutorial/presentation/tutorial.dart';
import 'package:adhd_0_1/src/features/tasks_weeklys/presentation/weeklys.dart';
import 'package:adhd_0_1/src/features/weekly_summery/presentation/widgets/weekly_summery_overlay.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/navigation/notification_router.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  final bool showTutorial;

  const MainScreen({super.key, this.showTutorial = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  OverlayPortalController overlayControllerTutorial = OverlayPortalController();
  OverlayPortalController overlayControllerSummery = OverlayPortalController();
  int _pageIndex = 1;
  final List<Prizes> weeklyPrizes = [];
  Timer? _dayWatcher;
  DateTime _lastDay = DateTime.now();
  late final VoidCallback _notifListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndroidInitialRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showTutorial) {
        overlayControllerTutorial.show();
      }
    });
    performResetsIfNeeded();
    _startDayWatcher();

    // Listen for notification tap requests to open Dailys tab
    _notifListener = () {
      if (NotificationRouter.instance.openDailysRequested.value) {
        setState(() => _pageIndex = 1); // Dailys tab index
        // reset the flag immediately so subsequent opens work
        NotificationRouter.instance.openDailysRequested.value = false;
      }
    };
    NotificationRouter.instance.openDailysRequested.addListener(_notifListener);
  }

  void _startDayWatcher() {
    _dayWatcher?.cancel();
    _lastDay = DateTime.now();
    _dayWatcher = Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      final changed =
          now.year != _lastDay.year ||
          now.month != _lastDay.month ||
          now.day != _lastDay.day;
      if (changed) {
        _lastDay = now;
        await performResetsIfNeeded();
      }
    });
  }

  Future<void> performResetsIfNeeded() async {
    final repository = context.read<DataBaseRepository>();
    final resetScheduler = ResetScheduler(
      repository,
      controller: overlayControllerSummery,
      awardedPrizesHolder: weeklyPrizes,
    );
    await resetScheduler.performResetsIfNeeded();
    if (!mounted) return;
    // Force a rebuild so task lists refetch after reset (updates isDone visuals)
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // On resume, ensure we catch up on any missed day change
      performResetsIfNeeded();
      _checkAndroidInitialRoute();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayWatcher?.cancel();
    NotificationRouter.instance.openDailysRequested.removeListener(
      _notifListener,
    );
    super.dispose();
  }

  Future<void> _checkAndroidInitialRoute() async {
    // Android-only hook: check if MainActivity provided an initial route from a notification tap
    try {
      const String channel = 'shadowapp.grace6424.adhd01/alarm';
      final platform = const MethodChannel(channel);
      final String? route = await platform.invokeMethod<String>(
        'getInitialRouteFromIntent',
      );
      if (route == 'dailys') {
        if (mounted) setState(() => _pageIndex = 1);
      }
    } catch (_) {
      // no-op on iOS or if method not available
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    Size screenSize = MediaQuery.of(context).size;

    List<Widget> pages = [
      Tutorial(overlayControllerTutorial),
      Dailys(),
      Weeklys(),
      Deadlineys(),
      Quest(),
      FridgeLock(),
      FidgetScreen(),
      PrizesScreen(),
      Settings(),
    ];

    return Stack(
      children: [
        AppBg(repository),
        OverlayPortal(
          controller: overlayControllerTutorial,
          overlayChildBuilder: (context) => Tutorial(overlayControllerTutorial),
          child: SizedBox.shrink(),
        ),
        OverlayPortal(
          controller: overlayControllerSummery,
          overlayChildBuilder:
              (_) => WeeklySummaryOverlay(
                prizes: weeklyPrizes,
                controller: overlayControllerSummery,
              ),
        ),
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 50,

                    height: double.infinity,
                    child: NavigationRail(
                      leading: SizedBox(height: 40),
                      selectedIndex: _pageIndex,
                      indicatorColor: Palette.highlight,
                      indicatorShape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      onDestinationSelected: (int index) {
                        if (index == 0) {
                          overlayControllerTutorial.toggle();
                        } else {
                          setState(() => _pageIndex = index);
                        }
                      },
                      backgroundColor: Colors.transparent,
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset(
                            'assets/img/sidebar/oi.png',
                            width: 30,
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: Image.asset('assets/img/sidebar/daily.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: Image.asset('assets/img/sidebar/week.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/clock.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                            child: Image.asset('assets/img/sidebar/star.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/fridge.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: Image.asset('assets/img/sidebar/fidget.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/prize.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Image.asset(
                              'assets/img/sidebar/hamburger.png',
                            ),
                          ),
                          label: Text(''),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SizedBox(
                      height: screenSize.height / 1.12,
                      width: screenSize.width,
                      child: Center(child: pages[_pageIndex]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
