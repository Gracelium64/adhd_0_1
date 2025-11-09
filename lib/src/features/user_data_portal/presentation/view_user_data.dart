import 'dart:convert';
import 'dart:ui';

import 'package:adhd_0_1/src/common/domain/prizes.dart';
import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/syncing_indicator.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';
import 'package:adhd_0_1/src/features/settings/presentation/widgets/load_saved_game.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/io/file_system_helper.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/user_data_service.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/user_data_snapshot.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ViewUserData extends StatefulWidget {
  final VoidCallback onClose;

  const ViewUserData({super.key, required this.onClose});

  @override
  State<ViewUserData> createState() => _ViewUserDataState();
}

class _ViewUserDataState extends State<ViewUserData> {
  String? _userName;
  String? _password;
  String? _email;
  String? _identifier;
  bool _remoteOptOut = false;
  bool _busy = false;
  Prizes? _lastBonusPrize;
  DateTime? _lastExportedAt;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  SyncRepository _syncRepo(BuildContext context) {
    final repo = context.read<DataBaseRepository>();
    if (repo is SyncRepository) return repo;
    throw StateError('SyncRepository not available in provider tree.');
  }

  UserDataService _service(BuildContext context) {
    return UserDataService(repository: _syncRepo(context));
  }

  Future<void> _loadInitialData() async {
    try {
      final repo = _syncRepo(context);
      final storage = const FlutterSecureStorage();
      final userName = await storage.read(key: 'userId');
      final password = await storage.read(key: 'password');
      final email = await storage.read(key: 'email');
      final storedIdentifier = await storage.read(key: 'firebaseUid');
      final remoteOptOut = await repo.getRemoteWriteOptOut();
      String? identifier = storedIdentifier;
      identifier ??= FirebaseAuth.instance.currentUser?.uid;
      if (!mounted) return;
      setState(() {
        _userName = userName;
        _password = password;
        _email = email;
        _identifier = identifier;
        _remoteOptOut = remoteOptOut;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to load user data: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).snackBarTheme.contentTextStyle,
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    if (kIsWeb) {
      _showSnackBar('Saving backups is not supported on web yet.');
      return;
    }
    setState(() => _busy = true);
    try {
      final service = _service(context);
      final snapshot = await service.buildSnapshot(includeBonusPrize: true);
      final jsonString = snapshot.toPrettyJson();
      final bytes = utf8.encode(jsonString);
      final defaultName =
          'adhd_backup_${snapshot.generatedAtUtc.toIso8601String().replaceAll(':', '-')}.adhd';
      final selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save ADHD backup',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: const ['adhd'],
      );
      if (selectedPath == null) {
        return;
      }
      final targetPath =
          selectedPath.toLowerCase().endsWith('.adhd')
              ? selectedPath
              : '$selectedPath.adhd';
      await writeBytesToPath(targetPath, bytes);
      if (!mounted) return;
      setState(() {
        _lastBonusPrize = snapshot.bonusPrize;
        _lastExportedAt = snapshot.generatedAtUtc;
      });
      final bonusText =
          snapshot.bonusPrize != null
              ? ' Bonus prize #${snapshot.bonusPrize!.prizeId} included!'
              : '';
      _showSnackBar('Backup saved to $targetPath.$bonusText');
    } on UnsupportedError catch (e) {
      _showSnackBar(e.message ?? 'Saving backups is not supported here.');
    } catch (e) {
      _showSnackBar('Could not save backup: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _handleImport() async {
    setState(() => _busy = true);
    try {
      final service = _service(context);
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select ADHD backup',
        type: FileType.custom,
        allowedExtensions: const ['adhd'],
        withData: kIsWeb,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.single;
      String jsonString;
      if (file.bytes != null) {
        jsonString = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        jsonString = await readStringFromPath(file.path!);
      } else {
        throw StateError('No readable data found in the selected file.');
      }
      final snapshot = UserDataSnapshot.fromJsonString(jsonString);
      await service.applySnapshot(snapshot);
      await _loadInitialData();
      if (!mounted) return;
      setState(() {
        _lastBonusPrize = snapshot.bonusPrize;
        _lastExportedAt = snapshot.generatedAtUtc;
      });
      _showSnackBar('Backup loaded successfully.');
    } on FormatException catch (e) {
      _showSnackBar('Invalid backup file: ${e.message}');
    } on UnsupportedError catch (e) {
      _showSnackBar(e.message ?? 'Loading backups is not supported here.');
    } catch (e) {
      _showSnackBar('Could not load backup: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _toggleRemoteOptOut(bool value) async {
    setState(() => _remoteOptOut = value);
    try {
      final repo = _syncRepo(context);
      await repo.setRemoteWriteOptOut(value);
      _showSnackBar(
        value
            ? 'Remote sync disabled. Data stays on this device.'
            : 'Remote sync enabled. A cloud sync will start shortly.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _remoteOptOut = !value);
      _showSnackBar('Could not update preference: $e');
    }
  }

  void _copyUserSummary() {
    final buffer = StringBuffer();
    if (_userName != null) buffer.writeln('User Name: $_userName');
    if (_email != null && _email!.isNotEmpty) buffer.writeln('Email: $_email');
    if (_password != null) buffer.writeln('Password: $_password');
    if (_identifier != null) buffer.writeln('Identifier: $_identifier');
    final summary =
        buffer.isEmpty ? 'No user data available' : buffer.toString();
    Clipboard.setData(ClipboardData(text: summary));
    _showSnackBar('User details copied to clipboard.');
  }

  void _openLegacySwitcher() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoadSaveGame(),
        transitionsBuilder:
            (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Stack(
            children: [
              _buildCard(context),
              if (_busy)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      border: Border.all(
                        color: Palette.basicBitchWhite,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: SyncingIndicator(centered: true),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        boxShadow: const [BoxShadow(color: Colors.black)],
        border: Border.all(color: Palette.basicBitchWhite, width: 2),
        color: Palette.monarchPurple2.withValues(alpha: 0.9),
      ),
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 95,
              width: 95,
              child: Image.asset(
                'assets/img/icons/icon_bw.png',
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 12),
            if (_userName != null)
              Text(
                'User Name: $_userName',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            if (_email != null && _email!.isNotEmpty)
              Text(
                'Email: $_email',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            if (_password != null)
              Text(
                'Password: $_password',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            if (_identifier != null)
              Text(
                'Identifier: $_identifier',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _busy ? null : _copyUserSummary,
              child: Text(
                'Copy details',
                style: TextStyle(color: Palette.basicBitchWhite),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _busy ? null : _handleExport,
              icon: const Icon(Icons.save_alt, size: 18),
              label: const Text('Save backup (.adhd)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.basicBitchBlack,
                foregroundColor: Palette.basicBitchWhite,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _busy ? null : _handleImport,
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('Load backup (.adhd)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.basicBitchBlack,
                foregroundColor: Palette.basicBitchWhite,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _remoteOptOut,
              onChanged: _busy ? null : _toggleRemoteOptOut,
              title: Text(
                'Opt out of Firebase sync',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              subtitle: Text(
                'Keep updates on this device only.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Palette.lightTeal),
              ),
              activeColor: Palette.lightTeal,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _openLegacySwitcher,
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Open legacy account switch'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Palette.basicBitchWhite,
                side: BorderSide(color: Palette.basicBitchWhite),
              ),
            ),
            if (_lastExportedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _exportSummaryText(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Palette.lightTeal),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            ConfirmButton(onPressed: _busy ? null : widget.onClose),
          ],
        ),
      ),
    );
  }

  String _exportSummaryText() {
    final timestamp = _lastExportedAt?.toLocal().toIso8601String() ?? '';
    final prizeText =
        _lastBonusPrize != null
            ? 'Bonus prize #${_lastBonusPrize!.prizeId} packed with this backup.'
            : 'No bonus prize included in the last backup.';
    return 'Last backup: $timestamp\n$prizeText';
  }
}
