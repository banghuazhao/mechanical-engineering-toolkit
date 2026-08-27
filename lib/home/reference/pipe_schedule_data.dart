import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

/// The wall-thickness series this library covers, from ASME B36.10M.
///
/// A schedule is not a thickness — it is a series. The same schedule number
/// gives a different wall on every size, which is exactly why a table is
/// needed: nobody can recall that 2" Sch 40 is 3.91 mm but 8" Sch 40 is
/// 8.18 mm.
enum PipeSchedule { sch10, sch40, sch80, sch160 }

extension PipeScheduleLabel on PipeSchedule {
  /// The number as it is written on a drawing or a mill certificate.
  String get label => switch (this) {
        PipeSchedule.sch10 => 'Sch 10',
        PipeSchedule.sch40 => 'Sch 40',
        PipeSchedule.sch80 => 'Sch 80',
        PipeSchedule.sch160 => 'Sch 160',
      };
}

/// One nominal pipe size.
///
/// The outside diameter is a property of the size alone and never changes with
/// schedule — pipe is made to a fixed OD so that the same fittings, flanges
/// and threads fit every wall. A heavier schedule eats into the bore instead,
/// which is why inside diameter is derived here rather than tabulated: it
/// cannot then disagree with the OD and wall it came from.
///
/// Note that NPS is a *name*, not a measurement. NPS 2 pipe has neither a 2"
/// bore nor a 2" outside diameter; only from NPS 14 up does the number equal
/// the OD in inches.
class PipeSize {
  const PipeSize._({
    required this.nps,
    required this.npsLabel,
    required this.dn,
    required this.outsideDiameter,
    required this.walls,
  });

  /// Nominal pipe size in inches, as a number — for sorting and for matching a
  /// typed query. See [npsLabel] for how it is written.
  final double nps;

  /// NPS as it appears on a drawing, e.g. `1 1/4`.
  final String npsLabel;

  /// The ISO nominal diameter, e.g. DN 32. A label, like NPS.
  final int dn;

  /// Outside diameter, mm.
  final double outsideDiameter;

  /// Wall thickness in mm, by schedule. A size carries only the schedules that
  /// are actually made in it: Sch 160 starts at NPS 1/2, and the three
  /// smallest sizes are made in Sch 40 and 80 only.
  final Map<PipeSchedule, double> walls;
}

/// One size-and-schedule pair: a row of the table, and what the picker hands
/// back to a calculator.
class PipeSpec {
  const PipeSpec(this.size, this.schedule);

  final PipeSize size;
  final PipeSchedule schedule;

  double get outsideDiameter => size.outsideDiameter;

  /// Wall thickness, mm.
  double get wallThickness => size.walls[schedule]!;

  /// Bore, mm. Derived — see [PipeSize].
  double get insideDiameter => outsideDiameter - 2 * wallThickness;

  /// Cross-sectional flow area, mm². What a velocity-from-flow-rate
  /// calculation actually needs.
  double get flowArea => math.pi * insideDiameter * insideDiameter / 4;

  /// The older weight-class name for this wall, where one applies.
  ///
  /// Standard weight and extra strong predate the schedule numbers and are
  /// still what gets written on drawings and quoted by suppliers. They track
  /// Sch 40 and Sch 80 only up to a point: above NPS 10, STD stays at 9.53 mm
  /// while Sch 40 keeps thickening, and above NPS 8 the same happens to XS at
  /// 12.70 mm. So the alias is reported only over the range where the two
  /// genuinely coincide, rather than implying an equivalence that stops.
  String? get weightClass {
    if (schedule == PipeSchedule.sch40 && size.nps <= 10) return 'STD';
    if (schedule == PipeSchedule.sch80 && size.nps <= 8) return 'XS';
    return null;
  }

  /// How the pipe would be called out, e.g. `NPS 2 Sch 40`.
  String get designation => 'NPS ${size.npsLabel} ${schedule.label}';

