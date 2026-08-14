import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// with share and settings actions, the banner ad, and a scrolling body
/// captured inside a [RepaintBoundary] so it can be exported as an image.
///
/// Share opens a format picker rather than one action per format; which
/// formats appear depends on what the page declared. See [ShareFormat].
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
    this.leading = const [],
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

  /// Cards rendered above the declared [results] — the tool header, and
  /// anything else that belongs before the numbers, such as a diagram.
  ///
  /// [children] land *below* the result cards, so whatever has to stay at the
  /// top goes here instead. Ignored when [body] is given.
  final List<Widget> leading;

  /// The page's results declared as data.
  ///
  /// Supplying these is the preferred form: the cards on screen, the plain
  /// text share, and the CSV export are then all derived from one description,
  /// instead of the page rendering widgets and separately hand-writing a
  /// [shareLines] that says the same thing again. It is also what makes CSV
  /// export possible at all — a `List<String>` has already fused label, value,
  /// and unit into one string.
  ///
  /// When given, these render between [header] and [children], and supply
  /// [shareLines] if the page did not provide its own. A page with a custom
  /// [body] renders its own way and declares these purely to be exported.
  final List<ResultSection>? results;

  /// Replaces the default list layout for pages that need something else —
  /// a responsive grid, for instance. It is still captured for image export.
  final Widget? body;

  /// App bar title. Defaults to the localized "Result".
  final String? title;

  /// Builds the plain-text share body, one entry per line. When null — and
  /// [results] is too — the picker drops its Text option.
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

/// The ways a result can leave the app. Which of these are offered depends on
/// what the page declared — see [_ResultScaffoldState._showSharePicker].
enum ShareFormat { text, csv, pdf, image }

class _ResultScaffoldState extends State<ResultScaffold> {
  final _exportKey = GlobalKey();

  /// The share button, used to anchor iPad's share popover — see [_shareOrigin].
  final _shareButtonKey = GlobalKey();

  /// Where the share sheet should point on iPad, in global coordinates.
  ///
  /// iPadOS presents a share sheet as a popover and needs a rect inside the
  /// root view to hang it off. `Printing.sharePdf` does not default this
  /// usefully: given no bounds it sends `Rect.fromCircle(center: Offset.zero,
  /// radius: 10)` — a rect *outside* the view, above and left of its top-left
  /// corner — which leaves the popover mispositioned while its invisible
  /// dismiss layer still covers the screen and swallows every touch. The result
  /// looks exactly like a frozen app.
  ///
  /// Always returns a rect within the view: if the button has somehow not been
  /// laid out, the screen centre is a poor anchor but a harmless one.
  Rect _shareOrigin() {
    final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }

