import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/language_picker.dart';
import 'package:mechanical_engineering_toolkit/home/major_list_page.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_favorites.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/more/more_app_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/more/more_row.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'favorites.dart';
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

/// Latin diacritics folded to their bare letter, so a French or German user
/// gets hits without reaching for the accented key: "elasticite" finds
/// "Élasticité", "trager" finds "Träger".
const Map<String, String> _searchFoldings = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'ç': 'c',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  'æ': 'ae', 'œ': 'oe', 'ß': 'ss',
};

/// Normalizes [value] for search comparison: case-folded and stripped of the
/// Latin diacritics the app's locales use. CJK text passes through unchanged,
/// which is fine — matching there is substring-based and needs no folding.
String foldForSearch(String value) {
  var folded = value.toLowerCase();
  _searchFoldings.forEach((accented, plain) {
    if (folded.contains(accented)) folded = folded.replaceAll(accented, plain);
  });
  return folded;
}

/// Splits a raw query into the terms a tool must match. Whitespace-separated so
/// "beam deflection" works in either order; a CJK query has no spaces and comes
/// back as a single term, which substring matching handles.
List<String> searchTerms(String query) => foldForSearch(query)
    .split(RegExp(r'\s+'))
    .where((term) => term.isNotEmpty)
    .toList();

class ToolPage extends StatefulWidget {
  const ToolPage({super.key});

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  List<ToolSection> sections = [];
  late ToolViewMode _viewMode;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _searchTerms = const [];
  AppOpenAdManager? _appOpenAdManager;
  AppLifecycleReactor? _appLifecycleReactor;

