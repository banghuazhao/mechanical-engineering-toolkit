import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/stress_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/single_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class GeneralStressResultPage extends StatefulWidget {
  final Stress stress;
  final double F;
  final double A;

  const GeneralStressResultPage(
      {Key? key, required this.stress, required this.F, required this.A})
      : super(key: key);

  @override
  _GeneralStressResultPageState createState() =>
      _GeneralStressResultPageState();
}

class _GeneralStressResultPageState extends State<GeneralStressResultPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                final precs =
                    Provider.of<NumberPrecisionHelper>(context, listen: false);
                shareResult('General Stress', [
                  'σ = ${precs.formatValue(widget.stress.value)}',
                  '',
                  'Calculation:',
                  'σ = F / A',
                  '= ${precs.formatValue(widget.F)} / ${precs.formatValue(widget.A)}',
                  '= ${precs.formatValue(widget.stress.value)}',
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                crossAxisCount: 8,
                itemCount: 2,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    SingleRowResult(
                        title: S.of(context).Stress,
                        resultTitle: "σ",
                        resultValue: widget.stress.value),
                    Consumer<NumberPrecisionHelper>(
                      builder: (context, precs, _) => CalculationCard(steps: [
                        'σ = F / A',
                        '= ${precs.formatValue(widget.F)} / ${precs.formatValue(widget.A)}',
                        '= ${precs.formatValue(widget.stress.value)}',
                      ]),
                    ),
                  ][index];
                }),
            if (_anchoredAdaptiveAd != null && _isLoaded)
              Container(
                color: Colors.transparent,
                width: _anchoredAdaptiveAd!.size.width.toDouble(),
                height: _anchoredAdaptiveAd!.size.height.toDouble(),
                child: AdWidget(ad: _anchoredAdaptiveAd!),
              )
          ]),
        ));
  }
}
