import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Supplies the typefaces a result report is drawn with.
///
/// The built-in PDF typefaces are WinAnsi-encoded and cannot draw Greek or
/// superscripts, which run through this app's labels and formulas (σ, τ, mm⁴).
/// [load] embeds the bundled Noto Sans, which covers Latin, Latin Extended,
/// Greek, Cyrillic and superscripts, plus the two CJK subsets that carry the
/// `ja`/`zh`/`zh_HK` labels and the maths operators Noto Sans omits.
class PdfReportFonts {
  PdfReportFonts({
    this.regular,
    this.bold,
    this.fallback = const <pw.Font>[],
  }) : _coverage = _coverageOf([regular, ...fallback]);

  /// Null means "use the PDF standard Helvetica" — no asset, Latin-1 only.
  /// Useful in tests; [load] is what production should use.
  final pw.Font? regular;
  final pw.Font? bold;

  /// Consulted rune by rune for anything [regular] cannot draw.
  final List<pw.Font> fallback;

  /// Code points the faces above can actually draw, read from their cmaps.
  ///
  /// Empty for the standard-Helvetica case, which [_covers] reads as Latin-1.
  final Set<int> _coverage;

  static final standard = PdfReportFonts();

  /// Keyed by [_fallbackAssets]' first entry — the two CJK faces overlap, so
  /// which one leads decides whether a Han character gets its Chinese or its
  /// Japanese glyph form.
  static final Map<String, PdfReportFonts> _cached = {};

  /// The CJK faces, most-preferred first for [languageCode].
  static List<String> _fallbackAssets(String? languageCode) {
    const sc = 'fonts/NotoSansCJKsc-Subset.ttf';
    const jp = 'fonts/NotoSansCJKjp-Subset.ttf';
    return languageCode == 'ja' ? const [jp, sc] : const [sc, jp];
  }

  /// Loads and caches the embedded report fonts for [languageCode].
  ///
  /// Falls back to [standard] if the assets cannot be read, so a font problem
  /// degrades the export rather than failing it outright.
  static Future<PdfReportFonts> load({String? languageCode}) async {
    final assets = _fallbackAssets(languageCode);
    final cached = _cached[assets.first];
    if (cached != null) return cached;
    try {
      final loaded = PdfReportFonts(
        regular:
            pw.Font.ttf(await rootBundle.load('fonts/NotoSans-Regular.ttf')),
        bold: pw.Font.ttf(await rootBundle.load('fonts/NotoSans-Bold.ttf')),
        fallback: [
          for (final asset in assets) pw.Font.ttf(await rootBundle.load(asset)),
        ],
      );
      return _cached[assets.first] = loaded;
    } catch (_) {
      return standard;
    }
  }

  @visibleForTesting
  static void resetCache() => _cached.clear();

  pw.ThemeData toTheme() => pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        fontFallback: fallback,
      );

  /// True when every character of [text] can be drawn.
  ///
  /// Callers use this to warn rather than to block: the pdf package omits a
  /// missing glyph silently, so without this check a reader gets a document
  /// with text quietly absent and no indication anything went wrong.
  bool hasGlyphsFor(String text) => !text.runes.any((rune) => !_covers(rune));

  bool _covers(int rune) {
    // Spaces, tabs and newlines are laid out rather than drawn, so a face need
    // not carry them.
    if (rune <= 0x20) return true;
    // No embedded face: the standard Helvetica is WinAnsi, so Latin-1 only.
    if (_coverage.isEmpty) return rune <= 0xFF;
    return _coverage.contains(rune);
  }

  /// Reads coverage from each face's cmap rather than from hard-coded Unicode
  /// ranges, so the warning cannot drift out of step with what the bundled
  /// assets happen to contain — including after a subset rebuild.
  static Set<int> _coverageOf(Iterable<pw.Font?> fonts) {
    final covered = <int>{};
    for (final font in fonts) {
      if (font is pw.TtfFont) {
        covered.addAll(TtfParser(font.data).charToGlyphIndexMap.keys);
      }
    }
    return covered;
  }
}

/// Every string a report draws, for checking coverage before exporting.
Iterable<String> reportStrings({
  required String toolName,
  required List<ResultSection> sections,
  List<String> formulaSteps = const [],
}) sync* {
  yield toolName;
  for (final section in sections) {
    yield section.title;
    for (final value in section.values) {
      yield value.label;
      final preformatted = value.value;
      if (preformatted != null) yield preformatted;
    }
  }
  yield* formulaSteps;
}