  /// Opens the format picker, then shares in whichever format was chosen.
  ///
  /// One button rather than four app-bar icons: the formats are alternatives,
  /// and a labelled sheet has room to say what each one is for, which a row of
  /// bare icons does not.
  Future<void> _showSharePicker(
    List<String> Function()? shareLines,
    List<ResultSection>? results,
    NumberPrecisionHelper precs,
    UnitSystem system,
  ) async {
    final format = await showModalBottomSheet<ShareFormat>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _SharePicker(
        // CSV and PDF need the structured results; text needs share lines.
        // An unmigrated page therefore offers only text and image.
        formats: [
          if (shareLines != null) ShareFormat.text,
          if (results != null) ShareFormat.csv,
          if (results != null) ShareFormat.pdf,
          ShareFormat.image,
        ],
      ),
    );
    if (format == null || !mounted) return;
    await _share(format, shareLines, results, precs, system);
  }

  Future<void> _share(
    ShareFormat format,
    List<String> Function()? shareLines,
    List<ResultSection>? results,
    NumberPrecisionHelper precs,
    UnitSystem system,
  ) async {
    switch (format) {
      case ShareFormat.text:
        await shareResult(widget.toolName, shareLines!());
      case ShareFormat.image:
        await shareResultImage(_exportKey, widget.toolName);
      case ShareFormat.csv:
        await shareResultCsv(
          widget.toolName,
          buildResultCsv(
            toolName: widget.toolName,
            sections: results!,
            precs: precs,
            system: system,
          ),
        );
      case ShareFormat.pdf:
        // Loaded up front so the coverage check and the render agree on which
        // faces are in play — the CJK fallbacks are picked by locale.
        final sections = results!;
        // Both read context, so they are taken before the first await.
        final origin = _shareOrigin();
        final fonts = await PdfReportFonts.load(
          languageCode: Localizations.localeOf(context).languageCode,
        );
        // The pdf package drops a glyph no embedded face carries, silently.
        // Say so rather than handing over a document with text absent.
        final complete = canRenderReport(
          fonts: fonts,
          toolName: widget.toolName,
          sections: sections,
          formulaSteps: widget.formulaSteps,
        );
        if (!complete && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).PDF_Missing_Characters)),
          );
        }
        final bytes = await buildResultPdf(
          toolName: widget.toolName,
          sections: sections,
          precs: precs,
          system: system,
          formulaSteps: widget.formulaSteps,
          fonts: fonts,
        );
        await shareResultPdf(widget.toolName, bytes, origin: origin);
    }
  }

  /// [ResultScaffold.leading] leads, then the declared results as one card per
  /// section, then any hand-built [ResultScaffold.children] the page still
  /// needs (diagrams, sweeps, formula cards).
  Widget _buildList(BuildContext context, AppTokens tokens) {
    final cards = <Widget>[
      ...widget.leading,
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
          // One share action for every format. Image is always available —
          // it is a capture of the screen and needs nothing declared.
          // KeyedSubtree adds no layout — it just gives _shareOrigin a handle
          // on the button's box while leaving the test key on the button.
          KeyedSubtree(
            key: _shareButtonKey,
            child: IconButton(
              key: const Key('shareResults'),
              tooltip: l10n.Share_Results,
              icon: const Icon(Icons.share_rounded),
              onPressed: () =>
                  _showSharePicker(shareLines, results, precs, system),
            ),
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

/// Bottom sheet listing the share formats a result page can offer.
///
/// Follows the same shape as the language picker: a title, a divider, then one
/// tappable row per choice.
class _SharePicker extends StatelessWidget {
  const _SharePicker({required this.formats});

  final List<ShareFormat> formats;

  static const _icons = {
    ShareFormat.text: Icons.notes_rounded,
    ShareFormat.csv: Icons.table_view_rounded,
    ShareFormat.pdf: Icons.picture_as_pdf_rounded,
    ShareFormat.image: Icons.image_rounded,
  };

  static const _keys = {
    ShareFormat.text: Key('shareFormatText'),
    ShareFormat.csv: Key('shareFormatCsv'),
    ShareFormat.pdf: Key('shareFormatPdf'),
    ShareFormat.image: Key('shareFormatImage'),
  };

  String _label(BuildContext context, ShareFormat format) {
    switch (format) {
      case ShareFormat.text:
        return S.of(context).Share_Format_Text;
      case ShareFormat.csv:
        return S.of(context).Share_Format_CSV;
      case ShareFormat.pdf:
        return S.of(context).Share_Format_PDF;
      case ShareFormat.image:
        return S.of(context).Share_Format_Image;
    }
  }

  String _description(BuildContext context, ShareFormat format) {
    switch (format) {
      case ShareFormat.text:
        return S.of(context).Share_Format_Text_Description;
      case ShareFormat.csv:
        return S.of(context).Share_Format_CSV_Description;
      case ShareFormat.pdf:
        return S.of(context).Share_Format_PDF_Description;
      case ShareFormat.image:
        return S.of(context).Share_Format_Image_Description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                S.of(context).Share_Results,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...formats.map(
              (format) => ListTile(
                key: _keys[format],
                leading: Icon(
                  _icons[format],
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(_label(context, format)),
                subtitle: Text(_description(context, format)),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context, format);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
