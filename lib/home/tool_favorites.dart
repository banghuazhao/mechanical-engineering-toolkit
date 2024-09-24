import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:provider/provider.dart';

import 'favorites.dart';

class ToolFavoritesPage extends StatefulWidget {
  const ToolFavoritesPage({Key? key}) : super(key: key);

  @override
  _ToolFavoritesPageState createState() => _ToolFavoritesPageState();
}

class _ToolFavoritesPageState extends State<ToolFavoritesPage> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
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
        title: Text(S.of(context).Favorites),
      ),
      body: Consumer<Favorites>(
        builder: (context, value, child) => value.items.isNotEmpty
            ? SafeArea(
                child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      buildStaggeredGridView(value, context),
                      if (_anchoredAdaptiveAd != null && _isLoaded)
                        Container(
                          color: Colors.green,
                          width: _anchoredAdaptiveAd!.size.width.toDouble(),
                          height: _anchoredAdaptiveAd!.size.height.toDouble(),
                          child: AdWidget(ad: _anchoredAdaptiveAd!),
                        )
                    ]),
              )
            : const Center(
                child: Text('No favorites added'),
              ),
      ),
    );
  }

  StaggeredGridView buildStaggeredGridView(
      Favorites value, BuildContext context) {
    return StaggeredGridView.countBuilder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      crossAxisCount: 8,
      itemCount: value.items.length,
      staggeredTileBuilder: (int index) {
        var model = ToolLibrary.shared.item(value.items[index], context);
        if (model is String) {
          return StaggeredTile.fit(8);
        } else {
          return StaggeredTile.fit(
              MediaQuery.of(context).size.width > 600 ? 4 : 8);
        }
      },
      mainAxisSpacing: 4,
      crossAxisSpacing: 8,
      itemBuilder: (BuildContext context, int index) {
        var model = ToolLibrary.shared.item(value.items[index], context);
        if (model is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text(
              model as String,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff666159)),
            ),
          );
        } else {
          return ToolRowWidget(model: model);
        }
      },
    );
  }
}

class ToolRowWidget extends StatelessWidget {
  const ToolRowWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  final Tool model;

  @override
  Widget build(BuildContext context) {
    int itemNo = model.id;
    String title = model.title;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          model.action(context, title);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: model.icon != null
                  ? Icon(
                      model.icon,
                      size: 50,
                      color: Color(0xffA8A7A6),
                    )
                  : Image(
                      height: 50,
                      width: 50,
                      image: model.image!,
                      fit: BoxFit.fitWidth,
                    ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                model.title,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<Favorites>().remove(itemNo);
                Fluttertoast.showToast(
                    msg: 'Removed from favorites',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              color: Color(0xffA8A7A6),
              icon: const Icon(Icons.close),
            )
          ]),
        ),
      ),
    );
  }
}
