import 'package:flutter/foundation.dart';

class AdConstants {
  AdConstants._();

  /// User-provided AdMob App ID
  static const String appId = 'ca-app-pub-3678496910045028~8239145686';

  /// Production Banner Ad Unit ID
  static const String productionBannerUnitId = 'ca-app-pub-3678496910045028/1861439598';

  /// Official Google Sample/Test Banner Ad Unit ID (Android)
  /// Used in debug mode to prevent policy violations / invalid traffic penalties
  static const String testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

  /// Active Banner Ad Unit ID depending on build mode
  static String get bannerAdUnitId {
    if (kReleaseMode) {
      return productionBannerUnitId;
    }
    return testBannerUnitId;
  }
}
