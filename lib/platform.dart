import 'dart:io' as io;

class Platform {
  static bool get isMobile => io.Platform.isAndroid || io.Platform.isIOS;
}
