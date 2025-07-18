import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseEnvOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('Platform not supported for Firebase config');
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['apiKeyAndroid']!,
    appId: dotenv.env['appIdAndroid']!,
    messagingSenderId: dotenv.env['messagingSenderIdAndroid']!,
    projectId: dotenv.env['projectIdAndroid']!,
    storageBucket: dotenv.env['storageBucketAndroid'],
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.env['apiKeyIos']!,
    appId: dotenv.env['appIdIos']!,
    messagingSenderId: dotenv.env['messagingSenderIdIos']!,
    projectId: dotenv.env['projectIdIos']!,
    storageBucket: dotenv.env['storageBucketIos'],
    iosBundleId: dotenv.env['iosBundleIdIos'],
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: dotenv.env['apiKeyMac']!,
    appId: dotenv.env['appIdMac']!,
    messagingSenderId: dotenv.env['messagingSenderIdMac']!,
    projectId: dotenv.env['projectIdMac']!,
    storageBucket: dotenv.env['storageBucketMac'],
    iosBundleId: dotenv.env['iosBundleIdMac'],
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: dotenv.env['apiKeyWin']!,
    appId: dotenv.env['appIdWin']!,
    messagingSenderId: dotenv.env['messagingSenderIdWin']!,
    projectId: dotenv.env['projectIdWin']!,
    storageBucket: dotenv.env['storageBucketWin'],
    authDomain: dotenv.env['authDomainWin'],
  );

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['apiKeyWeb']!,
    appId: dotenv.env['appIdWeb']!,
    messagingSenderId: dotenv.env['messagingSenderIdWeb']!,
    projectId: dotenv.env['projectIdWeb']!,
    storageBucket: dotenv.env['storageBucketWeb'],
    authDomain: dotenv.env['authDomainWeb'],
  );
}