/// True when every string in the report can be drawn by [fonts].
bool canRenderReport({
  required PdfReportFonts fonts,
  required String toolName,
  required List<ResultSection> sections,
  List<String> formulaSteps = const [],
}) =>
    reportStrings(
      toolName: toolName,
      sections: sections,
      formulaSteps: formulaSteps,
    ).every(fonts.hasGlyphsFor);

/// Renders a one-page report of [sections] — the thing a student staples to a
/// problem set and an engineer drops into a design file.
///
/// Values are converted and formatted at render time from their SI values, so
/// the document reflects [system] and [precs] rather than whatever was on
/// screen. [formulaSteps], when given, is reproduced verbatim beneath the
/// tables as the worked derivation.
Future<Uint8List> buildResultPdf({
  required String toolName,
  required List<ResultSection> sections,
  required NumberPrecisionHelper precs,
  required UnitSystem system,
  List<String> formulaSteps = const [],
  PdfReportFonts? fonts,
  String? languageCode,
  DateTime? generatedAt,
}) async {
  final timestamp = generatedAt ?? DateTime.now();
  final reportFonts =
      fonts ?? await PdfReportFonts.load(languageCode: languageCode);
  final document = pw.Document(theme: reportFonts.toTheme());

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox.shrink()
          : pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(toolName,
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
      build: (context) => [
        _title(toolName, timestamp, system),
        pw.SizedBox(height: 18),
        for (final section in sections) ...[
          _sectionTable(section, precs, system),
          pw.SizedBox(height: 14),
        ],
        if (formulaSteps.isNotEmpty) _formulaBlock(formulaSteps),
      ],
    ),
  );

  return document.save();
}

pw.Widget _title(String toolName, DateTime generatedAt, UnitSystem system) {
  final unitSystem =
      system == UnitSystem.si ? 'Metric (SI)' : 'Imperial (US)';
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Mechanical Engineering Toolkit',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      pw.SizedBox(height: 4),
      pw.Text(toolName,
          style: const pw.TextStyle(
              fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 6),
      // A page of bare numbers is worthless later without these two facts.
      pw.Text(
        '$unitSystem  ·  ${_formatTimestamp(generatedAt)}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 10),
      pw.Divider(height: 1, color: PdfColors.grey400),
    ],
  );
}

String _formatTimestamp(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} '
      '${two(value.hour)}:${two(value.minute)}';
}

pw.Widget _sectionTable(
  ResultSection section,
  NumberPrecisionHelper precs,
  UnitSystem system,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        section.title,
        style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 6),
      pw.TableHelper.fromTextArray(
        cellStyle: const pw.TextStyle(fontSize: 10),
        headerStyle:
            const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        cellHeight: 18,
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(2),
          2: pw.FlexColumnWidth(1),
        },
        cellAlignments: const {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerLeft,
        },
        headers: const ['Quantity', 'Value', 'Unit'],
        data: [
          for (final value in section.values)
            [
              value.label,
              value.formattedValue(precs, system),
              value.unit(system),
            ],
        ],
      ),
    ],
  );
}

pw.Widget _formulaBlock(List<String> steps) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Formula',
            style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final step in steps)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(step,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
            ],
          ),
        ),
      ],
    );

/// ASCII-safe file stem, matching the rule the CSV and image exports use.
String pdfFileName(String toolName) {
  final stem = toolName
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return '${stem.isEmpty ? 'me_toolkit_result' : stem}.pdf';
}

/// Hands [bytes] to the platform share/print sheet.
///
/// [origin] anchors the popover iPadOS presents the sheet in, in global
/// coordinates — pass the rect of the control the user tapped. It is not
/// optional in practice: given no bounds, `Printing.sharePdf` substitutes
/// `Rect.fromCircle(center: Offset.zero, radius: 10)`, a rect outside the root
/// view, which mispositions the popover while its invisible dismiss layer still
/// covers the screen and swallows every touch — the app reads as frozen.
Future<void> shareResultPdf(
  String toolName,
  Uint8List bytes, {
  required Rect origin,
}) =>
    Printing.sharePdf(
      bytes: bytes,
      filename: pdfFileName(toolName),
      bounds: origin,
    );
