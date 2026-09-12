import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/language_picker.dart';
import 'package:mechanical_engineering_toolkit/home/major_list_page.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_favorites.dart';
import 'package:mechanical_engineering_toolkit/home/tool_launcher.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/more/app_actions.dart';
import 'package:mechanical_engineering_toolkit/more/more_app_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/more/more_row.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
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
  final ToolType type;
  ToolSection(this.title, this.tools, this.type);
}

/// The library's categories in the order they are listed, with the glyph the
/// wide layout's sidebar shows beside each.
const List<(ToolType, IconData)> toolCategories = [
  (ToolType.mechanicsOfMaterial, Icons.straighten_rounded),
  (ToolType.beamEngineering, Icons.horizontal_split_rounded),
  (ToolType.machineDesign, Icons.settings_rounded),
  (ToolType.statics, Icons.change_history_rounded),
  (ToolType.theoryOfElasticity, Icons.grid_4x4_rounded),
  (ToolType.composite, Icons.layers_rounded),
  (ToolType.fluidsThermal, Icons.water_drop_rounded),
  (ToolType.thermodynamics, Icons.local_fire_department_rounded),
  (ToolType.utilities, Icons.menu_book_rounded),
];

String toolCategoryTitle(BuildContext context, ToolType type) {
  final l10n = S.of(context);
  return switch (type) {
    ToolType.mechanicsOfMaterial => l10n.Mechanics_of_Material,
    ToolType.beamEngineering => l10n.Beam_Engineering,
    ToolType.machineDesign => l10n.Machine_Design,
    ToolType.statics => l10n.Truss_Statics,
    ToolType.theoryOfElasticity => l10n.Theory_of_Elasticity,
    ToolType.composite => l10n.Composite_Material,
    ToolType.fluidsThermal => l10n.Fluids_and_Thermal,
    ToolType.thermodynamics => l10n.Thermodynamics,
    ToolType.utilities => l10n.Utilities,
  };
}

