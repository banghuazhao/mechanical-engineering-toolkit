import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:provider/provider.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _ad;
  AnchoredAdaptiveBannerAdSize? _size;
  int? _loadedWidth;

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _load(int width) async {
    if (_loadedWidth == width) return;
    _loadedWidth = width;
    if (!await AdsManager.canRequestAds() || !mounted) return;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (size == null || !mounted) return;
    setState(() => _size = size);

    final oldAd = _ad;
    final ad = BannerAd(
      adUnitId: AdsManager.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted) {
            loadedAd.dispose();
            return;
          }
          oldAd?.dispose();
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
    final adsRemoved = context.watch<RemoveAdsService>().isAdsRemoved;
    if (adsRemoved) {
      if (_ad != null || _size != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ad?.dispose();
          if (mounted) {
            setState(() {
              _ad = null;
              _size = null;
            });
          }
        });
      }
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.floor();
          if (width > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _load(width));
          }
          final size = _size;
          if (size == null) return const SizedBox.shrink();
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: SizedBox(
              height: size.height.toDouble(),
              child: Center(
                child: SizedBox(
                  width: size.width.toDouble(),
                  height: size.height.toDouble(),
                  child: _ad == null ? null : AdWidget(ad: _ad!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
