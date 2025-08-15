import 'package:adhd_0_1/firebase_options.dart';
import 'package:adhd_0_1/src/app.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
// import 'package:adhd_0_1/src/data/domain/firestore_initializer.dart';
// import 'package:adhd_0_1/src/data/domain/reset_scheduler.dart';
import 'package:adhd_0_1/src/data/firebase_auth_repository.dart';
// import 'package:adhd_0_1/src/data/domain/sharedpreferences_initializer.dart';
import 'package:adhd_0_1/src/data/firestore_repository.dart';
// import 'package:adhd_0_1/src/data/sharedpreferencesrepository.dart';
// import 'package:adhd_0_1/src/data/domain/prize_manager.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:adhd_0_1/src/data/syncrepository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:adhd_0_1/src/features/morning_greeting/domain/daily_quote_notifier.dart';

// import 'package:flutter/foundation.dart';
// import 'package:device_preview/device_preview.dart';

/*
There is A LOT of redundant code in this file.
I know that it's there, it has been left there on purpose.
It was before we started using a Firebase Repository, it was actually made in preparation for it.
Since this is an Offline First App, I've build it so that it would prefer the local Repository and back it up to the server when connected to the internet.
Only a couple of days later I learned in class that this feature is default in Firebase anyway.
Fuck it, the code stays.


update 21.7.25 - fuck it, the code gets commented out until i figure out how to not make the syncs fight with each other.


There will not be many comments in this project, you've just collected your first!  
*/

// void initSyncListeners(SyncRepository repository) {
//   final Connectivity connectivity = Connectivity();

//   connectivity.onConnectivityChanged.listen((status) {
//     if (status != ConnectivityResult.none) {
//       repository.syncAll();
//     }
//   });
// }

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
  FlutterNativeSplash.remove;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // One-time migration: consolidate legacy 'secure_secure_name' into 'secure_name'
  try {
    const storage = FlutterSecureStorage();
    final legacy = await storage.read(key: 'secure_secure_name');
    final current = await storage.read(key: 'secure_name');
    if (legacy != null && legacy.trim().isNotEmpty) {
      if (current == null || current.trim().isEmpty) {
        await storage.write(key: 'secure_name', value: legacy);
      }
      await storage.delete(key: 'secure_secure_name');
      debugPrint(
        '🔧 Migrated secure_secure_name to secure_name and removed legacy key',
      );
    }
  } catch (e) {
    debugPrint('⚠️ secure_name migration failed: $e');
  }

  final auth = FirebaseAuthRepository();
  final mainRepo = FirestoreRepository();
  // final localRepo = SharedPreferencesRepository();
  // final mainPrizeManager = PrizeManager(mainlRepo);
  // final localPrizeManager = PrizeManager(localRepo);

  // final repository = SyncRepository(
  //   mainRepo: mainRepo,
  //   localRepo: localRepo,
  //   prizeManager: prizeManager,
  // );

  // initSyncListeners(repository);

  runApp(
    MultiProvider(
      providers: [
        Provider<DataBaseRepository>(create: (_) => mainRepo),
        Provider<FirebaseAuthRepository>(create: (_) => auth),
      ],
      child: const App(),
    ),
  );

  // Initialize local notifications and schedule daily quote at user's startOfDay
  try {
    await DailyQuoteNotifier.instance.init();
    await DailyQuoteNotifier.instance.requestPermissions();
    await DailyQuoteNotifier.instance.rescheduleFromRepository(mainRepo);
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
  // v.0.1.2 //
  //

  // Test Release 2 //
  //TODO: NEW app disclaimer after completing onboarding
  //TODO: responsive design - fine tune 16:9 aspect ratio elemnts placement in AppBg
  //TODO: responsive design - RESPONSIVE FUCKING DESIGN, collect device data from bug reports and adapt
  //TODO: responsive design - move subTitle to AppBg?
  //TODO: BUG - syncrepository duplicates and wrecks havoc on the firestore repository. firestore in offline mode is very buggy.
  //TODO: confirm bug fixes with testers after deployment

  // Test Release 3 //
  //TODO: weather API
  //TODO: good morning overlay with tip of day + weather + tasks for the day
  //TODO: cleanup - secure_name / secure_secure_name
  //TODO: UNDO Button in SncakBar when completing a Quest or Deadline Tasks
  //TODO: eastereggs
  //TODO: make more AI abominations for prizes
  //TODO: confirm bug fixes with testers after deployment

  // Test Release 4 //
  //TODO: how to save files outside of shared memory - save local backup of user data from local repository
  //TODO: user console area through settings, console looks and user input
  //TODO:  [
  //TODO:   delete user information,
  //TODO:   load user information from file,
  //TODO:   load user information of existing user
  //TODO:   (copy in database from one user document with another with entering a valid unique userId),
  //TODO:   backup user information to file, back to app
  //TODO:   ]
  //TODO: confirm bug fixes with testers after deployment

  // Test Release 5 //
  //TODO: responsive design - accesibility big fonts (wtf)
  //TODO: translations
  //TODO: repurpose FridgeLock (?)
  //TODO: tasks with multiple subtasks
  //TODO: animated splash screen
  //TODO: confirm bug fixes with testers after deployment

  //
  // v.0.1.3 // Ready for app release
  //
}
