import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/single_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class ColumnBucklingLoadResultPage extends StatefulWidget {
  final double Pcr;
  final double E;
  final double I;
  final double L;
  final String endCondition;
  final double C;

  const ColumnBucklingLoadResultPage({
    Key? key,
    required this.Pcr,
    required this.E,
    required this.I,
    required this.L,
    required this.endCondition,
    required this.C,
  }) : super(key: key);

  @override
  _ColumnBucklingLoadResultPageState createState() =>
      _ColumnBucklingLoadResultPageState();
}

class _ColumnBucklingLoadResultPageState
    extends State<ColumnBucklingLoadResultPage> {
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
                final cStr = widget.C == 1.0
                    ? 'π²'
                    : '${precs.formatValue(widget.C)} × π²';
                shareResult('Column Buckling Load', [
                  'Pcr = ${precs.formatValue(widget.Pcr)}',
                  '',
                  'Calculation:',
                  'Pcr = C·π²·E·I / L²  (${widget.endCondition})',
                  '= $cStr × ${precs.formatValue(widget.E)} × ${precs.formatValue(widget.I)} / ${precs.formatValue(widget.L)}²',
                  '= ${precs.formatValue(widget.Pcr)}',
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
                        title: S.of(context).Buckling_Load,
                        resultTitle: "Pcr",
                        resultValue: widget.Pcr),
                    Consumer<NumberPrecisionHelper>(
                      builder: (context, precs, _) {
                        final cStr = widget.C == 1.0
                            ? 'π²'
                            : '${precs.formatValue(widget.C)} × π²';
                        return CalculationCard(steps: [
                          'Pcr = C·π²·E·I / L²  (${widget.endCondition})',
                          '= $cStr × ${precs.formatValue(widget.E)} × ${precs.formatValue(widget.I)} / ${precs.formatValue(widget.L)}²',
                          '= ${precs.formatValue(widget.Pcr)}',
                        ]);
                      },
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
