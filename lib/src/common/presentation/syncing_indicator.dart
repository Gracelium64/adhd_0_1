import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';

/// Shows a small, consistent syncing indicator when the app is performing
/// a background sync (SyncRepository.isSyncingNotifier == true). Otherwise
/// falls back to a normal CircularProgressIndicator so existing loading
/// affordances continue to work.
class SyncingIndicator extends StatelessWidget {
  final bool centered;
  final double? size;
  final double strokeWidth;

  const SyncingIndicator({
    super.key,
    this.centered = false,
    this.size,
    this.strokeWidth = 2.0,
  });

  Widget _buildSpinner() {
    final s = size ?? 24.0;
    return SizedBox(
      width: s,
      height: s,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
      ),
    );
  }

  Widget _buildPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(140),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Syncing…',
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Expect a DataBaseRepository to be provided at the app root (main.dart)
    final db = Provider.of<DataBaseRepository>(context, listen: false);
    if (db is SyncRepository) {
      final syncRepo = db;
      return ValueListenableBuilder<bool>(
        valueListenable: syncRepo.isSyncingNotifier,
        builder: (_, isSyncing, __) {
          if (isSyncing) {
            final pill = _buildPill();
            return centered ? Center(child: pill) : pill;
          }
          final spinner = _buildSpinner();
          return centered ? Center(child: spinner) : spinner;
        },
      );
    }

    final spinner = _buildSpinner();
    return centered ? Center(child: spinner) : spinner;
  }
}
