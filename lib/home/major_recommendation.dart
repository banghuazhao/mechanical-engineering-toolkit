import 'package:flutter/material.dart';

class MajorRecommendation {
  final String title;
  final IconData icon;
  final List<int> toolIds;

  const MajorRecommendation({
    required this.title,
    required this.icon,
    required this.toolIds,
  });
}

const List<MajorRecommendation> majorRecommendations = [
  MajorRecommendation(
    title: 'Mechanical Engineering',
    icon: Icons.precision_manufacturing_rounded,
    toolIds: [
      100, 101, 102, 103, 104, 114, 115, 112, 116, 500,
      118, 119, 120, 121, // stress analysis / joint design
      701, 702, 703, 704, 705, 706, 707, 708, // machine element sizing
    ],
  ),
  MajorRecommendation(
    title: 'Civil / Structural Engineering',
    icon: Icons.foundation_rounded,
    toolIds: [401, 105, 106, 117, 102, 111, 400, 402, 113, 403, 118, 120, 707],
  ),
  MajorRecommendation(
    title: 'Aerospace Engineering',
    icon: Icons.flight_rounded,
    toolIds: [
      300, 301, 302, 303, 304, 305, 110, 109, 111,
      119, 120, 121, 306, 706, // fatigue, joints, composite failure
    ],
  ),
  MajorRecommendation(
    title: 'Materials Science Engineering',
    icon: Icons.science_rounded,
    toolIds: [116, 108, 107, 301, 305, 200, 201, 112, 306],
  ),
];