  @override
  void initState() {
    super.initState();

    _viewMode = ToolViewModePreference.get();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ToolViewMode.list
          ? ToolViewMode.grid
          : ToolViewMode.list;
    });
    ToolViewModePreference.set(_viewMode);
  }

  void _updateSearch(String value) {
    setState(() {
      _searchQuery = value.trim();
      _searchTerms = searchTerms(_searchQuery);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _updateSearch('');
  }

  /// A tool matches when every term in the query appears somewhere in its
  /// localized title, its section's localized title, or its keywords.
  ///
  /// Searching the section title is what lets a non-English user pull up a
  /// whole category ("Verbund", "複合材料") without knowing any single tool's
  /// name. The keywords themselves stay English on purpose: they are synonyms
  /// for engineers who reach for the English term ("torque", "von mises"),
  /// which is common in the field, and they cost nothing to leave in place.
  bool _matchesSearch(Tool tool, String sectionTitle) {
    if (_searchTerms.isEmpty) return true;
    final haystack = foldForSearch(
      [tool.title, sectionTitle, ...tool.keywords].join(' '),
    );
    return _searchTerms.every(haystack.contains);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureAppOpenAds();
    sections = [];
    final allTools = ToolLibrary.shared.getTools(context);

    sections.add(ToolSection(
      S.of(context).Mechanics_of_Material,
      allTools.where((e) => e.type == ToolType.mechanicsOfMaterial).toList(),
    ));

    sections.add(ToolSection(
      S.of(context).Beam_Engineering,
      allTools.where((e) => e.type == ToolType.beamEngineering).toList(),
    ));

    sections.add(ToolSection(
      S.of(context).Machine_Design,
      allTools.where((e) => e.type == ToolType.machineDesign).toList(),
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

  void _configureAppOpenAds() {
    if (_appOpenAdManager != null ||
        context.read<RemoveAdsService>().isAdsRemoved) {
      return;
    }
    _appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: _appOpenAdManager!,
    );
    WidgetsBinding.instance.addObserver(_appLifecycleReactor!);
  }

  @override
  void dispose() {
    final reactor = _appLifecycleReactor;
    if (reactor != null) WidgetsBinding.instance.removeObserver(reactor);
    _appOpenAdManager?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).ME_Toolkit),
        actions: [
          IconButton(
            onPressed: _toggleViewMode,
            tooltip: _viewMode == ToolViewMode.list
                ? S.of(context).Grid_View
                : S.of(context).List_View,
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
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Center(
                child: Image(
                  height: 150,
                  image: AssetImage("images/app_icon_clear.png"),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            MoreRow(
              title: S.of(context).Recommended_by_Major,
              leadingIcon: Icons.school_rounded,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MajorListPage(),
                  ),
                );
              },
            ),
            MoreRow(
              title: S.of(context).Saved_Projects,
              leadingIcon: Icons.bookmark_rounded,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedProjectsPage(),
                  ),
                );
              },
            ),
            const Divider(height: 24, indent: 16, endIndent: 16),
            MoreRow(
                title: S.of(context).Settings,
                leadingIcon: Icons.settings_rounded,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ToolSettingPage()));
                }),
            Consumer<LanguagePreference>(
              builder: (context, languagePref, _) => MoreRow(
                title: S.of(context).Language,
                leadingIcon: Icons.translate_rounded,
                trailingText: languageLabel(context, languagePref.language),
                onTap: () => showLanguagePicker(context),
              ),
            ),
            Consumer<RemoveAdsService>(
              builder: (context, purchases, _) {
                if (!purchases.isSupported) return const SizedBox.shrink();
                return MoreRow(
                  title: S.of(context).Remove_Ads,
                  leadingIcon: purchases.isAdsRemoved
                      ? Icons.verified_rounded
                      : Icons.block_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RemoveAdsPage(),
                      ),
                    );
                  },
                );
              },
            ),
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
              onTap: () async {
                final Size size = MediaQuery.of(context).size;
                if (Platform.isIOS) {
                  await SharePlus.instance.share(ShareParams(
                    text: 'http://itunes.apple.com/app/id1601099443',
                    sharePositionOrigin:
                        Rect.fromLTWH(0, 0, size.width, size.height / 2),
                  ));
                } else {
                  AppOpenAdManager.bypassShowAd = true;
                  await SharePlus.instance.share(ShareParams(
                    text:
                        'https://play.google.com/store/apps/details?id=com.appsbay.mechanical_engineering_toolkit',
                  ));
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
                    builder: (BuildContext context) => const MoreAppPage(),
                  ),
                );
              },
            ),
            // Also reachable from Settings; surfaced here because store review
            // and several privacy regimes expect it to be easy to find.
            MoreRow(
              title: S.of(context).Privacy_Policy,
              leadingIcon: Icons.policy_rounded,
              onTap: () => launchUrl(
                Uri.parse(privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: buildContents(context)),
      bottomNavigationBar: const AppBannerAd(),
    );
  }

  Widget buildContents(BuildContext context) {
    final visibleSections = _searchTerms.isEmpty
        ? sections
        : sections
            .map(
              (section) => ToolSection(
                section.title,
                section.tools
                    .where((tool) => _matchesSearch(tool, section.title))
                    .toList(),
              ),
            )
            .where((section) => section.tools.isNotEmpty)
            .toList();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.tokens.contentMaxWidth),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  key: const Key('toolSearchField'),
                  controller: _searchController,
                  onChanged: _updateSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: S.of(context).Search_Tools,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            key: const Key('clearToolSearch'),
                            tooltip: S.of(context).Clear_Search,
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ),
            for (var section in visibleSections) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildSectionHeader(context, section.title),
                ),
              ),
              if (_viewMode == ToolViewMode.list)
                _buildListSliver(context, section.tools)
              else
                _buildGridSliver(context, section.tools),
            ],
            if (visibleSections.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      S.of(context).No_Tools_Found,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: context.tokens.space4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSliver(BuildContext context, List<Tool> tools) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StaggeredEntrance(
              index: index,
              child: ToolRowWidget(model: tools[index]),
            ),
          ),
          childCount: tools.length,
        ),
      ),
    );
  }

  Widget _buildGridSliver(BuildContext context, List<Tool> tools) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 128,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 126,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => StaggeredEntrance(
            index: index,
            child: ToolGridTile(model: tools[index]),
          ),
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
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class ToolRowWidget extends StatelessWidget {
  const ToolRowWidget({
    super.key,
    required this.model,
  });

  final Tool model;

  @override
  Widget build(BuildContext context) {
    final favoritesList = context.watch<Favorites>();
    int itemNo = model.id;
    String title = model.title;
    final isFavorite = favoritesList.items.contains(itemNo);
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.tokens.radiusLarge),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () {
          model.action(context, title, itemNo);
        },
        borderRadius: BorderRadius.circular(context.tokens.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(children: [
            Hero(
              tag: 'tool_icon_${model.id}',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(context.tokens.radiusMedium),
                ),
                child: model.icon != null
                    ? Icon(model.icon, size: 26, color: primary)
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(context.tokens.radiusMedium),
                        child: Image(
                          height: 48,
                          width: 48,
                          image: model.image!,
                          fit: BoxFit.cover,
                        ),
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
              tooltip: isFavorite
                  ? S.of(context).Remove_from_Favorites
                  : S.of(context).Add_to_Favorites,
              onPressed: () async {
                await HapticFeedback.selectionClick();
                !isFavorite
                    ? favoritesList.add(itemNo)
                    : favoritesList.remove(itemNo);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(!isFavorite
                      ? S.of(context).Added_to_Favorites
                      : S.of(context).Removed_from_Favorites),
                ));
              },
              color: isFavorite
                  ? primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
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
    super.key,
    required this.model,
  });

  final Tool model;

  @override
  Widget build(BuildContext context) {
    final favoritesList = context.watch<Favorites>();
    int itemNo = model.id;
    String title = model.title;
    final isFavorite = favoritesList.items.contains(itemNo);
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.tokens.radiusLarge),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () {
          model.action(context, title, itemNo);
        },
        borderRadius: BorderRadius.circular(context.tokens.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'tool_icon_${model.id}',
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(context.tokens.radiusSmall),
                      ),
                      child: model.icon != null
                          ? Icon(model.icon, size: 21, color: primary)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  context.tokens.radiusSmall),
                              child: Image(
                                image: model.image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: IconButton(
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: isFavorite
                          ? S.of(context).Remove_from_Favorites
                          : S.of(context).Add_to_Favorites,
                      onPressed: () async {
                        await HapticFeedback.selectionClick();
                        !isFavorite
                            ? favoritesList.add(itemNo)
                            : favoritesList.remove(itemNo);
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 18,
                        color: isFavorite
                            ? primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  model.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
