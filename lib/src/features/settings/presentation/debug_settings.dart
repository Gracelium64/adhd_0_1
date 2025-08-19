import 'package:flutter/material.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/reset_scheduler.dart';
import 'package:adhd_0_1/src/common/domain/refresh_bus.dart';

class DebugSettings extends StatefulWidget {
  const DebugSettings({super.key});

  @override
  State<DebugSettings> createState() => _DebugSettingsState();
}

class _DebugSettingsState extends State<DebugSettings> {
  bool _showBorders = false;
  String _status = '';

  Future<void> _runDailyResetNow() async {
    final repo = context.read<DataBaseRepository>();
    final scheduler = ResetScheduler(
      repo,
      controller: null,
      awardedPrizesHolder: [],
    );
    await scheduler.performDebugResetsNow();
    if (!mounted) return;
    context.read<RefreshBus>().bump();
    setState(() => _status = 'Ran resets');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Palette.monarchPurple2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _showBorders ? Colors.redAccent : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Debug Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _showBorders,
                  onChanged: (v) => setState(() => _showBorders = v),
                  title: const Text('Show debug borders'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _runDailyResetNow,
                  child: const Text('Run resets now'),
                ),
                if (_status.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
