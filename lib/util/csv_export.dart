import 'dart:convert';
import 'dart:typed_data';

import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:share_plus/share_plus.dart';

/// Quotes a CSV field when it contains a comma, quote, or newline, doubling
/// any embedded quotes (RFC 4180).
String csvEscape(String field) {
  if (!field.contains(RegExp(r'[",\r\n]'))) return field;
  return '"${field.replaceAll('"', '""')}"';
}

String _row(List<String> fields) => fields.map(csvEscape).join(',');

/// Builds a spreadsheet-ready CSV for a set of result sections.
///
/// Values are converted and formatted at export time from their SI values, so
/// the file reflects the reader's current unit system and precision rather
/// than whatever was on screen when the calculation ran. A short preamble
/// records which unit system that was, because a column of bare numbers is
/// worthless six months later.
String buildResultCsv({
  required String toolName,
  required List<ResultSection> sections,
  required NumberPrecisionHelper precs,
  required UnitSystem system,
  DateTime? generatedAt,
}) {
  final timestamp = (generatedAt ?? DateTime.now()).toIso8601String();
  final rows = <String>[
    _row(['Mechanical Engineering Toolkit', toolName]),
    _row(['Generated', timestamp]),
    _row(['Unit system', system == UnitSystem.si ? 'Metric (SI)' : 'Imperial (US)']),
    '',
    _row(['Section', 'Quantity', 'Value', 'Unit']),
  ];

  for (final section in sections) {
    for (final value in section.values) {
      rows.add(_row([
        section.title,
        value.label,
        value.formattedValue(precs, system),
        value.unit(system),
      ]));
    }
  }

  return '${rows.join('\r\n')}\r\n';
}

/// ASCII-safe file stem, since a fully localized tool name can sanitize down
/// to nothing. Mirrors the rule [shareResultImage] uses.
String csvFileName(String toolName) {
  final stem = toolName
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return '${stem.isEmpty ? 'me_toolkit_result' : stem}.csv';
}

/// UTF-8 bytes with a leading byte-order mark.
///
/// The BOM matters: without it Excel misreads the µ, °, and Greek letters that
/// turn up throughout these results.
Uint8List csvBytes(String csv) =>
    Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);

/// Shares [csv] as a .csv file.
Future<void> shareResultCsv(String toolName, String csv) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          csvBytes(csv),
          mimeType: 'text/csv',
          name: csvFileName(toolName),
        )
      ],
      text: '[$toolName] — ME Toolkit',
    ),
  );
}
