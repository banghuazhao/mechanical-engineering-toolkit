import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_favorites.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/more/more_app_page.dart';
import 'package:mechanical_engineering_toolkit/more/more_row.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'favorites.dart';
import 'history.dart';
import 'tool_history_page.dart';

enum ToolViewMode { list, grid }

class ToolViewModePreference {
  static const _key = 'TOOL_VIEW_MODE';

  static ToolViewMode get() {
    final raw = SharedPreferencesHelper.localStorage.getString(_key);
    return raw == 'list' ? ToolViewMode.list : ToolViewMode.grid;
  }

  static void set(ToolViewMode mode) {
    SharedPreferencesHelper.localStorage
        .setString(_key, mode == ToolViewMode.grid ? 'grid' : 'list');
  }
}

class ToolSection {
  final String title;
  final List<Tool> tools;
  ToolSection(this.title, this.tools);
}

class ToolPage extends StatefulWidget {
  const ToolPage({Key? key}) : super(key: key);

  @override
  _ToolPageState createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  List<ToolSection> sections = [];
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  late ToolViewMode _viewMode;

  @override
  void initState() {
    super.initState();

    _viewMode = ToolViewModePreference.get();

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    WidgetsBinding.instance
        .addObserver(AppLifecycleReactor(appOpenAdManager: appOpenAdManager));
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ToolViewMode.list
          ? ToolViewMode.grid
          : ToolViewMode.list;
    });
    ToolViewModePreference.set(_viewMode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();

    sections = [];
    final allTools = ToolLibrary.shared.getTools(context);

    sections.add(ToolSection(
      S.of(context).Mechanics_of_Material,
      allTools.where((e) => e.type == ToolType.mechanicsOfMaterial).toList(),
    ));

    sections.add(ToolSection(
      S.of(context).Truss_Statics,
      allTools.where((e) => e.type == ToolType.statics).toList(),
    ));

    sections.add(ToolSection(
      S.of(context).Theory_of_Elasticity,
      allTools.where((e) => e.type == ToolType.theoryOfElasticity).toList(),
    ));

    sections.add(ToolSection(
      S.of(context).Composite_Material,
      allTools.where((e) => e.type == ToolType.composite).toList(),
    ));

    sections.add(ToolSection(
      S.of(context).Utilities,
      allTools.where((e) => e.type == ToolType.utilities).toList(),
    ));
  }

  Future<void> _loadAd() async {
    if (!await AdsManager.canRequestAds() || !mounted) return;

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
            onPressed: _toggleViewMode,
            tooltip: _viewMode == ToolViewMode.list ? 'Grid view' : 'List view',
            icon: Icon(_viewMode == ToolViewMode.list
                ? Icons.grid_view_rounded
                : Icons.view_list_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ToolHistoryPage()));
            },
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ToolFavoritesPage()));
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
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ToolSettingPage()));
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
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            MoreRow(
              title: S.of(context).RatethisApp,
              leadingIcon: Icons.thumb_up_rounded,
              onTap: () async {
                final InAppReview inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  await inAppReview.openStoreListing();
                }
              },
            ),
            MoreRow(
              title: S.of(context).SharethisApp,
              leadingIcon: Icons.share_rounded,
              onTap: () {
                final Size size = MediaQuery.of(context).size;
                if (Platform.isIOS) {
                  Share.share("http://itunes.apple.com/app/id${"1601099443"}",
                      sharePositionOrigin:
                          Rect.fromLTWH(0, 0, size.width, size.height / 2));
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
              color: Colors.transparent,
              width: _anchoredAdaptiveAd!.size.width.toDouble(),
              height: _anchoredAdaptiveAd!.size.height.toDouble(),
              child: AdWidget(ad: _anchoredAdaptiveAd!),
            )
        ]),
      ),
    );
  }

  double get _bottomPadding => _isLoaded && _anchoredAdaptiveAd != null
      ? _anchoredAdaptiveAd!.size.height.toDouble() + 30
      : 120.0;

  Widget buildContents(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width > 900
        ? 5
        : width > 600
            ? 4
            : 3;

    return CustomScrollView(
      slivers: [
        for (var section in sections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSectionHeader(context, section.title),
            ),
          ),
          if (_viewMode == ToolViewMode.list)
            _buildListSliver(context, section.tools)
          else
            _buildGridSliver(context, section.tools, columns),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: _bottomPadding),
        ),
      ],
    );
  }

  Widget _buildListSliver(BuildContext context, List<Tool> tools) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ToolRowWidget(model: tools[index]),
          ),
          childCount: tools.length,
        ),
      ),
    );
  }

  Widget _buildGridSliver(BuildContext context, List<Tool> tools, int columns) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio:
              0.8, // Increased height slightly to prevent overflow
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ToolGridTile(model: tools[index]),
          childCount: tools.length,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xffA8866B),
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
      ),
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
    final isFavorite = favoritesList.items.contains(itemNo);
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: InkWell(
        onTap: () {
          model.action(context, title, itemNo);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: model.icon != null
                  ? Icon(model.icon, size: 26, color: primary)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        height: 48,
                        width: 48,
                        image: model.image!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                model.title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            IconButton(
              onPressed: () {
                !isFavorite
                    ? favoritesList.add(itemNo)
                    : favoritesList.remove(itemNo);
                Fluttertoast.showToast(
                    msg: !isFavorite
                        ? 'Added to favorites'
                        : 'Removed from favorites',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 14.0);
              },
              color: isFavorite ? primary : Colors.grey[400],
              icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
            ),
          ]),
        ),
      ),
    );
  }
}

class ToolGridTile extends StatelessWidget {
  const ToolGridTile({
    Key? key,
    required this.model,
  }) : super(key: key);

  final Tool model;

  @override
  Widget build(BuildContext context) {
    final favoritesList = context.watch<Favorites>();
    int itemNo = model.id;
    String title = model.title;
    final isFavorite = favoritesList.items.contains(itemNo);
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: InkWell(
        onTap: () {
          model.action(context, title, itemNo);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      !isFavorite
                          ? favoritesList.add(itemNo)
                          : favoritesList.remove(itemNo);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 18,
                        color: isFavorite ? primary : Colors.grey[350],
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: model.icon != null
                      ? Icon(model.icon, size: 22, color: primary)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            height: 40,
                            width: 40,
                            image: model.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  model.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
