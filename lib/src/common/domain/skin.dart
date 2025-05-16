/*
true = pink
null = white
false = blue
*/

bool? appBg;

// ignore: body_might_complete_normally_nullable
String? appBgSkin(bool? appBg) {
  if (appBg == true) {
    return 'assets/img/app_bg/png/app_bg_pink.png';
  } else if (appBg == null) {
    return 'assets/img/app_bg/png/app_bg_white.png';
  } else if (appBg == false) {
    return 'assets/img/app_bg/png/app_bg_blue.png';
  }
}
