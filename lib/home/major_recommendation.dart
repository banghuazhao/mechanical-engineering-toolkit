import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

class MajorRecommendation {
  /// Resolves the display name in the active locale. Takes the lookup rather
  /// than a literal so the list below can stay `const`.
  final String Function(S) _title;
  final IconData icon;
  final List<int> toolIds;

  const MajorRecommendation({
    required String Function(S) title,
    required this.icon,
    required this.toolIds,
  }) : _title = title;

  String title(BuildContext context) => _title(S.of(context));
}

String _mechanical(S s) => s.Mechanical_Engineering;
String _civil(S s) => s.Civil_Structural_Engineering;
String _aerospace(S s) => s.Aerospace_Engineering;
String _materials(S s) => s.Materials_Science_Engineering;

const List<MajorRecommendation> majorRecommendations = [
  MajorRecommendation(
    title: _mechanical,
    icon: Icons.precision_manufacturing_rounded,
    toolIds: [
      100, 101, 102, 103, 104, 114, 115, 112, 116, 500, 501, 502, 503,
      506, // bolt grades and tightening torque
      118, 119, 120, 121, // stress analysis / joint design
      701, 702, 703, 704, 705, 706, 707, 708, // machine element sizing
      712, // power screws
      709, 710, 711, // vibration and critical speed
      800, 801, 802, 810, 811, 812, // fluids and heat transfer
    ],
  ),
  MajorRecommendation(
    title: _civil,
    icon: Icons.foundation_rounded,
    toolIds: [
      401, 105, 106, 117, 102, 111, 400, 402, 113, 403, 118, 120, 707, 503,
      506, // bolt grades for structural connections
      710, // floor and footbridge vibration
      801, 810, // building services and envelope heat loss
    ],
  ),
  MajorRecommendation(
    title: _aerospace,
    icon: Icons.flight_rounded,
    toolIds: [
      300, 301, 302, 303, 304, 305, 110, 109, 111,
      119, 120, 121, 306, 706, // fatigue, joints, composite failure
      709, 710, // flutter/resonance margins on shafts and structures
      800, 801, 811, 812, // propulsion and thermal management
    ],
  ),
  MajorRecommendation(
    title: _materials,
    icon: Icons.science_rounded,
    toolIds: [116, 108, 107, 301, 305, 200, 201, 112, 306, 810],
  ),
];
