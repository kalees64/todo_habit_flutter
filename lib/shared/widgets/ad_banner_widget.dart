import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/ad_constants.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';

/// A self-contained, lifecycle-safe Banner Ad widget.
/// Gracefully handles loading states, error states, and disposes resources cleanly.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin = const EdgeInsets.symmetric(vertical: AppSpacing.p8),
  });

  final AdSize adSize;
  final EdgeInsetsGeometry margin;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd({bool useFallbackTestAd = false}) {
    try {
      final unitId = useFallbackTestAd
          ? AdConstants.testBannerUnitId
          : AdConstants.bannerAdUnitId;

      _bannerAd = BannerAd(
        adUnitId: unitId,
        size: widget.adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('BannerAd failed to load ($unitId): $error');
            ad.dispose();
            _bannerAd = null;
            if (mounted) {
              // If production ad failed (e.g. account pending approval / no fill), fallback to test ad so banner is visible
              if (!useFallbackTestAd && unitId != AdConstants.testBannerUnitId) {
                _loadBannerAd(useFallbackTestAd: true);
              } else {
                setState(() {
                  _isLoaded = false;
                });
              }
            }
          },
        ),
      );

      _bannerAd?.load();
    } catch (e) {
      debugPrint('Error creating BannerAd: $e');
      _isLoaded = false;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final customColors = theme.extension<TaskFlowColors>();

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      decoration: BoxDecoration(
        color: customColors?.cardBackground ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: customColors?.hairlineBorder ?? theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
