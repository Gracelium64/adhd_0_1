import 'dart:async';
import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/presentation/app_bg.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';
import 'package:adhd_0_1/src/data/domain/reset_scheduler.dart';
import 'package:adhd_0_1/src/features/tasks_dailys/presentation/dailys.dart';
import 'package:adhd_0_1/src/features/tasks_deadlineys/presentation/deadlineys.dart';
import 'package:adhd_0_1/src/features/fidget_screen/presentation/fidget_screen.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/prizes_screen.dart';
import 'package:adhd_0_1/src/features/tasks_quest/presentation/quest.dart';
import 'package:adhd_0_1/src/features/settings/presentation/settings.dart';
import 'package:adhd_0_1/src/features/tutorial/presentation/tutorial.dart';
import 'package:adhd_0_1/src/features/tasks_weeklys/presentation/weeklys.dart';
import 'package:adhd_0_1/src/features/weekly_summery/presentation/widgets/weekly_summery_overlay.dart';
import 'package:adhd_0_1/src/features/morning_greeting/presentation/widgets/daily_start_overlay.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/daily_quote_notifier.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/navigation/notification_router.dart';
import 'package:flutter/services.dart';
import 'package:adhd_0_1/src/common/domain/refresh_bus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/common/domain/progress_triggers.dart';
import 'package:adhd_0_1/src/data/domain/prefs_keys.dart';
import 'dart:io' show Platform;

class MainScreen extends StatefulWidget {
  final bool showTutorial;

  const MainScreen({super.key, this.showTutorial = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _PostRegistrationPrefsResult {
  const _PostRegistrationPrefsResult({
    required this.remoteOptOut,
    required this.silentNotification,
  });

  final bool remoteOptOut;
  final bool silentNotification;
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  OverlayPortalController overlayControllerTutorial = OverlayPortalController();
  OverlayPortalController overlayControllerSummery = OverlayPortalController();
  OverlayPortalController overlayControllerDailyStart =
      OverlayPortalController();
  int _pageIndex = 1;
  final List<Prizes> weeklyPrizes = [];
  Timer? _dayWatcher;
  DateTime _lastDay = DateTime.now();
  late final VoidCallback _notifListener;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndroidInitialRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showTutorial) {
        overlayControllerTutorial.show();
      }
      unawaited(_maybeShowPostRegistrationDialog());
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

  Future<void> _maybeShowPostRegistrationDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final pending =
        prefs.getBool(PrefsKeys.postRegistrationPrefsPendingKey) ?? false;
    if (!pending || !mounted) return;

    final bool initialSilentNotification =
        prefs.getBool(PrefsKeys.silentNotificationKey) ?? false;

    final repoBase = context.read<DataBaseRepository>();
    final syncRepo = repoBase is SyncRepository ? repoBase : null;

    bool remoteOptOut = false;
    try {
      if (syncRepo != null) {
        remoteOptOut = await syncRepo.getRemoteWriteOptOut();
      }
    } catch (_) {}

    if (!mounted) return;
    var optOutValue = remoteOptOut;
    var silentValue = initialSilentNotification;

    final result = await showDialog<_PostRegistrationPrefsResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Palette.monarchPurple2,
              title: Text(
                'Set up your backups',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    value: optOutValue,
                    onChanged: (value) => setState(() => optOutValue = value),
                    contentPadding: EdgeInsets.zero,
                    activeColor: Palette.lightTeal,
                    title: Text(
                      'Opt out of Firebase backup',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      'Keep everything on this device only.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Palette.lightTeal),
                    ),
                  ),
                  SwitchListTile.adaptive(
                    value: silentValue,
                    onChanged: (value) => setState(() => silentValue = value),
                    contentPadding: EdgeInsets.zero,
                    activeColor: Palette.lightTeal,
                    title: Text(
                      'Silent daily notification',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      'Disable sound for the daily quote.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Palette.lightTeal),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(
                    'Maybe later',
                    style: TextStyle(color: Palette.basicBitchWhite),
                  ),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.of(ctx).pop(
                        _PostRegistrationPrefsResult(
                          remoteOptOut: optOutValue,
                          silentNotification: silentValue,
                        ),
                      ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Palette.lightTeal),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    await prefs.setBool(PrefsKeys.postRegistrationPrefsPendingKey, false);

    if (!mounted || result == null) return;

    // Always persist the silent daily notification pref (local only)
    try {
      await prefs.setBool(
        PrefsKeys.silentNotificationKey,
        result.silentNotification,
      );
    } catch (_) {}

    // Sync Android native alarms/receivers as well.
    if (Platform.isAndroid) {
      try {
        const platform = MethodChannel('shadowapp.grace6424.adhd/alarm');
        await platform.invokeMethod('setSilentNotification', {
          'value': result.silentNotification,
        });
      } catch (_) {}
    }

    // Split the operations so we can pinpoint which one fails.
    if (syncRepo != null && result.remoteOptOut != remoteOptOut) {
      try {
        await syncRepo.setRemoteWriteOptOut(result.remoteOptOut);
      } catch (e, stack) {
        debugPrint('❌ Failed to persist remoteOptOut preference: $e');
        debugPrint(stack.toString());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not update Firebase backup preference: $e',
              style: Theme.of(context).snackBarTheme.contentTextStyle,
            ),
          ),
        );
        return;
      }
    }