/// Window width from which the library gets a permanent sidebar in place of
/// the drawer. Below the tool workspace's own breakpoint on purpose: the
/// sidebar is narrow and pays for itself sooner than a second column does.
const double kLibrarySidebarWidth = 900;

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
  final FocusNode _searchFocus = FocusNode();

  /// The category the sidebar narrows the library to; null shows them all.
  ToolType? _category;
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
    final allTools = ToolLibrary.shared.getTools(context);
    sections = [
      for (final (type, _) in toolCategories)
        ToolSection(
          toolCategoryTitle(context, type),
          allTools.where((tool) => tool.type == type).toList(),
          type,
        ),
    ];
  }

  void _configureAppOpenAds() {
    if (!AppPlatform.current.supportsAds ||
        _appOpenAdManager != null ||
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
    _searchFocus.dispose();
    super.dispose();
  }

  /// Focuses the search field — the answer to ⌘F.
  void _focusSearch() {
    _searchFocus.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= kLibrarySidebarWidth;
    return AppCommandHandler(
      command: AppCommand.findTool,
      onInvoke: _focusSearch,
      child: Scaffold(
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
              tooltip: S.of(context).History,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToolHistoryPage()),
              ),
              icon: const Icon(Icons.history_rounded),
            ),
            IconButton(
              tooltip: S.of(context).Favorites,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ToolFavoritesPage()),
              ),
              icon: const Icon(Icons.star_border_rounded),
            ),
          ],
        ),
        // A wide window keeps the menu open as a sidebar; a drawer that has
        // to be summoned is a phone's answer to a phone's lack of room.
        drawer: wide
            ? null
            : Drawer(
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
                    ..._menuRows(context, inDrawer: true),
                  ],
                ),
              ),
        body: SafeArea(
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 264, child: _buildSidebar(context)),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(child: buildContents(context)),
                  ],
                )
              : buildContents(context),
        ),
        bottomNavigationBar: const AppBannerAd(),
      ),
    );
  }

  /// The library's categories, then everything the phone layout keeps in its
  /// drawer.
  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    Widget category(ToolType? type, String title, IconData icon, int count) {
      final selected = _category == type;
      return ListTile(
        dense: true,
        selected: selected,
        selectedTileColor: theme.colorScheme.secondaryContainer,
        selectedColor: theme.colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.tokens.radiusMedium),
        ),
        leading: Icon(icon, size: 20),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text('$count', style: theme.textTheme.labelSmall),
        onTap: () => setState(() => _category = type),
      );
    }

    return ListView(
      padding: EdgeInsets.all(context.tokens.space2),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.tokens.space3,
            context.tokens.space2,
            context.tokens.space3,
            context.tokens.space2,
          ),
          child: Text(
            S.of(context).Menu_Tool_Library,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        category(
          null,
          S.of(context).All_Tools,
          Icons.apps_rounded,
          sections.fold(0, (sum, section) => sum + section.tools.length),
        ),
        for (final (type, icon) in toolCategories)
          category(
            type,
            toolCategoryTitle(context, type),
            icon,
            sections.firstWhere((s) => s.type == type).tools.length,
          ),
        const Divider(height: 24),
        ..._menuRows(context, inDrawer: false),
      ],
    );
  }

  /// The rows the drawer and the sidebar share. [inDrawer] closes the drawer
  /// before navigating; the sidebar has nothing to close, and popping there
  /// would pop the library itself.
  List<Widget> _menuRows(BuildContext context, {required bool inDrawer}) {
    void open(Widget page) {
      if (inDrawer) Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }

    return [
      MoreRow(
        title: S.of(context).Recommended_by_Major,
        leadingIcon: Icons.school_rounded,
        onTap: () => open(const MajorListPage()),
      ),
      MoreRow(
        title: S.of(context).Saved_Projects,
        leadingIcon: Icons.bookmark_rounded,
        onTap: () => open(const SavedProjectsPage()),
      ),
      const Divider(height: 24, indent: 16, endIndent: 16),
      MoreRow(
        title: S.of(context).Settings,
        leadingIcon: Icons.settings_rounded,
        onTap: () => open(const ToolSettingPage()),
      ),
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
          // The same destination under two names: the purchase stops ads
          // where there are ads, and unlocks the gated tools where there are
          // none.
          final gate = PremiumGate.watch(context);
          return MoreRow(
            title: gate.gatesFeatures
                ? (gate.isEntitled
                    ? S.of(context).Premium
                    : S.of(context).Unlock_Premium)
                : S.of(context).Remove_Ads,
            leadingIcon: gate.gatesFeatures
                ? (gate.isEntitled
                    ? Icons.verified_rounded
                    : Icons.workspace_premium_rounded)
                : (purchases.isAdsRemoved
                    ? Icons.verified_rounded
                    : Icons.block_rounded),
            onTap: () => open(const RemoveAdsPage()),
          );
        },
      ),
      MoreRow(
        title: S.of(context).Feedback,
        leadingIcon: Icons.chat_rounded,
        onTap: sendFeedbackEmail,
      ),
      MoreRow(
        title: S.of(context).RatethisApp,
        leadingIcon: Icons.thumb_up_rounded,
        onTap: openStoreListing,
      ),
      MoreRow(
        title: S.of(context).SharethisApp,
        leadingIcon: Icons.share_rounded,
        onTap: () async {
          final Size size = MediaQuery.of(context).size;
          // macOS is the same App Store listing as iOS — one record, two
          // platforms — so it shares the same link, and share_plus wants the
          // anchor rect on desktop for the same reason iPad does: the sheet
          // is a popover.
          if (Platform.isIOS || Platform.isMacOS) {
            await SharePlus.instance.share(ShareParams(
              text: 'https://apps.apple.com/app/id1601099443',
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
        onTap: () => open(const MoreAppPage()),
      ),
      // Also reachable from Settings; surfaced here because store review and
      // several privacy regimes expect it to be easy to find.
      MoreRow(
        title: S.of(context).Privacy_Policy,
        leadingIcon: Icons.policy_rounded,
        onTap: () => launchUrl(
          Uri.parse(privacyPolicyUrl),
          mode: LaunchMode.externalApplication,
        ),
      ),
    ];
  }

  Widget buildContents(BuildContext context) {
    final gate = PremiumGate.watch(context);
    final inCategory = _category == null ||
            MediaQuery.sizeOf(context).width < kLibrarySidebarWidth
        ? sections
        : sections.where((section) => section.type == _category).toList();
    final visibleSections = _searchTerms.isEmpty
        ? inCategory
        : inCategory
            .map(
              (section) => ToolSection(
                section.title,
                section.tools
                    .where((tool) => _matchesSearch(tool, section.title))
                    .toList(),
                section.type,
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
                  focusNode: _searchFocus,
                  onChanged: _updateSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: withShortcutHint(
                        S.of(context).Search_Tools, AppCommand.findTool),
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
            if (gate.showsLocks)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _FreeTierNotice(
                    freeCount: kFreeToolIds.length,
                    totalCount: sections.fold(
                      0,
                      (sum, section) => sum + section.tools.length,
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
    final isFavorite = favoritesList.items.contains(itemNo);
    final primary = Theme.of(context).colorScheme.primary;
    final isLocked = PremiumGate.watch(context).isToolLocked(itemNo);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.tokens.radiusLarge),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () => launchTool(context, model),
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
            if (isLocked) ...[
              const PremiumLockBadge(),
              const SizedBox(width: 4),
            ],
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
    final isFavorite = favoritesList.items.contains(itemNo);
    final primary = Theme.of(context).colorScheme.primary;
    final isLocked = PremiumGate.watch(context).isToolLocked(itemNo);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.tokens.radiusLarge),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () => launchTool(context, model),
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
                  if (isLocked)
                    const Positioned(
                      top: -2,
                      left: -2,
                      child: PremiumLockBadge(compact: true),
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

/// Explains the free tier at the top of the library, once, in one line.
///
/// Shown only where something is actually locked, and phrased as a count
/// rather than a nag: an engineer deciding whether this app is worth buying is
/// better served by "18 of 60 are free" than by a padlock they have to tap to
/// understand.
class _FreeTierNotice extends StatelessWidget {
  const _FreeTierNotice({required this.freeCount, required this.totalCount});

  final int freeCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 20,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.Premium_Free_Tools_Note(freeCount, totalCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () => showPremiumUpsell(
                context,
                reason: strings.Unlock_Premium,
              ),
              child: Text(strings.See_Premium),
            ),
          ],
        ),
      ),
    );
  }
}
