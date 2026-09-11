import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:provider/provider.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  static const _size = AdSize.banner;

  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!await AdsManager.canRequestAds() || !mounted) return;
    final ad = BannerAd(
      adUnitId: AdsManager.bannerAdUnitId,
      size: _size,
      request: AdsManager.buildAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted) {
            loadedAd.dispose();
            return;
          }
          setState(() => _ad = loadedAd as BannerAd);
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          if (kDebugMode) debugPrint('Banner ad failed to load: $error');
        },
      ),
    );
    await ad.load();
  }

  @override
  Widget build(BuildContext context) {
    // macOS has no ad SDK and no ad slot in the layout at all: not an empty
    // strip the height of a banner, but nothing. Checked before the ads-removed
    // branch below so the Mac build never reserves the space.
    if (!AppPlatform.current.supportsAds) return const SizedBox.shrink();

    final adsRemoved = context.watch<RemoveAdsService>().isAdsRemoved;
    if (adsRemoved) {
      if (_ad != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ad?.dispose();
          if (mounted) setState(() => _ad = null);
        });
      }
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: SizedBox(
          height: _size.height.toDouble(),
          child: Center(
            child: _ad == null
                ? null
                : SizedBox(
                    width: _size.width.toDouble(),
                    height: _size.height.toDouble(),
                    child: AdWidget(ad: _ad!),
                  ),
          ),
        ),
      ),
    );
  }
}