  /// Everything a search should match: both naming systems, the schedule, and
  /// the weight class, so "dn50", "2", "sch 40" and "std" all find the row.
  String get searchText =>
      '${size.npsLabel} nps${size.npsLabel} dn${size.dn} ${size.dn} '
      '${schedule.label} ${weightClass ?? ''}';
}

/// ASME B36.10M welded and seamless wrought steel pipe, NPS 1/8 to 24.
///
/// Dimensions are millimetres, matching the app's SI display unit for length.
/// Only the four schedules in [PipeSchedule] are carried: they cover the great
/// majority of process and utility piping, and a table nobody can scroll is
/// worse than a shorter one that answers the question.
const List<PipeSize> pipeSizes = [
  PipeSize._(nps: 0.125, npsLabel: '1/8', dn: 6, outsideDiameter: 10.3, walls: {
    PipeSchedule.sch40: 1.73,
    PipeSchedule.sch80: 2.41,
  }),
  PipeSize._(nps: 0.25, npsLabel: '1/4', dn: 8, outsideDiameter: 13.7, walls: {
    PipeSchedule.sch40: 2.24,
    PipeSchedule.sch80: 3.02,
  }),
  PipeSize._(nps: 0.375, npsLabel: '3/8', dn: 10, outsideDiameter: 17.1, walls: {
    PipeSchedule.sch40: 2.31,
    PipeSchedule.sch80: 3.20,
  }),
  PipeSize._(nps: 0.5, npsLabel: '1/2', dn: 15, outsideDiameter: 21.3, walls: {
    PipeSchedule.sch10: 2.11,
    PipeSchedule.sch40: 2.77,
    PipeSchedule.sch80: 3.73,
    PipeSchedule.sch160: 4.78,
  }),
  PipeSize._(nps: 0.75, npsLabel: '3/4', dn: 20, outsideDiameter: 26.7, walls: {
    PipeSchedule.sch10: 2.11,
    PipeSchedule.sch40: 2.87,
    PipeSchedule.sch80: 3.91,
    PipeSchedule.sch160: 5.56,
  }),
  PipeSize._(nps: 1, npsLabel: '1', dn: 25, outsideDiameter: 33.4, walls: {
    PipeSchedule.sch10: 2.77,
    PipeSchedule.sch40: 3.38,
    PipeSchedule.sch80: 4.55,
    PipeSchedule.sch160: 6.35,
  }),
  PipeSize._(
      nps: 1.25, npsLabel: '1 1/4', dn: 32, outsideDiameter: 42.2, walls: {
    PipeSchedule.sch10: 2.77,
    PipeSchedule.sch40: 3.56,
    PipeSchedule.sch80: 4.85,
    PipeSchedule.sch160: 6.35,
  }),
  PipeSize._(
      nps: 1.5, npsLabel: '1 1/2', dn: 40, outsideDiameter: 48.3, walls: {
    PipeSchedule.sch10: 2.77,
    PipeSchedule.sch40: 3.68,
    PipeSchedule.sch80: 5.08,
    PipeSchedule.sch160: 7.14,
  }),
  PipeSize._(nps: 2, npsLabel: '2', dn: 50, outsideDiameter: 60.3, walls: {
    PipeSchedule.sch10: 2.77,
    PipeSchedule.sch40: 3.91,
    PipeSchedule.sch80: 5.54,
    PipeSchedule.sch160: 8.74,
  }),
  PipeSize._(
      nps: 2.5, npsLabel: '2 1/2', dn: 65, outsideDiameter: 73.0, walls: {
    PipeSchedule.sch10: 3.05,
    PipeSchedule.sch40: 5.16,
    PipeSchedule.sch80: 7.01,
    PipeSchedule.sch160: 9.53,
  }),
  PipeSize._(nps: 3, npsLabel: '3', dn: 80, outsideDiameter: 88.9, walls: {
    PipeSchedule.sch10: 3.05,
    PipeSchedule.sch40: 5.49,
    PipeSchedule.sch80: 7.62,
    PipeSchedule.sch160: 11.13,
  }),
  PipeSize._(nps: 4, npsLabel: '4', dn: 100, outsideDiameter: 114.3, walls: {
    PipeSchedule.sch10: 3.05,
    PipeSchedule.sch40: 6.02,
    PipeSchedule.sch80: 8.56,
    PipeSchedule.sch160: 13.49,
  }),
  PipeSize._(nps: 5, npsLabel: '5', dn: 125, outsideDiameter: 141.3, walls: {
    PipeSchedule.sch10: 3.40,
    PipeSchedule.sch40: 6.55,
    PipeSchedule.sch80: 9.53,
    PipeSchedule.sch160: 15.88,
  }),
  PipeSize._(nps: 6, npsLabel: '6', dn: 150, outsideDiameter: 168.3, walls: {
    PipeSchedule.sch10: 3.40,
    PipeSchedule.sch40: 7.11,
    PipeSchedule.sch80: 10.97,
    PipeSchedule.sch160: 18.26,
  }),
  PipeSize._(nps: 8, npsLabel: '8', dn: 200, outsideDiameter: 219.1, walls: {
    PipeSchedule.sch10: 3.76,
    PipeSchedule.sch40: 8.18,
    PipeSchedule.sch80: 12.70,
    PipeSchedule.sch160: 23.01,
  }),
  PipeSize._(nps: 10, npsLabel: '10', dn: 250, outsideDiameter: 273.0, walls: {
    PipeSchedule.sch10: 4.19,
    PipeSchedule.sch40: 9.27,
    PipeSchedule.sch80: 15.09,
    PipeSchedule.sch160: 28.58,
  }),
  PipeSize._(nps: 12, npsLabel: '12', dn: 300, outsideDiameter: 323.8, walls: {
    PipeSchedule.sch10: 4.57,
    PipeSchedule.sch40: 10.31,
    PipeSchedule.sch80: 17.48,
    PipeSchedule.sch160: 33.32,
  }),
  PipeSize._(nps: 14, npsLabel: '14', dn: 350, outsideDiameter: 355.6, walls: {
    PipeSchedule.sch10: 4.78,
    PipeSchedule.sch40: 11.13,
    PipeSchedule.sch80: 19.05,
    PipeSchedule.sch160: 35.71,
  }),
  PipeSize._(nps: 16, npsLabel: '16', dn: 400, outsideDiameter: 406.4, walls: {
    PipeSchedule.sch10: 4.78,
    PipeSchedule.sch40: 12.70,
    PipeSchedule.sch80: 21.44,
    PipeSchedule.sch160: 40.49,
  }),
  PipeSize._(nps: 18, npsLabel: '18', dn: 450, outsideDiameter: 457.0, walls: {
    PipeSchedule.sch10: 4.78,
    PipeSchedule.sch40: 14.27,
    PipeSchedule.sch80: 23.83,
    PipeSchedule.sch160: 45.24,
  }),
  PipeSize._(nps: 20, npsLabel: '20', dn: 500, outsideDiameter: 508.0, walls: {
    PipeSchedule.sch10: 5.54,
    PipeSchedule.sch40: 15.09,
    PipeSchedule.sch80: 26.19,
    PipeSchedule.sch160: 50.01,
  }),
  PipeSize._(nps: 24, npsLabel: '24', dn: 600, outsideDiameter: 610.0, walls: {
    PipeSchedule.sch10: 6.35,
    PipeSchedule.sch40: 17.48,
    PipeSchedule.sch80: 30.96,
    PipeSchedule.sch160: 59.54,
  }),
];

/// Every size-and-schedule combination, ordered by size then by schedule —
/// the order a catalogue lists them in.
final List<PipeSpec> pipeSpecs = [
  for (final size in pipeSizes)
    for (final schedule in PipeSchedule.values)
      if (size.walls.containsKey(schedule)) PipeSpec(size, schedule),
];

/// Localized name of the reference, for pages that need it before a row.
String pipeSchedulesTitle(BuildContext context) => S.of(context).Pipe_Schedules;
