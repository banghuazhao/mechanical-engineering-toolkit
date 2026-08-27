import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// A result page's numbers, frozen so a report can reproduce them later
/// without re-running the calculation.
///
/// ## What is and is not preserved
///
/// Values are stored as SI magnitudes with their [UnitCategory] wherever the
/// page declared them that way, never as formatted text. A report built from a
/// snapshot therefore renders in the reader's *current* unit system and
/// precision, exactly as a live result page would — switching the app to
/// imperial changes a year-old snapshot too.
///
/// Labels are the exception: they are stored as text, so they stay in the
/// language they were captured in. Re-localizing them would mean re-running
/// the tool, and a saved record that silently changed wording is arguably
/// worse than one that is honestly a snapshot.
class ResultSnapshot {
  const ResultSnapshot({
    required this.toolName,
    required this.sections,
    this.formulaSteps = const [],
    required this.capturedAt,
  });

  /// The tool's name as it read when captured. Used as the section heading in
  /// a report; the live tool name is preferred where a [toolId] resolves.
  final String toolName;

  final List<ResultSection> sections;

  /// The worked derivation, reproduced under the tables.
  final List<String> formulaSteps;

  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
        'toolName': toolName,
        'capturedAt': capturedAt.toIso8601String(),
        'sections': [for (final section in sections) _sectionToJson(section)],
        if (formulaSteps.isNotEmpty) 'formula': formulaSteps,
      };

  /// Reads tolerantly: a value that cannot be understood is dropped rather
  /// than taking the snapshot — and with it the whole project record — down.
  factory ResultSnapshot.fromJson(Map<String, dynamic> json) => ResultSnapshot(
        toolName: json['toolName'] as String? ?? '',
        capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        sections: [
          for (final raw in (json['sections'] as List? ?? const []))
            if (raw is Map<String, dynamic>) _sectionFromJson(raw),
        ],
        formulaSteps: [
          for (final step in (json['formula'] as List? ?? const []))
            '$step',
        ],
      );
}

Map<String, dynamic> _sectionToJson(ResultSection section) => {
      'title': section.title,
      'values': [
        for (final value in section.values)
          {
            'label': value.label,
            // Only one of these is meaningful — see [ResultValue].
            if (value.valueSI != null) 'si': value.valueSI,
            if (value.category != null) 'cat': value.category!.name,
            if (value.valueSI == null) 'text': value.value,
          },
      ],
    };

ResultSection _sectionFromJson(Map<String, dynamic> json) => ResultSection(
      title: json['title'] as String? ?? '',
      values: [
        for (final raw in (json['values'] as List? ?? const []))
          if (raw is Map<String, dynamic>) _valueFromJson(raw),
      ],
    );

ResultValue _valueFromJson(Map<String, dynamic> json) {
  final si = (json['si'] as num?)?.toDouble();
  return ResultValue(
    label: json['label'] as String? ?? '',
    valueSI: si,
    category: si == null ? null : _categoryByName(json['cat'] as String?),
    // ResultValue asserts that one of the two is present, and a record with
    // neither would otherwise throw on read.
    value: si == null ? (json['text'] as String? ?? '') : null,
  );
}

/// Resolves a stored category name, tolerating one this build no longer has.
///
/// A dropped or renamed [UnitCategory] leaves the value dimensionless rather
/// than unreadable: the number still renders, it just stops converting.
UnitCategory? _categoryByName(String? name) {
  if (name == null) return null;
  for (final category in UnitCategory.values) {
    if (category.name == name) return category;
  }
  return null;
}
