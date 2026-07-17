import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/displacement_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/single_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class BarForceDisplacementResultPage extends StatefulWidget {
  final Displacement displacement;
  final double F;
  final double L;
  final double E;
  final double A;

  const BarForceDisplacementResultPage({
    Key? key,
    required this.displacement,
    required this.F,
    required this.L,
    required this.E,
    required this.A,
  }) : super(key: key);

  @override
  _BarForceDisplacementResultPageState createState() =>
      _BarForceDisplacementResultPageState();
}

class _BarForceDisplacementResultPageState
    extends State<BarForceDisplacementResultPage> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (!await AdsManager.canRequestAds() || !mounted) return;

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      // TODO: replace these test ad units with your own ad unit.
      adUnitId: AdsManager.bannerAdUnitId,
      size: size,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  String _fv(BuildContext context, double? valueSI, UnitCategory category) {
    final precs = Provider.of<NumberPrecisionHelper>(context, listen: false);
    final system =
        Provider.of<UnitSystemPreference>(context, listen: false).system;
    final display = valueSI == null ? null : fromSI(valueSI, category, system);
    return '${precs.formatValue(display)} ${unitLabel(category, system)}';
  }

  @override
  Widget build(BuildContext context) {
    final adsRemoved = context.watch<RemoveAdsService>().isAdsRemoved;
    context.watch<UnitSystemPreference>();
    _disposeBannerWhenPurchased(adsRemoved);
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                shareResult('Bar Force & Displacement', [
                  'δ = ${_fv(context, widget.displacement.value, UnitCategory.length)}',
                  '',
                  'Calculation:',
                  'δ = F·L / (E·A)',
                  '= ${_fv(context, widget.F, UnitCategory.force)} × ${_fv(context, widget.L, UnitCategory.length)} / (${_fv(context, widget.E, UnitCategory.stress)} × ${_fv(context, widget.A, UnitCategory.area)})',
                  '= ${_fv(context, widget.displacement.value, UnitCategory.length)}',
                ]);
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ToolSettingPage()));
              },
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(S.of(context).Result),
        ),
        body: SafeArea(
          child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
            StaggeredGridView.countBuilder(
                padding: EdgeInsets.fromLTRB(20, 20, 20, adsRemoved ? 20 : 100),
                crossAxisCount: 8,
                itemCount: 2,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    SingleRowResult(
                        title: S.of(context).Displacement,
                        resultTitle: "δ",
                        resultValue: widget.displacement.value,
                        category: UnitCategory.length),
                    CalculationCard(steps: [
                      'δ = F·L / (E·A)',
                      '= ${_fv(context, widget.F, UnitCategory.force)} × ${_fv(context, widget.L, UnitCategory.length)} / (${_fv(context, widget.E, UnitCategory.stress)} × ${_fv(context, widget.A, UnitCategory.area)})',
                      '= ${_fv(context, widget.displacement.value, UnitCategory.length)}',
                    ]),
                  ][index];
                }),
            if (!adsRemoved && _anchoredAdaptiveAd != null && _isLoaded)
              Container(
                color: Colors.transparent,
                width: _anchoredAdaptiveAd!.size.width.toDouble(),
                height: _anchoredAdaptiveAd!.size.height.toDouble(),
                child: AdWidget(ad: _anchoredAdaptiveAd!),
              )
          ]),
        ));
  }

  void _disposeBannerWhenPurchased(bool adsRemoved) {
    if (!adsRemoved || _anchoredAdaptiveAd == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _anchoredAdaptiveAd?.dispose();
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });
  }
}
