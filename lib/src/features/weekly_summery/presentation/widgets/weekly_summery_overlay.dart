import 'dart:ui';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/common/presentation/syncing_indicator.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:adhd_0_1/src/common/domain/prizes.dart';

class WeeklySummaryOverlay extends StatefulWidget {
  final List<Prizes> prizes;
  final OverlayPortalController controller;

  const WeeklySummaryOverlay({
    super.key,
    required this.prizes,
    required this.controller,
  });

  @override
  State<WeeklySummaryOverlay> createState() => _WeeklySummaryOverlayState();
}

class _WeeklySummaryOverlayState extends State<WeeklySummaryOverlay> {
  bool _showDebug = false;
  late final Future<Map<String, dynamic>> _summaryFuture;
  Map<String, dynamic>? _cachedSummary;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchWithTimeout();
  }

  @override
  void didUpdateWidget(covariant WeeklySummaryOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If prizes reference changed or overlay was toggled anew, refresh once
    if (!identical(oldWidget.prizes, widget.prizes)) {
      _summaryFuture = _fetchWithTimeout();
    }
  }

  // Styled line for debug entries that doesn't disrupt the main UI styling
  Widget _debugLine(BuildContext context, String label, String value) {
    final base =
        Theme.of(context).textTheme.bodySmall ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 12);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: base.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: base,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Themed debug section to preserve the older summary styling even in debug mode
  Widget _buildDebugSection(BuildContext context, Map<String, dynamic> data) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.basicBitchWhite.withAlpha(32),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Palette.lightTeal.withAlpha(80),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug',
              style: (Theme.of(context).textTheme.titleSmall ??
                      Theme.of(context).textTheme.titleMedium ??
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ))
                  .copyWith(color: Palette.lightTeal),
            ),
            const SizedBox(height: 6),
            _debugLine(
              context,
              'daily (last-day counters)',
              '${data['dailyCompleted']}/${data['dailyTotal']}',
            ),
            _debugLine(
              context,
              'dailyAvg (weekly)',
              '${(data['dailyAvg'] as double).toStringAsFixed(2)} (sum=${(data['dailyWeekSum'] as double).toStringAsFixed(2)}, n=${data['dailyWeekCount']})',
            ),
            _debugLine(
              context,
              'weekly',
              '${data['weeklyCompleted']}/${data['weeklyTotal']}',
            ),
            _debugLine(
              context,
              'quests',
              '${data['questCompleted']}',
            ),
            _debugLine(
              context,
              'deadlines',
              '${data['deadlineCompleted']}',
            ),
            _debugLine(
              context,
              'calc prizes vs awarded',
              '${data['prizesToGiveCalc']} / ${widget.prizes.length}',
            ),
            _debugLine(
              context,
              'weeklyRewardGiven',
              '${data['weeklyRewardGiven']}',
            ),
            _debugLine(
              context,
              'lastWeeklyReset',
              '${data['lastWeeklyReset'] ?? '-'}',
            ),
            _debugLine(
              context,
              'lastDailyReset',
              '${data['lastDailyReset'] ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchSummaryData() async {
    final prefs = await SharedPreferences.getInstance();
    // Prefer last-week snapshot if present (immediately after reset)
    final dailyCompleted = prefs.getInt('dailyCompleted') ?? 0;
    final dailyTotal = prefs.getInt('dailyTotal') ?? 1;
    final weeklyCompleted =
        prefs.getInt('lastWeeklyCompleted') ??
        prefs.getInt('weeklyCompleted') ??
        0;
    final weeklyTotal =
        prefs.getInt('lastWeeklyTotal') ?? prefs.getInt('weeklyTotal') ?? 1;
    final questCompleted =
        prefs.getInt('lastQuestCompleted') ??
        prefs.getInt('questCompleted') ??
        0;
    final deadlineCompleted =
        prefs.getInt('lastDeadlineCompleted') ??
        prefs.getInt('deadlineCompleted') ??
        0;
    final weeklyRewardGiven = prefs.getBool('weeklyRewardGiven') ?? false;
    final lastWeeklyReset = prefs.getString('lastWeeklyReset');
    final lastDailyReset = prefs.getString('lastDailyReset');
    // Weekly-averaged daily completion
    final dailyWeekSum =
        prefs.getDouble('lastDailyWeekSum') ??
        prefs.getDouble('dailyWeekSum') ??
        0.0;
    final dailyWeekCount =
        prefs.getInt('lastDailyWeekCount') ??
        prefs.getInt('dailyWeekCount') ??
        0;
    final dailyAvg =
        dailyWeekCount == 0 ? 0.0 : (dailyWeekSum / dailyWeekCount);
    final weeklyRatio =
        (weeklyCompleted / (weeklyTotal == 0 ? 1 : weeklyTotal));

    // Local recompute of prize count for transparency
    int prizesToGive = 0;
    if (dailyAvg >= 0.75) prizesToGive++;
    if (weeklyRatio >= 0.75) prizesToGive++;
    prizesToGive += questCompleted + deadlineCompleted;

    final dailyPct = ((dailyAvg * 100).round()).clamp(0, 100);
    final weeklyPct = ((weeklyRatio * 100).round()).clamp(0, 100);

    return {
      'dailyCompleted': dailyCompleted,
      'dailyTotal': dailyTotal,
      'dailyWeekSum': dailyWeekSum,
      'dailyWeekCount': dailyWeekCount,
      'dailyAvg': dailyAvg,
      'weeklyCompleted': weeklyCompleted,
      'weeklyTotal': weeklyTotal,
      'questCompleted': questCompleted,
      'deadlineCompleted': deadlineCompleted,
      'weeklyRewardGiven': weeklyRewardGiven,
      'lastWeeklyReset': lastWeeklyReset,
      'lastDailyReset': lastDailyReset,
      'dailyRatioPct': dailyPct,
      'weeklyRatioPct': weeklyPct,
      'prizesToGiveCalc': prizesToGive,
    };
  }

  // Wrap data fetch with a timeout to avoid a stuck loading spinner
  Future<Map<String, dynamic>> _fetchWithTimeout() async {
    try {
      return await _fetchSummaryData().timeout(const Duration(seconds: 2));
    } catch (_) {
      return {
        'dailyCompleted': 0,
        'dailyTotal': 1,
        'weeklyCompleted': 0,
        'weeklyTotal': 1,
        'questCompleted': 0,
        'deadlineCompleted': 0,
        'weeklyRewardGiven': false,
        'lastWeeklyReset': null,
        'lastDailyReset': null,
        'dailyRatioPct': 0,
        'weeklyRatioPct': 0,
        'prizesToGiveCalc': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute a responsive height to avoid bottom overflow on small screens
    final media = MediaQuery.of(context);
    final safeHeight =
        media.size.height - media.padding.top - media.padding.bottom - 32;
    final double containerHeight =
        safeHeight < 420 ? 420 : (safeHeight > 600 ? 600 : safeHeight);

    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          width: 320,
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Palette.basicBitchWhite.withAlpha(175),
                offset: const Offset(-0, -0),
                blurRadius: 5,
                blurStyle: BlurStyle.inner,
              ),
              BoxShadow(
                color: Palette.basicBitchBlack.withAlpha(125),
                offset: const Offset(4, 4),
                blurRadius: 5,
              ),
              BoxShadow(
                color: Palette.monarchPurple1Opacity,
                offset: const Offset(0, 0),
                blurRadius: 20,
                blurStyle: BlurStyle.solid,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && _cachedSummary == null) {
                _cachedSummary = Map<String, dynamic>.from(snapshot.data!);
              }
              if (_cachedSummary == null) {
                // Fallback on error to avoid permanent spinner
                if (snapshot.hasError) {
                  _cachedSummary = {
                    'dailyRatioPct': 0,
                    'weeklyRatioPct': 0,
                    'questCompleted': 0,
                    'deadlineCompleted': 0,
                  };
                }
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: SyncingIndicator(),
                      ),
                      const SizedBox(height: 12),
                      const Text('Preparing your weekly summary...'),
                    ],
                  ),
                );
              }

              final data = _cachedSummary!;
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(24),
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: Image.asset(
                        'assets/img/icons/icon_transparent.png',
                      ),
                    ),
                    Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Weekly Summary',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium!.copyWith(fontSize: 32),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),

                        _showDebug
                            ? IconButton(
                              tooltip: _showDebug ? 'Hide debug' : 'Show debug',
                              onPressed:
                                  () =>
                                      setState(() => _showDebug = !_showDebug),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              iconSize: 18,
                              icon: Icon(
                                _showDebug
                                    ? Icons.bug_report
                                    : Icons.bug_report_outlined,
                                color: Palette.lightTeal,
                              ),
                            )
                            : Gap(0),
                      ],
                    ),
                    const Gap(8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Daily Completion Rate: ${data['dailyRatioPct']}%',
                            ),
                            Text(
                              'Weekly Completion Rate: ${data['weeklyRatioPct']}%',
                            ),
                            if ((data['questCompleted'] as int) > 0)
                              Text(
                                'Quests Completed: ${data['questCompleted']}',
                              ),
                            if ((data['deadlineCompleted'] as int) > 0)
                              Text(
                                'Deadlines Completed: ${data['deadlineCompleted']}',
                              ),
                            const Gap(8),
                            if (_showDebug) _buildDebugSection(context, data),
                            const Gap(8),
                            const Text("For this you're earned:"),
                            const Gap(8),
                            if (widget.prizes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No prizes this week yet. Keep going! \u2728',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children:
                                    widget.prizes
                                        .map(
                                          (prize) =>
                                              Image.asset(prize.prizeUrl),
                                        )
                                        .toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      child: SizedBox(
                        height: 48,
                        width: 64,
                        child: ConfirmButton(
                          onPressed: () => widget.controller.toggle(),
                        ),
                      ),
                    ),
                    Gap(40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
