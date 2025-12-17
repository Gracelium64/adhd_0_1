import 'package:adhd_0_1/firebase_options.dart';
import 'package:adhd_0_1/src/app.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
import 'package:adhd_0_1/src/data/firestore_repository.dart';
import 'package:adhd_0_1/src/data/sharedpreferencesrepository.dart';
import 'package:adhd_0_1/src/data/syncrepository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/daily_quote_notifier.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/deadline_notifier.dart';
// import 'package:adhd_0_1/src/features/morning_greeting/domain/daily_weather_notifier.dart';
// TODO(reactivate_weather): Re-enable this import when turning daily weather notifications back on.
import 'package:adhd_0_1/src/common/domain/refresh_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/data/domain/pending_registration.dart';
import 'package:adhd_0_1/src/common/notifications/awesome_notif_service.dart';
import 'package:adhd_0_1/src/common/security/secure_name_manager.dart';

// import 'package/flutter/foundation.dart';
// import 'package:device_preview/device_preview.dart';

/*
There is A LOT of redundant code in this file.
I know that it's there, it has been left there on purpose.
It was before we started using a Firebase Repository, it was actually made in preparation for it.
Since this is an Offline First App, I've build it so that it would prefer the local Repository and back it up to the server when connected to the internet.
Only a couple of days later I learned in class that this feature is default in Firebase anyway.
Fuck it, the code stays.


update 21.7.25 - fuck it, the code gets commented out until i figure out how to not make the syncs fight with each other.

update 19.8.25 - I was a puritan at first when the course began, insisting writing my own code without AI.
                 As time went by I learned the benefits of working with AI to better my code and to speed things up extremely.
                 As of today, and with the help from a CoPilot subscription and ChatGPT5 - this app is finally an Offline First Architecture App.


There will not be many comments in this project, you've just collected your first!  
*/

