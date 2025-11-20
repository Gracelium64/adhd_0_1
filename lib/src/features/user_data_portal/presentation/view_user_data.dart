import 'dart:convert';
import 'dart:typed_data' as typed_data;
import 'dart:ui';

import 'package:adhd_0_1/src/common/presentation/confirm_button.dart';
import 'package:adhd_0_1/src/common/presentation/syncing_indicator.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';
import 'package:adhd_0_1/src/features/settings/presentation/widgets/load_saved_game.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/io/file_system_helper.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/user_data_service.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/user_data_snapshot.dart';
import 'package:adhd_0_1/src/main_screen.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/io/file_picker_prefs.dart';

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
  DateTime? _lastExportedAt;

  bool get _canExport {
    // Disable backup exporting until core credentials exist (cold start).
    final hasUser = (_userName ?? '').isNotEmpty;
    final hasPassword = (_password ?? '').isNotEmpty;
    return hasUser && hasPassword;
  }

  bool get _shouldUseShareFlow {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  bool get _isIOS {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  void _setBusy(bool value) {
    if (!mounted) return;
    setState(() => _busy = value);
  }

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
    _setBusy(true);
    try {
      final service = _service(context);
      final snapshot = await service.buildSnapshot(includeBonusPrize: true);
      final jsonString = snapshot.toPrettyJson();
      final bytes = utf8.encode(jsonString);
      final defaultName =
          'adhd_backup_${snapshot.generatedAtUtc.toIso8601String().replaceAll(':', '-')}.adhd';
      if (_shouldUseShareFlow) {
        final shareParams = ShareParams(
          files: [
            XFile.fromData(
              typed_data.Uint8List.fromList(bytes),
              name: defaultName,
            ),
          ],
        );
        _setBusy(false);
        await SharePlus.instance.share(shareParams);
        if (!mounted) return;
        setState(() {
          _lastExportedAt = snapshot.generatedAtUtc;
        });
        _showSnackBar(
          'Backup ready to share. Choose Files or Drive to store it.',
        );
        return;
      }
      //TODO: .adhd
      final useFilter = await FilePickerPrefs.shouldUseCustomFilter();
      String? selectedPath;
      try {
        if (useFilter) {
          selectedPath = await FilePicker.platform.saveFile(
            dialogTitle: 'Save ADHD backup',
            fileName: defaultName,
            type: FileType.custom,
            allowedExtensions: const ['adhd'],
          );
        } else {
          selectedPath = await FilePicker.platform.saveFile(
            dialogTitle: 'Save ADHD backup',
            fileName: defaultName,
            type: FileType.any,
          );
        }
      } on PlatformException catch (e) {
        debugPrint('[ViewUserData] saveFile PlatformException: $e');
        // If device doesn't support custom filters, remember and retry with any
        await FilePickerPrefs.markFilterUnsupported();
        selectedPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save ADHD backup',
          fileName: defaultName,
          type: FileType.any,
        );
      }
      if (selectedPath == null) {
        _setBusy(false);
        return;
      }
      final targetPath =
          selectedPath.toLowerCase().endsWith('.adhd')
              ? selectedPath
              : '$selectedPath.adhd';
      await writeBytesToPath(targetPath, bytes);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _lastExportedAt = snapshot.generatedAtUtc;
      });
      _showSnackBar('Backup saved to $targetPath.');
    } on UnsupportedError catch (e) {
      _setBusy(false);
      _showSnackBar(e.message ?? 'Saving backups is not supported here.');
    } catch (e) {
      _setBusy(false);
      _showSnackBar('Could not save backup: $e');
    }
  }

  Future<void> _handleImport() async {
    _setBusy(true);
    try {
      final service = _service(context);
      final authRepo = context.read<FirebaseAuthRepository?>();
      final navigator = Navigator.of(context, rootNavigator: true);
      bool shouldNavigateToMain = false;
      final bool allowAnyFile =
          _isIOS; // iOS document picker ignores custom extensions.
      FilePickerResult? result;
      final useFilter = await FilePickerPrefs.shouldUseCustomFilter();
      try {
        if (allowAnyFile) {
          result = await FilePicker.platform.pickFiles(
            dialogTitle: 'Select ADHD backup',
            type: FileType.any,
            withData: kIsWeb,
          );
        } else if (useFilter) {
          result = await FilePicker.platform.pickFiles(
            dialogTitle: 'Select ADHD backup',
            type: FileType.custom,
            allowedExtensions: const ['adhd'],
            withData: kIsWeb,
          );
        } else {
          // Previously marked as unsupported: skip custom filter attempt
          result = await FilePicker.platform.pickFiles(
            dialogTitle: 'Select ADHD backup',
            type: FileType.any,
            withData: kIsWeb,
          );
        }
      } on PlatformException catch (e) {
        debugPrint('[ViewUserData] FilePicker PlatformException: $e');
        // Detect unsupported filter error and cache result so we avoid retries
        if ((e.message ?? '').contains('Unsupported filter') ||
            e.code.toLowerCase().contains('unsupported')) {
          _showSnackBar(
            'File picker filter unsupported on this device — showing all files.',
          );
          await FilePickerPrefs.markFilterUnsupported();
          result = await FilePicker.platform.pickFiles(
            dialogTitle: 'Select ADHD backup',
            type: FileType.any,
            withData: kIsWeb,
          );
        } else {
          rethrow;
        }
      }
      if (result == null || result.files.isEmpty) {
        _setBusy(false);
        return;
      }
      final file = result.files.single;
      final lowerName = file.name.toLowerCase();
      final pathLower = file.path?.toLowerCase();
      final extension = file.extension?.toLowerCase();
      const supportedExtensions = {'adhd', 'so', 'bin'};
      bool matchesSuffix(String target) {
        return supportedExtensions.any((ext) => target.endsWith('.$ext'));
      }

      final hasSupportedExtension =
          (extension != null && supportedExtensions.contains(extension)) ||
          matchesSuffix(lowerName) ||
          (pathLower != null && matchesSuffix(pathLower));
      if (!hasSupportedExtension) {
        _setBusy(false);
        _showSnackBar('Please choose a compatible backup (.adhd).');
        return;
      }
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
      final prefs = await SharedPreferences.getInstance();
      final wasOnboardingComplete =
          prefs.getBool('onboardingComplete') ?? false;
      shouldNavigateToMain = !wasOnboardingComplete;
      await prefs.setBool('onboardingComplete', true);
      if (authRepo != null) {
        try {
          const storage = FlutterSecureStorage();
          final email = await storage.read(key: 'email');
          final password = await storage.read(key: 'password');
          if (email != null && password != null) {
            await authRepo.signInWithEmailAndPassword(email, password);
          }
        } catch (e) {
          debugPrint('⚠️ Silent sign-in after import failed: $e');
        }
      }
      await _loadInitialData();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _lastExportedAt = snapshot.generatedAtUtc;
      });
      _showSnackBar('Backup loaded successfully.');
      if (shouldNavigateToMain) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onClose();
          navigator.pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MainScreen(),
              transitionsBuilder:
                  (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
            (route) => false,
          );
        });
      }
    } on FormatException catch (e) {
      _setBusy(false);
      _showSnackBar('Invalid backup file: ${e.message}');
    } on UnsupportedError catch (e) {
      _setBusy(false);
      _showSnackBar(e.message ?? 'Loading backups is not supported here.');
    } catch (e) {
      _setBusy(false);
      _showSnackBar('Could not load backup: $e');
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
    final navigator = Navigator.of(context, rootNavigator: true);
    widget.onClose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator.push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoadSaveGame(),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
      );
    });
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
        color: Palette.basicBitchBlack,
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
            // // const SizedBox(height: 12),
            // // if (_userName != null)
            // //   Text(
            // //     'User Name: $_userName',
            // //     style: Theme.of(context).textTheme.bodySmall,
            // //     textAlign: TextAlign.center,
            // //   ),
            // // if (_email != null && _email!.isNotEmpty)
            // //   Text(
            // //     'Email: $_email',
            // //     style: Theme.of(context).textTheme.bodySmall,
            // //     textAlign: TextAlign.center,
            // //   ),
            // // if (_password != null)
            // //   Text(
            // //     'Password: $_password',
            // //     style: Theme.of(context).textTheme.bodySmall,
            // //     textAlign: TextAlign.center,
            // //   ),
            // // if (_identifier != null)
            // //   Text(
            // //     'Identifier: $_identifier',
            // //     style: Theme.of(context).textTheme.bodySmall,
            // //     maxLines: 1,
            // //     overflow: TextOverflow.ellipsis,
            // //     textAlign: TextAlign.center,
            // //   ),
            const SizedBox(height: 12),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _busy || !_canExport ? null : _handleExport,
              icon: const Icon(Icons.save_alt, size: 18),
              label: const Text('Save backup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.basicBitchWhite,
                foregroundColor: Palette.basicBitchBlack,
                disabledBackgroundColor: Palette.basicBitchWhite,
                disabledForegroundColor: Palette.basicBitchWhite,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _busy ? null : _handleImport,
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('Load backup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.basicBitchWhite.withValues(
                  alpha: 0.90,
                ),
                foregroundColor: Palette.basicBitchBlack,
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
                'Keep data on this device only.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Palette.lightTeal),
              ),
              activeColor: Palette.lightTeal,
            ),
            TextButton(
              onPressed: _busy ? null : _copyUserSummary,
              style: TextButton.styleFrom(
                backgroundColor: Palette.monarchPurple1Opacity,
                foregroundColor: Palette.basicBitchWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Copy account details to Clipboard',
                style: TextStyle(color: Palette.basicBitchWhite, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _busy ? null : _openLegacySwitcher,
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Switch using Firestore Backup'),
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
    return 'Last backup: $timestamp';
  }
}
