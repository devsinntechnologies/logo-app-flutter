import 'dart:io';

class Adhelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3846215901075841/2245794811";
    } else if (Platform.isIOS) {
      return "";
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
