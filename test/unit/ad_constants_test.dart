import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/constants/ad_constants.dart';

void main() {
  group('AdConstants Tests', () {
    test('App ID and Unit IDs are properly configured', () {
      expect(AdConstants.appId, 'ca-app-pub-3678496910045028~8239145686');
      expect(AdConstants.productionBannerUnitId, 'ca-app-pub-3678496910045028/1861439598');
      expect(AdConstants.testBannerUnitId, 'ca-app-pub-3940256099942544/6300978111');
    });

    test('bannerAdUnitId returns a non-empty valid AdMob ID format', () {
      final id = AdConstants.bannerAdUnitId;
      expect(id, isNotEmpty);
      expect(id.startsWith('ca-app-pub-'), isTrue);
    });
  });
}
