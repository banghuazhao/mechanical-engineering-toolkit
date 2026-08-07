import 'dart:typed_data';

import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Supplies the typefaces a result report is drawn with.
///
/// This is a seam rather than a hardcoded font because the built-in PDF
/// typefaces cover Latin only. A tool name in Chinese or Japanese renders as
/// empty boxes with [PdfReportFonts.standard]; see [hasGlyphsFor].
class PdfReportFonts {
  const PdfReportFonts({this.regular, this.bold});

  /// Null means "use the PDF standard Helvetica", which needs no asset and no
  /// network but covers Latin scripts only.
  final pw.Font? regular;
  final pw.Font? bold;

  static const standard = PdfReportFonts();

  pw.ThemeData toTheme() => pw.ThemeData.withFont(base: regular, bold: bold);
}

/// True when [text] is entirely within the range the standard PDF typefaces
/// can draw. Anything outside Latin-1 plus common punctuation — CJK above all
/// — needs an embedded font.
bool hasGlyphsFor(String text) =>
    !text.runes.any((rune) => rune > 0x24F && !_alwaysDrawable.contains(rune));

/// Symbols this app uses constantly that sit outside Latin-1 but are present
/// in the standard typefaces or degrade acceptably.
const _alwaysDrawable = <int>{
  0x2013, 0x2014, // en/em dash
  0x2018, 0x2019, 0x201C, 0x201D, // curly quotes
  0x2022, // bullet
  0x00B0, // degree
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
  PdfReportFonts fonts = PdfReportFonts.standard,
  DateTime? generatedAt,
}) async {
  final timestamp = generatedAt ?? DateTime.now();
  final document = pw.Document(theme: fonts.toTheme());

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
                  child: pw.Text(step, style: const pw.TextStyle(fontSize: 10)),
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
