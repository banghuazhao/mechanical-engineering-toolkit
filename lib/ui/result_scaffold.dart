import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';

/// A "Formula" card showing the worked calculation, one step per line.
class FormulaCard extends StatelessWidget {
  const FormulaCard({super.key, required this.steps});

  /// Lines of the derivation, joined with newlines for display.
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: S.of(context).Formula,
      child: Text(
        steps.join('\n'),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

/// The common chrome every calculator result page wears: a "Result" app bar
/// with share / share-as-image / settings actions, the banner ad, and a
/// scrolling body captured inside a [RepaintBoundary] so it can be exported
/// as an image.
///
/// Pass the result cards as [children]; they are laid out in a [ListView]
/// inside an [AppContent] and separated by the standard spacing, so pages no
/// longer need to interleave `SizedBox(height: ...)` by hand.
class ResultScaffold extends StatefulWidget {
  const ResultScaffold({
    super.key,
    required this.toolName,
    this.children,
    this.body,
    this.title,
    this.shareLines,
    this.extraActions = const [],
  }) : assert(children != null || body != null,
            'Provide either children or a custom body');

  /// Display name of the tool. Heads the shared text and names the shared
  /// image file.
  final String toolName;

  /// Result cards, laid out top to bottom. Ignored when [body] is given.
  final List<Widget>? children;

  /// Replaces the default list layout for pages that need something else —
  /// a responsive grid, for instance. It is still captured for image export.
  final Widget? body;

  /// App bar title. Defaults to the localized "Result".
  final String? title;

  /// Builds the plain-text share body, one entry per line. When null the
  /// text-share action is hidden and only image sharing is offered.
  final List<String> Function()? shareLines;

  /// Actions inserted before the standard share/settings actions.
  final List<Widget> extraActions;

  @override
  State<ResultScaffold> createState() => _ResultScaffoldState();
}

class _ResultScaffoldState extends State<ResultScaffold> {
  final _exportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final tokens = context.tokens;
    final shareLines = widget.shareLines;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? l10n.Result),
        actions: [
          ...widget.extraActions,
          if (shareLines != null)
            IconButton(
              tooltip: l10n.Share_Results,
              icon: const Icon(Icons.share_rounded),
              onPressed: () => shareResult(widget.toolName, shareLines()),
            ),
          IconButton(
            tooltip: l10n.Share_as_Image,
            icon: const Icon(Icons.image_outlined),
            onPressed: () => shareResultImage(_exportKey, widget.toolName),
          ),
          IconButton(
            tooltip: l10n.Settings,
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolSettingPage()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: RepaintBoundary(
        key: _exportKey,
        child: widget.body ??
            AppContent(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                padding: EdgeInsets.all(tokens.space4),
                itemCount: widget.children!.length,
                separatorBuilder: (_, __) => SizedBox(height: tokens.space4),
                itemBuilder: (_, index) => widget.children![index],
              ),
            ),
      ),
    );
  }
}
