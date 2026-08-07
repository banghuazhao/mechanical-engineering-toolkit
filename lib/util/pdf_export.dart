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
/// Greek, Cyrillic and superscripts.
class PdfReportFonts {
  const PdfReportFonts({this.regular, this.bold});

  /// Null means "use the PDF standard Helvetica" — no asset, Latin-1 only.
  /// Useful in tests; [load] is what production should use.
  final pw.Font? regular;
  final pw.Font? bold;

  static const standard = PdfReportFonts();

  static PdfReportFonts? _cached;

  /// Loads and caches the embedded report fonts.
  ///
  /// Falls back to [standard] if the assets cannot be read, so a font problem
  /// degrades the export rather than failing it outright.
  static Future<PdfReportFonts> load() async {
    final cached = _cached;
    if (cached != null) return cached;
    try {
      final loaded = PdfReportFonts(
        regular: pw.Font.ttf(
            await rootBundle.load('fonts/NotoSans-Regular.ttf')),
        bold:
            pw.Font.ttf(await rootBundle.load('fonts/NotoSans-Bold.ttf')),
      );
      return _cached = loaded;
    } catch (_) {
      return standard;
    }
  }

  @visibleForTesting
  static void resetCache() => _cached = null;

  pw.ThemeData toTheme() => pw.ThemeData.withFont(base: regular, bold: bold);
}

/// Characters the app uses that the embedded Noto Sans does not carry, mapped
/// to the ASCII spelling every engineer reads the same way.
///
/// Noto Sans covers Greek and superscripts but not the Mathematical Operators
/// block, and √ alone appears in over twenty formula steps. Substituting a
/// handful of characters is a far better trade than bundling a second font for
/// four symbols.
const Map<String, String> _pdfSubstitutions = {
  '√': 'sqrt',
  '≈': '~=',
  '≤': '<=',
  '≥': '>=',
  '∑': 'sum',
  '≠': '!=',
};

/// Rewrites [text] so every character survives the embedded font.
String sanitizeForPdf(String text) {
  var out = text;
  _pdfSubstitutions.forEach((from, to) {
    if (out.contains(from)) out = out.replaceAll(from, to);
  });
  return out;
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

/// True when every string in the report can be drawn.
///
/// Callers use this to warn rather than to block: the pdf package omits a
/// missing glyph silently, so without this check a reader gets a document with
/// text quietly absent and no indication anything went wrong.
bool canRenderReport({
  required String toolName,
  required List<ResultSection> sections,
  List<String> formulaSteps = const [],
}) =>
    reportStrings(
      toolName: toolName,
      sections: sections,
      formulaSteps: formulaSteps,
    ).every(hasGlyphsFor);

/// True when [text] can be drawn by the embedded report font after
/// [sanitizeForPdf].
///
/// The remaining gap is CJK: three of the app's six locales localize tool
/// names into scripts Noto Sans (Latin/Greek/Cyrillic) does not carry.
bool hasGlyphsFor(String text) {
  final sanitized = sanitizeForPdf(text);
  return !sanitized.runes.any((rune) {
    if (rune <= 0x24F) return false; // Latin + Latin Extended-A/B
    if (rune >= 0x370 && rune <= 0x3FF) return false; // Greek
    if (rune >= 0x400 && rune <= 0x4FF) return false; // Cyrillic
    return !_alwaysDrawable.contains(rune);
  });
}

/// Characters above the ranges above that Noto Sans does carry.
const _alwaysDrawable = <int>{
  0x2013, 0x2014, // en/em dash
  0x2018, 0x2019, 0x201C, 0x201D, // curly quotes
  0x2022, // bullet
  0x00B0, // degree
  0x2070, 0x00B9, 0x00B2, 0x00B3, // superscripts 0-3
  0x2074, 0x2075, 0x2076, 0x2077, 0x2078, 0x2079, // superscripts 4-9
  0x00B7, // middle dot
  0x00B1, 0x00D7, 0x00F7, // plus-minus, times, divide
  0x00B5, // micro
  0x2032, 0x2033, // prime, double prime
};

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
  DateTime? generatedAt,
}) async {
  final timestamp = generatedAt ?? DateTime.now();
  final reportFonts = fonts ?? await PdfReportFonts.load();
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
              child: pw.Text(sanitizeForPdf(toolName),
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
      pw.Text(sanitizeForPdf(toolName),
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
        sanitizeForPdf(section.title),
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
              sanitizeForPdf(value.label),
              sanitizeForPdf(value.formattedValue(precs, system)),
              sanitizeForPdf(value.unit(system)),
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
                  child: pw.Text(sanitizeForPdf(step),
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
Future<void> shareResultPdf(String toolName, Uint8List bytes) =>
    Printing.sharePdf(bytes: bytes, filename: pdfFileName(toolName));
