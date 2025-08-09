/*
true = pink
null = white
false = blue
*/

import 'package:flutter/foundation.dart';

bool? appBg;

// Map the tri-state skin flag to a concrete asset path (sync helper)
String skinAssetFromBool(bool? skin) {
  if (skin == true) {
    return 'assets/img/app_bg/png/app_bg_pink.png';
  } else if (skin == false) {
    return 'assets/img/app_bg/png/app_bg_blue.png';
  } else {
    return 'assets/img/app_bg/png/app_bg_white.png';
  }
}

// Reactive notifier so the background can update instantly when skin changes.
final ValueNotifier<String> appBgAsset =
    ValueNotifier<String>(skinAssetFromBool(null));

void updateAppBgAsset(bool? skin) {
  appBgAsset.value = skinAssetFromBool(skin);
}

// Legacy async helper kept for compatibility with existing callers.
// ignore: body_might_complete_normally_nullable
Future<String?> appBgSkin(bool? appBg) async {
  return skinAssetFromBool(appBg);
}