    try {
      await DailyQuoteNotifier.instance.rescheduleFromRepository(repoBase);
    } catch (e, stack) {
      debugPrint(
        '❌ Failed to reschedule daily notifications after onboarding: $e',
      );
      debugPrint(stack.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not reschedule notifications: $e',
            style: Theme.of(context).snackBarTheme.contentTextStyle,
          ),
        ),
      );
    }
  }

  Future<void> performResetsIfNeeded() async {
    if (_isResetting) return;
    _isResetting = true;
    try {
      final repository = context.read<DataBaseRepository>();
      final refreshBus = context.read<RefreshBus>();
      final resetScheduler = ResetScheduler(
        repository,
        controller: overlayControllerSummery,
        awardedPrizesHolder: weeklyPrizes,
      );
      await resetScheduler.performResetsIfNeeded();
      if (!mounted) return;
      // If weekly summary is being shown, immediately hide the daily start overlay
      if (overlayControllerSummery.isShowing &&
          overlayControllerDailyStart.isShowing) {
        overlayControllerDailyStart.hide();
      }
      // Force refetch in task lists and rebuild (updates isDone visuals)
      refreshBus.bump();
      setState(() {});
      // After daily reset, show morning overlay once when app opens or day changes
      // Only show if lastDailyReset is recent and hasn't been shown yet for that reset
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastDaily = prefs.getString('lastDailyReset');
        if (lastDaily != null) {
          final when = DateTime.tryParse(lastDaily);
          if (when != null) {
            final diff = DateTime.now().difference(when).inMinutes;
            final lastShownMarker = prefs.getString('dailyStartShownAt');
            final notShownForThisReset = lastShownMarker != lastDaily;
            if (diff >= 0 && diff <= 10 && notShownForThisReset) {
              // If weekly summary is visible or prizes were awarded (likely to show), skip DailyStart
              if (overlayControllerSummery.isShowing ||
                  weeklyPrizes.isNotEmpty) {
                await prefs.setString('dailyStartShownAt', lastDaily);
                return;
              }
              // ensure weekly progress notifier is fresh
              await refreshWeeklyProgress(repository);
              if (!overlayControllerDailyStart.isShowing &&
                  !overlayControllerSummery.isShowing) {
                overlayControllerDailyStart.show();
              }
              await prefs.setString('dailyStartShownAt', lastDaily);
            }
          }
        }
      } catch (_) {}
    } finally {
      _isResetting = false;
    }
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
      const String channel = 'shadowapp.grace6424.adhd/alarm';
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

  Future<void> _ensureAndroidNotificationHealth() async {
    try {
      const String channel = 'shadowapp.grace6424.adhd/alarm';
      final platform = const MethodChannel(channel);
      // Nudge settings if notifications disabled
      final android =
          FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final enabled = await android?.areNotificationsEnabled() ?? true;
      if (!enabled) {
        await platform.invokeMethod('openAppNotificationSettings');
        return;
      }
      // Suggest ignoring battery optimizations
      final bool ignoring = await platform.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );
      if (!ignoring) {
        await platform.invokeMethod('requestIgnoreBatteryOptimizations');
      }
      // Request exact alarm if missing
      final dynamic allowed = await platform.invokeMethod(
        'hasExactAlarmPermission',
      );
      if (allowed is bool && !allowed) {
        await platform.invokeMethod('requestExactAlarmPermission');
      }
    } catch (_) {}
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
      // // // // // // // // // FridgeLock(),
      FidgetScreen(),
      PrizesScreen(),
      Settings(),
    ];

    // Android: proactively ensure notification health when app opens to help with OEM restrictions
    _ensureAndroidNotificationHealth();
    return Stack(
      children: [
        AppBg(repository),
        // Tiny sync status indicator (bottom-left)
        Positioned(
          bottom: 8,
          left: 8,
          child: _SyncStatusPill(),
        ),
        OverlayPortal(
          controller: overlayControllerTutorial,
          overlayChildBuilder: (context) => Tutorial(overlayControllerTutorial),
          child: SizedBox.shrink(),
        ),
        OverlayPortal(
          controller: overlayControllerSummery,
          overlayChildBuilder: (_) {
            // Defensive: if weekly summary is opening, ensure daily start is hidden
            if (overlayControllerDailyStart.isShowing) {
              overlayControllerDailyStart.hide();
            }
            return WeeklySummaryOverlay(
              key: UniqueKey(),
              prizes: weeklyPrizes,
              controller: overlayControllerSummery,
              repository: repository,
            );
          },
        ),
        OverlayPortal(
          controller: overlayControllerDailyStart,
          overlayChildBuilder:
              (_) => DailyStartOverlay(
                controller: overlayControllerDailyStart,
                repository: repository,
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
                        // // // // // // // NavigationRailDestination(
                        // // // // // // //   padding: EdgeInsets.only(bottom: 8),
                        // // // // // // //   icon: Image.asset('assets/img/sidebar/fridge.png'),
                        // // // // // // //   label: Text(''),
                        // // // // // // // ),
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

class _SyncStatusPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = context.read<DataBaseRepository>();
    if (db is! SyncRepository) return const SizedBox.shrink();
    final sync = db;
    return ValueListenableBuilder<bool>(
      valueListenable: sync.isSyncingNotifier,
      builder: (_, isSyncing, __) {
        // Show nothing when idle
        if (!isSyncing) return const SizedBox.shrink();
        // Minimal unobtrusive pill with a tiny spinner
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(140),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Syncing…',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
