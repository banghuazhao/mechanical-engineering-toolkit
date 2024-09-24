import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:launch_review/launch_review.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_favorites.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/more/more_app_page.dart';
import 'package:mechanical_engineering_toolkit/more/more_row.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../swiftcomp/lib/more/tool_setting_page.dart';
import 'favorites.dart';

class ToolPage extends StatefulWidget {
  const ToolPage({Key? key}) : super(key: key);

  @override
  _ToolPageState createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  List dataSource = [];
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    WidgetsBinding.instance!.addObserver(AppLifecycleReactor(appOpenAdManager: appOpenAdManager));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();

    dataSource = [];
    dataSource.add(S.of(context).Mechanics_of_Material);
    dataSource.addAll(ToolLibrary.shared
        .getTools(context)
        .where((element) => element.type == ToolType.mechanicsOfMaterial)
        .toList());
    dataSource.add(S.of(context).Theory_of_Elasticity);
    dataSource.addAll(ToolLibrary.shared
        .getTools(context)
        .where((element) => element.type == ToolType.theoryOfElasticity)
        .toList());
    dataSource.add(S.of(context).Composite_Material);
    dataSource.addAll(ToolLibrary.shared
        .getTools(context)
        .where((element) => element.type == ToolType.composite)
        .toList());
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
        title: Text(S.of(context).ME_Toolkit),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const ToolFavoritesPage()));
            },
            icon: const Icon(Icons.star_border_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Center(
                child: Image(
                  height: 150,
                  image: AssetImage("images/app_icon_clear.png"),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            MoreRow(
                title: S.of(context).Settings,
                leadingIcon: Icons.settings_rounded,
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const ToolSettingPage()));
                }),
            MoreRow(
              title: S.of(context).Feedback,
              leadingIcon: Icons.chat_rounded,
              onTap: () async {
                final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

                String device;
                String systemVersion;

                if (Platform.isAndroid) {
                  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                  device = androidInfo.model;
                  systemVersion = androidInfo.version.sdkInt.toString();
                } else if (Platform.isIOS) {
                  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
                  device = iosInfo.model;
                  systemVersion = iosInfo.systemVersion;
                } else {
                  device = "";
                  systemVersion = "";
                }

                PackageInfo packageInfo = await PackageInfo.fromPlatform();

                String appName = packageInfo.appName;
                String version = packageInfo.version;

                final Uri params = Uri(
                  scheme: 'mailto',
                  path: 'appsbayarea@gmail.com',
                  query:
                      'subject=$appName Feedback&body=\n\n\nVersion=$version\nDevice=$device\nSystem Version=$systemVersion', //add subject and body here
                );

                var url = params.toString();
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            MoreRow(
              title: S.of(context).RatethisApp,
              leadingIcon: Icons.thumb_up_rounded,
              onTap: () {
                LaunchReview.launch(
                    androidAppId: "com.appsbay.mechanical_engineering_toolkit",
                    iOSAppId: "1601099443");
              },
            ),
            MoreRow(
              title: S.of(context).SharethisApp,
              leadingIcon: Icons.share_rounded,
              onTap: () {
                final Size size = MediaQuery.of(context).size;
                if (Platform.isIOS) {
                  Share.share("http://itunes.apple.com/app/id${"1601099443"}",
                      sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
                } else {
                  AppOpenAdManager.bypassShowAd = true;
                  Share.share("https://play.google.com/store/apps/details?id=" +
                      "com.appsbay.mechanical_engineering_toolkit");
                }
              },
            ),
            MoreRow(
              title: S.of(context).MoreApps,
              leadingIcon: Icons.more_horiz_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => MoreAppPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
          buildContents(context),
          if (_anchoredAdaptiveAd != null && _isLoaded)
            Container(
              color: Colors.green,
              width: _anchoredAdaptiveAd!.size.width.toDouble(),
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            )
        ]),
      ),
    );
  }

  StaggeredGridView buildContents(BuildContext context) {
    return StaggeredGridView.countBuilder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      crossAxisCount: 8,
      itemCount: dataSource.length,
      staggeredTileBuilder: (int index) {
        var model = dataSource[index];
        if (model is String) {
          return StaggeredTile.fit(8);
        } else {
          return StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8);
        }
      },
      mainAxisSpacing: 4,
      crossAxisSpacing: 8,
      itemBuilder: (BuildContext context, int index) {
        var model = dataSource[index];
        if (model is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Text(
              model,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff666159)),
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
    final favoritesList = context.watch<Favorites>();
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
                !favoritesList.items.contains(itemNo)
                    ? favoritesList.add(itemNo)
                    : favoritesList.remove(itemNo);

                Fluttertoast.showToast(
                    msg: favoritesList.items.contains(itemNo)
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              color: Color(0xffA8A7A6),
              icon: !favoritesList.items.contains(itemNo)
                  ? Icon(
                      Icons.star_border_rounded,
                    )
                  : Icon(
                      Icons.star_rounded,
                    ),
            )
          ]),
        ),
      ),
    );
  }
}