void initSyncListeners(SyncRepository repository) {
  final Connectivity connectivity = Connectivity();

  connectivity.onConnectivityChanged.listen((statuses) async {
    final hasConnection = statuses.any(
      (result) => result != ConnectivityResult.none,
    );

    if (hasConnection) {
      debugPrint('📶 Connectivity regained: $statuses');
      // First, try to complete any pending registrations before syncing
      bool completed = false;
      try {
        final auth = FirebaseAuthRepository();
        final has = await PendingRegistration.hasPending();
        debugPrint('📝 Pending registration present: $has');
        if (has) {
          completed = await PendingRegistration.attempt(auth);
          debugPrint('📝 Pending registration completed: $completed');
          if (completed) {
            // Ensure the Firestore user doc exists with ownerUid before any writes
            try {
              const storage = FlutterSecureStorage();
              final userId = await storage.read(key: 'userId');
              final name = await storage.read(key: 'name');
              final email = await storage.read(key: 'email');
              final password = await storage.read(key: 'password');
              if (userId != null && email != null && password != null) {
                debugPrint('👤 Finalizing user doc for userId=$userId');
                final fsRepo = FirestoreRepository();
                await fsRepo.setAppUser(
                  userId,
                  name ?? userId,
                  email,
                  password,
                  false,
                );
                await fsRepo.cleanupUserDocLegacyFields();
                // Do NOT hydrate here. After registration we keep local as source of truth
                // and push to server. Hydration is reserved for user migration/load saved game.
              }
            } catch (_) {}
            // Force a sync push right after completing registration
            debugPrint('🚀 Forcing sync after registration completion');
            repository.triggerSync(force: true);
          }
        }
        // If no pending registration, ensure we're signed in and user doc has ownerUid
        if (!completed) {
          try {
            const storage = FlutterSecureStorage();
            final email = await storage.read(key: 'email');
            final password = await storage.read(key: 'password');
            final userId = await storage.read(key: 'userId');
            final name = await storage.read(key: 'name');
            if (email != null && password != null && userId != null) {
              final current = FirebaseAuth.instance.currentUser;
              if (current == null) {
                await auth.signInWithEmailAndPassword(email, password);
                debugPrint('🔐 Signed in with stored credentials');
              } else if ((current.email ?? '').toLowerCase() !=
                  email.toLowerCase()) {
                debugPrint(
                  '� Auth/email mismatch (current=${current.email}, stored=$email). Switching session…',
                );
                await FirebaseAuth.instance.signOut();
                await auth.signInWithEmailAndPassword(email, password);
                debugPrint('🔐 Switched auth session to stored credentials');
              } else {
                debugPrint('🔐 Already signed in as ${current.uid}');
              }
              final fsRepo = FirestoreRepository();
              try {
                await fsRepo.setAppUser(
                  userId,
                  name ?? userId,
                  email,
                  password,
                  false,
                );
                // Remove legacy 'password' field from Firestore user doc if present
                await fsRepo.cleanupUserDocLegacyFields();
              } catch (e) {
                // If permission-denied, try a silent re-auth and retry once
                final err = e.toString();
                if (err.contains('permission-denied')) {
                  try {
                    await FirebaseAuth.instance.signOut();
                    await auth.signInWithEmailAndPassword(email, password);
                    await fsRepo.setAppUser(
                      userId,
                      name ?? userId,
                      email,
                      password,
                      false,
                    );
                    await fsRepo.cleanupUserDocLegacyFields();
                    debugPrint('🔁 OwnerUid stamp succeeded after re-auth');
                  } catch (e2) {
                    debugPrint(
                      '⚠️ Sign-in/ownerUid stamp skipped after retry: $e2',
                    );
                  }
                } else {
                  debugPrint('⚠️ Sign-in/ownerUid stamp skipped: $e');
                }
              }
            }
          } catch (e) {
            debugPrint('⚠️ Sign-in/ownerUid stamp skipped: $e');
          }
        }
      } catch (_) {}

      repository.runOneTimeDedupMarking();
      // Normal connectivity regain: request a sync (non-forced)
      debugPrint('🔔 Requesting normal sync after connectivity regain');
      repository.triggerSync();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // // // await SharedPreferencesInitializer.initializeDefaults();
  await dotenv.load(fileName: 'black_speech.env');
  debugPrint('✅ Using API key: ${dotenv.env['apiKeyIos']}');

  try {
    await Firebase.initializeApp(options: FirebaseEnvOptions.currentPlatform);
    debugPrint("✅ Firebase.initializeApp() succeeded");
  } catch (e) {
    debugPrint("❌ Firebase.initializeApp() failed: $e");
    debugPrint('🧪 Firebase.apps: ${Firebase.apps}');
    if (!e.toString().contains('already exists')) rethrow;
  }
  // there were some trouble here with the API keys after reciting the black_speech //
  // remove try-catch when finished //

  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Pre-warm SharedPreferences to avoid first-call latency on overlays
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('⚠️ SharedPreferences prewarm failed: $e');
  }

  // One-time migration: consolidate legacy 'secure_secure_name' into 'secure_name'
  try {
    const storage = FlutterSecureStorage();
    final secureNameManager = SecureNameManager(
      store: FlutterSecureStorageStore(storage),
    );
    await secureNameManager.ensure();
  } catch (e, stack) {
    debugPrint('⚠️ secure_name migration failed: $e');
    debugPrint(stack.toString());
  }

  final auth = FirebaseAuthRepository();
  // Local-first development toggle: set --dart-define=USE_LOCAL_REPO=true
  final localRepo = SharedPreferencesRepository();
  final useLocal = const String.fromEnvironment('USE_LOCAL_REPO') == 'true';
  final mainRepo = useLocal ? localRepo : FirestoreRepository();
  final prizeManager = PrizeManager(localRepo);

  final repository = SyncRepository(
    mainRepo: mainRepo,
    localRepo: localRepo,
    prizeManager: prizeManager,
  );

  initSyncListeners(repository);

  // Initialize Awesome Notifications channels/permissions (Android/iOS)
  try {
    await AwesomeNotifService.instance.init();
    debugPrint('🔔 Awesome Notifications initialized');
  } catch (e, stack) {
    debugPrint('⚠️ Awesome Notifications init failed: $e');
    debugPrint(stack.toString());
  }

  // Kick a one-time dedup pass at cold start as well (safe: mark-only)
  // Disabled temporarily to avoid network calls during local/dev runs.
  // TODO(reenable): REENABLE_REMOTE_SYNC - Re-enable this for production
  // Re-enabled only when not using local repo for development.
  if (!useLocal) {
    Future.microtask(() => repository.runOneTimeDedupMarking());
  }

  // Pull down any new remote prizes roughly once per week. (disabled)
  // TODO(reenable): REENABLE_REMOTE_SYNC - Re-enable this when network testing is desired
  //
  //    if (!useLocal) {
  //      try {
  //        await repository.syncPrizesFromRemoteWeeklyIfNeeded();
  //      } catch (e) {
  //        debugPrint('⚠️ Prize pull on startup failed: $e');
  //      }
  //    }
  // Sync locally won prizes to Firestore once per day at cold start. (disabled)
  // TODO(reenable): REENABLE_REMOTE_SYNC - Re-enable when remote writes are needed
  //
  //    if (!useLocal) {
  //      try {
  //        await repository.syncPrizesToRemoteIfNeeded();
  //      } catch (e) {
  //        debugPrint('⚠️ Prize sync on startup failed: $e');
  //      }
  //    }
  // Ensure prize #22 is awarded after 3 days from first run. (disabled)
  // TODO(reenable): REENABLE_REMOTE_SYNC - Re-enable after verifying prize sync behavior
  //
  //    if (!useLocal) {
  //      try {
  //        await repository.ensurePrize22AfterThreeDays();
  //      } catch (e) {
  //        debugPrint('⚠️ ensurePrize22AfterThreeDays failed: $e');
  //      }
  //    }

  runApp(
    MultiProvider(
      providers: [
        Provider<DataBaseRepository>(create: (_) => repository),
        Provider<FirebaseAuthRepository>(create: (_) => auth),
        ChangeNotifierProvider<RefreshBus>(create: (_) => RefreshBus()),
      ],
      child: const App(),
    ),
  );

  // Initialize local notifications and schedule daily quote at user's startOfDay
  try {
    await DailyQuoteNotifier.instance.init();
    await DailyQuoteNotifier.instance.requestPermissions();
    await DailyQuoteNotifier.instance.rescheduleFromRepository(mainRepo);
    // Schedule the deadline notifier shortly after the daily quote time
    // using the same startOfDay from settings.
    final settings = await mainRepo.getSettings();
    final start = settings?.startOfDay ?? const TimeOfDay(hour: 7, minute: 15);
    await DeadlineNotifier.instance.init();
    await DeadlineNotifier.instance.requestPermissions();
    await DeadlineNotifier.instance.scheduleRelativeToDaily(start, mainRepo);

    // Schedule daily silent weather notification one minute before daily quote (disabled).
    // TODO(reactivate_weather): Uncomment this block (and the import above) to restore the weather API notification.
    // try {
    //   await DailyWeatherNotifier.instance.init();
    //   await DailyWeatherNotifier.instance.scheduleRelativeToDaily(
    //     start,
    //     mainRepo,
    //   );
    // } catch (e) {
    //   debugPrint('⚠️ DailyWeatherNotifier scheduling failed: $e');
    // }
  } catch (e) {
    debugPrint('⚠️ Notification init/schedule failed: $e');
  }

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => App(repository),
  //   ),
  // );

  //
  //

  //
  // v.0.1.2.3 //
  //

  // Test Release 3 // v.0.1.2.1.3 // Ready further documents needed to apply the app to the App Store and Play Store

  // Test Release 4 // v.0.1.3 // Apply for review in App Store and Play Store
  //todo: silent morning notification

  // First Update after Release // v.0.1.3.1 //
  //TODO: make more AI abominations for prizes
  //TODO: eastereggs
  // //TODO: weather API - in another daily silent notification in the morning with a one liner and symbol for today's weather, to be timed for 5 minutes before the daily quote
  //TODO: fix bleed in dragging tasks to change order
  //TODO: responsive design - accesibility big fonts    // GRACE //
  //TODO: translations
  //TODO: repurpose FridgeLock (?)
  //TODO: animated splash screen
  //TODO: confirm bug fixes with testers after deployment

  //
  // v.0.1.3 // Ready for release
  //
}
