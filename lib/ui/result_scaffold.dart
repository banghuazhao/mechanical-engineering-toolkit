import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/csv_export.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/pdf_export.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';

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
    this.results,
    this.title,
    this.shareLines,
    this.extraActions = const [],
    this.formulaSteps = const [],
  }) : assert(children != null || body != null || results != null,
            'Provide results, children, or a custom body');

  /// Display name of the tool. Heads the shared text and names the shared
  /// image file.
  final String toolName;

  /// Result cards, laid out top to bottom. Ignored when [body] is given.
  final List<Widget>? children;

  /// The page's results declared as data.
  ///
  /// Supplying these is the preferred form: the cards on screen, the plain
  /// text share, and the CSV export are then all derived from one description,
  /// instead of the page rendering widgets and separately hand-writing a
  /// [shareLines] that says the same thing again. It is also what makes CSV
  /// export possible at all — a `List<String>` has already fused label, value,
  /// and unit into one string.
  ///
  /// When given, these render above [children] and supply [shareLines] if the
  /// page did not provide its own.
  final List<ResultSection>? results;

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

  /// The worked derivation, reproduced in the PDF report beneath the tables.
  ///
  /// Pass the same steps given to the page's [FormulaCard]; a report without
  /// the derivation is much less use for coursework.
  final List<String> formulaSteps;

  @override
  State<ResultScaffold> createState() => _ResultScaffoldState();
}

enum _ExportFormat { csv, pdf }

class _ResultScaffoldState extends State<ResultScaffold> {
  final _exportKey = GlobalKey();

  Future<void> _export(
    _ExportFormat format,
    List<ResultSection> results,
    NumberPrecisionHelper precs,
    UnitSystem system,
  ) async {
    switch (format) {
      case _ExportFormat.csv:
        await shareResultCsv(
          widget.toolName,
          buildResultCsv(
            toolName: widget.toolName,
            sections: results,
            precs: precs,
            system: system,
          ),
        );
      case _ExportFormat.pdf:
        final bytes = await buildResultPdf(
          toolName: widget.toolName,
          sections: results,
          precs: precs,
          system: system,
          formulaSteps: widget.formulaSteps,
        );
        await shareResultPdf(widget.toolName, bytes);
    }
  }

  /// Declared results render first, as one card per section, followed by any
  /// hand-built [ResultScaffold.children] the page still needs (diagrams,
  /// sweeps, formula cards).
  Widget _buildList(BuildContext context, AppTokens tokens) {
    final cards = <Widget>[
      for (final section in widget.results ?? const <ResultSection>[])
        AppSectionCard(
          title: section.title,
          child: Column(
            children: [
              for (final value in section.values)
                AppCopyableValue(
                  label: value.label,
                  value: value.value,
                  valueSI: value.valueSI,
                  category: value.category,
                ),
            ],
          ),
        ),
      ...?widget.children,
    ];

    return AppContent(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        padding: EdgeInsets.all(tokens.space4),
        itemCount: cards.length,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space4),
        itemBuilder: (_, index) => cards[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final tokens = context.tokens;
    final results = widget.results;
    final precs = context.watch<NumberPrecisionHelper>();
    final system = context.watch<UnitSystemPreference>().system;

    // A page that declares its results as data gets its share text for free;
    // one that has not migrated yet keeps supplying its own.
    final shareLines = widget.shareLines ??
        (results == null
            ? null
            : () => resultShareLines(results, precs, system));

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
          // Only offered where the structure a spreadsheet or report needs
          // actually exists. Pre-formatted share lines cannot be split into
          // columns.
          if (results != null)
            PopupMenuButton<_ExportFormat>(
              tooltip: l10n.Export,
              icon: const Icon(Icons.file_download_outlined),
              onSelected: (format) => _export(format, results, precs, system),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _ExportFormat.csv,
                  child: Text(l10n.Export_CSV),
                ),
                PopupMenuItem(
                  value: _ExportFormat.pdf,
                  child: Text(l10n.Export_PDF),
                ),
              ],
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
        child: widget.body ?? _buildList(context, tokens),
      ),
    );
  }
}
