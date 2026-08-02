/// Thread and drill reference data for the drill & tap chart.
///
/// Tap drills are the standard sizes for roughly 75% thread engagement.
/// Metric clearance holes follow ISO 273 (fine series = close, coarse series =
/// free); inch clearance holes are the customary close/free fit drills.
library;

enum ThreadSeries { metricCoarse, metricFine, unifiedCoarse, unifiedFine }

/// A drill, identified by diameter and — for inch drills — the number, letter,
/// or fractional designation it is sold under.
class DrillSize {
  const DrillSize(this.mm, [this.designation]);

  final double mm;
  final String? designation;

  String get millimeters {
    final text = mm.toStringAsFixed(2);
    final trimmed =
        text.endsWith('0') ? text.substring(0, text.length - 1) : text;
    return trimmed;
  }

  /// What a table cell leads with: the designation you would ask for at the
  /// drill index, or the diameter itself when the drill has no designation.
  String get headline => designation ?? millimeters;

  /// The millimetre equivalent, shown under [headline] only when the headline
  /// is a designation rather than a diameter.
  String? get subline => designation == null ? null : millimeters;

  @override
  String toString() =>
      designation == null ? millimeters : '$designation ($millimeters)';
}

class ThreadEntry {
  const ThreadEntry({
    required this.series,
    required this.size,
    required this.pitch,
    required this.tapDrill,
    required this.clearanceClose,
    required this.clearanceFree,
  });

  final ThreadSeries series;

  /// Thread designation without the series suffix, e.g. `M8` or `1/4-20`.
  final String size;

  /// Pitch in mm for metric threads, threads per inch for unified threads.
  final String pitch;

  final DrillSize tapDrill;
  final DrillSize clearanceClose;
  final DrillSize clearanceFree;

  bool get isMetric =>
      series == ThreadSeries.metricCoarse || series == ThreadSeries.metricFine;
}

const List<ThreadEntry> threadEntries = [
  // --- Metric coarse (ISO 261) -------------------------------------------
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M1.6',
    pitch: '0.35 mm',
    tapDrill: DrillSize(1.25),
    clearanceClose: DrillSize(1.7),
    clearanceFree: DrillSize(2.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M2',
    pitch: '0.4 mm',
    tapDrill: DrillSize(1.6),
    clearanceClose: DrillSize(2.2),
    clearanceFree: DrillSize(2.6),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M2.5',
    pitch: '0.45 mm',
    tapDrill: DrillSize(2.05),
    clearanceClose: DrillSize(2.7),
    clearanceFree: DrillSize(3.1),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M3',
    pitch: '0.5 mm',
    tapDrill: DrillSize(2.5),
    clearanceClose: DrillSize(3.2),
    clearanceFree: DrillSize(3.6),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M4',
    pitch: '0.7 mm',
    tapDrill: DrillSize(3.3),
    clearanceClose: DrillSize(4.3),
    clearanceFree: DrillSize(4.8),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M5',
    pitch: '0.8 mm',
    tapDrill: DrillSize(4.2),
    clearanceClose: DrillSize(5.3),
    clearanceFree: DrillSize(5.8),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M6',
    pitch: '1.0 mm',
    tapDrill: DrillSize(5.0),
    clearanceClose: DrillSize(6.4),
    clearanceFree: DrillSize(7.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M8',
    pitch: '1.25 mm',
    tapDrill: DrillSize(6.8),
    clearanceClose: DrillSize(8.4),
    clearanceFree: DrillSize(10.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M10',
    pitch: '1.5 mm',
    tapDrill: DrillSize(8.5),
    clearanceClose: DrillSize(10.5),
    clearanceFree: DrillSize(12.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M12',
    pitch: '1.75 mm',
    tapDrill: DrillSize(10.2),
    clearanceClose: DrillSize(13.0),
    clearanceFree: DrillSize(14.5),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M14',
    pitch: '2.0 mm',
    tapDrill: DrillSize(12.0),
    clearanceClose: DrillSize(15.0),
    clearanceFree: DrillSize(16.5),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M16',
    pitch: '2.0 mm',
    tapDrill: DrillSize(14.0),
    clearanceClose: DrillSize(17.0),
    clearanceFree: DrillSize(18.5),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M18',
    pitch: '2.5 mm',
    tapDrill: DrillSize(15.5),
    clearanceClose: DrillSize(19.0),
    clearanceFree: DrillSize(21.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M20',
    pitch: '2.5 mm',
    tapDrill: DrillSize(17.5),
    clearanceClose: DrillSize(21.0),
    clearanceFree: DrillSize(24.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M22',
    pitch: '2.5 mm',
    tapDrill: DrillSize(19.5),
    clearanceClose: DrillSize(23.0),
    clearanceFree: DrillSize(26.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M24',
    pitch: '3.0 mm',
    tapDrill: DrillSize(21.0),
    clearanceClose: DrillSize(25.0),
    clearanceFree: DrillSize(28.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M27',
    pitch: '3.0 mm',
    tapDrill: DrillSize(24.0),
    clearanceClose: DrillSize(28.0),
    clearanceFree: DrillSize(32.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M30',
    pitch: '3.5 mm',
    tapDrill: DrillSize(26.5),
    clearanceClose: DrillSize(31.0),
    clearanceFree: DrillSize(35.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricCoarse,
    size: 'M36',
    pitch: '4.0 mm',
    tapDrill: DrillSize(32.0),
    clearanceClose: DrillSize(37.0),
    clearanceFree: DrillSize(42.0),
  ),

  // --- Metric fine --------------------------------------------------------
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M4×0.5',
    pitch: '0.5 mm',
    tapDrill: DrillSize(3.5),
    clearanceClose: DrillSize(4.3),
    clearanceFree: DrillSize(4.8),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M5×0.5',
    pitch: '0.5 mm',
    tapDrill: DrillSize(4.5),
    clearanceClose: DrillSize(5.3),
    clearanceFree: DrillSize(5.8),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M6×0.75',
    pitch: '0.75 mm',
    tapDrill: DrillSize(5.25),
    clearanceClose: DrillSize(6.4),
    clearanceFree: DrillSize(7.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M8×1',
    pitch: '1.0 mm',
    tapDrill: DrillSize(7.0),
    clearanceClose: DrillSize(8.4),
    clearanceFree: DrillSize(10.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M10×1.25',
    pitch: '1.25 mm',
    tapDrill: DrillSize(8.75),
    clearanceClose: DrillSize(10.5),
    clearanceFree: DrillSize(12.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M10×1',
    pitch: '1.0 mm',
    tapDrill: DrillSize(9.0),
    clearanceClose: DrillSize(10.5),
    clearanceFree: DrillSize(12.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M12×1.5',
    pitch: '1.5 mm',
    tapDrill: DrillSize(10.5),
    clearanceClose: DrillSize(13.0),
    clearanceFree: DrillSize(14.5),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M12×1.25',
    pitch: '1.25 mm',
    tapDrill: DrillSize(10.75),
    clearanceClose: DrillSize(13.0),
    clearanceFree: DrillSize(14.5),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M14×1.5',
    pitch: '1.5 mm',
    tapDrill: DrillSize(12.5),
    clearanceClose: DrillSize(15.0),
    clearanceFree: DrillSize(16.5),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M16×1.5',
    pitch: '1.5 mm',
    tapDrill: DrillSize(14.5),
    clearanceClose: DrillSize(17.0),
    clearanceFree: DrillSize(18.5),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M18×1.5',
    pitch: '1.5 mm',
    tapDrill: DrillSize(16.5),
    clearanceClose: DrillSize(19.0),
    clearanceFree: DrillSize(21.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M20×1.5',
    pitch: '1.5 mm',
    tapDrill: DrillSize(18.5),
    clearanceClose: DrillSize(21.0),
    clearanceFree: DrillSize(24.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M22×1.5',
    pitch: '1.5 mm',
    tapDrill: DrillSize(20.5),
    clearanceClose: DrillSize(23.0),
    clearanceFree: DrillSize(26.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M24×2',
    pitch: '2.0 mm',
    tapDrill: DrillSize(22.0),
    clearanceClose: DrillSize(25.0),
    clearanceFree: DrillSize(28.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M27×2',
    pitch: '2.0 mm',
    tapDrill: DrillSize(25.0),
    clearanceClose: DrillSize(28.0),
    clearanceFree: DrillSize(32.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M30×2',
    pitch: '2.0 mm',
    tapDrill: DrillSize(28.0),
    clearanceClose: DrillSize(31.0),
    clearanceFree: DrillSize(35.0),
  ),
  ThreadEntry(
    series: ThreadSeries.metricFine,
    size: 'M36×3',
    pitch: '3.0 mm',
    tapDrill: DrillSize(33.0),
    clearanceClose: DrillSize(37.0),
    clearanceFree: DrillSize(42.0),
  ),

  // --- Unified coarse (UNC) ----------------------------------------------
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#1-64',
    pitch: '64 TPI',
    tapDrill: DrillSize(1.51, '#53'),
    clearanceClose: DrillSize(1.93, '#48'),
    clearanceFree: DrillSize(2.06, '#46'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#2-56',
    pitch: '56 TPI',
    tapDrill: DrillSize(1.78, '#50'),
    clearanceClose: DrillSize(2.26, '#43'),
    clearanceFree: DrillSize(2.44, '#41'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#3-48',
    pitch: '48 TPI',
    tapDrill: DrillSize(1.99, '#47'),
    clearanceClose: DrillSize(2.64, '#37'),
    clearanceFree: DrillSize(2.79, '#35'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#4-40',
    pitch: '40 TPI',
    tapDrill: DrillSize(2.26, '#43'),
    clearanceClose: DrillSize(2.95, '#32'),
    clearanceFree: DrillSize(3.26, '#30'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#5-40',
    pitch: '40 TPI',
    tapDrill: DrillSize(2.58, '#38'),
    clearanceClose: DrillSize(3.26, '#30'),
    clearanceFree: DrillSize(3.45, '#29'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#6-32',
    pitch: '32 TPI',
    tapDrill: DrillSize(2.70, '#36'),
    clearanceClose: DrillSize(3.66, '#27'),
    clearanceFree: DrillSize(3.80, '#25'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#8-32',
    pitch: '32 TPI',
    tapDrill: DrillSize(3.45, '#29'),
    clearanceClose: DrillSize(4.31, '#18'),
    clearanceFree: DrillSize(4.50, '#16'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#10-24',
    pitch: '24 TPI',
    tapDrill: DrillSize(3.80, '#25'),
    clearanceClose: DrillSize(4.98, '#9'),
    clearanceFree: DrillSize(5.11, '#7'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '#12-24',
    pitch: '24 TPI',
    tapDrill: DrillSize(4.50, '#16'),
    clearanceClose: DrillSize(5.61, '#2'),
    clearanceFree: DrillSize(5.79, '#1'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '1/4-20',
    pitch: '20 TPI',
    tapDrill: DrillSize(5.11, '#7'),
    clearanceClose: DrillSize(6.53, 'F'),
    clearanceFree: DrillSize(6.76, 'H'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '5/16-18',
    pitch: '18 TPI',
    tapDrill: DrillSize(6.53, 'F'),
    clearanceClose: DrillSize(8.20, 'P'),
    clearanceFree: DrillSize(8.43, 'Q'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '3/8-16',
    pitch: '16 TPI',
    tapDrill: DrillSize(7.94, '5/16'),
    clearanceClose: DrillSize(9.80, 'W'),
    clearanceFree: DrillSize(10.08, 'X'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '7/16-14',
    pitch: '14 TPI',
    tapDrill: DrillSize(9.35, 'U'),
    clearanceClose: DrillSize(11.51, '29/64'),
    clearanceFree: DrillSize(11.91, '15/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '1/2-13',
    pitch: '13 TPI',
    tapDrill: DrillSize(10.72, '27/64'),
    clearanceClose: DrillSize(13.10, '33/64'),
    clearanceFree: DrillSize(13.49, '17/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '9/16-12',
    pitch: '12 TPI',
    tapDrill: DrillSize(12.30, '31/64'),
    clearanceClose: DrillSize(14.68, '37/64'),
    clearanceFree: DrillSize(15.08, '19/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '5/8-11',
    pitch: '11 TPI',
    tapDrill: DrillSize(13.49, '17/32'),
    clearanceClose: DrillSize(16.27, '41/64'),
    clearanceFree: DrillSize(16.67, '21/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '3/4-10',
    pitch: '10 TPI',
    tapDrill: DrillSize(16.67, '21/32'),
    clearanceClose: DrillSize(19.45, '49/64'),
    clearanceFree: DrillSize(19.84, '25/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '7/8-9',
    pitch: '9 TPI',
    tapDrill: DrillSize(19.45, '49/64'),
    clearanceClose: DrillSize(22.62, '57/64'),
    clearanceFree: DrillSize(23.02, '29/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedCoarse,
    size: '1"-8',
    pitch: '8 TPI',
    tapDrill: DrillSize(22.23, '7/8'),
    clearanceClose: DrillSize(25.80, '1-1/64'),
    clearanceFree: DrillSize(26.19, '1-1/32'),
  ),

  // --- Unified fine (UNF) -------------------------------------------------
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#0-80',
    pitch: '80 TPI',
    tapDrill: DrillSize(1.19, '3/64'),
    clearanceClose: DrillSize(1.61, '#52'),
    clearanceFree: DrillSize(1.78, '#50'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#1-72',
    pitch: '72 TPI',
    tapDrill: DrillSize(1.51, '#53'),
    clearanceClose: DrillSize(1.93, '#48'),
    clearanceFree: DrillSize(2.06, '#46'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#2-64',
    pitch: '64 TPI',
    tapDrill: DrillSize(1.78, '#50'),
    clearanceClose: DrillSize(2.26, '#43'),
    clearanceFree: DrillSize(2.44, '#41'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#3-56',
    pitch: '56 TPI',
    tapDrill: DrillSize(2.08, '#45'),
    clearanceClose: DrillSize(2.64, '#37'),
    clearanceFree: DrillSize(2.79, '#35'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#4-48',
    pitch: '48 TPI',
    tapDrill: DrillSize(2.37, '#42'),
    clearanceClose: DrillSize(2.95, '#32'),
    clearanceFree: DrillSize(3.26, '#30'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#5-44',
    pitch: '44 TPI',
    tapDrill: DrillSize(2.64, '#37'),
    clearanceClose: DrillSize(3.26, '#30'),
    clearanceFree: DrillSize(3.45, '#29'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#6-40',
    pitch: '40 TPI',
    tapDrill: DrillSize(2.87, '#33'),
    clearanceClose: DrillSize(3.66, '#27'),
    clearanceFree: DrillSize(3.80, '#25'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#8-36',
    pitch: '36 TPI',
    tapDrill: DrillSize(3.45, '#29'),
    clearanceClose: DrillSize(4.31, '#18'),
    clearanceFree: DrillSize(4.50, '#16'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#10-32',
    pitch: '32 TPI',
    tapDrill: DrillSize(4.04, '#21'),
    clearanceClose: DrillSize(4.98, '#9'),
    clearanceFree: DrillSize(5.11, '#7'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '#12-28',
    pitch: '28 TPI',
    tapDrill: DrillSize(4.62, '#14'),
    clearanceClose: DrillSize(5.61, '#2'),
    clearanceFree: DrillSize(5.79, '#1'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '1/4-28',
    pitch: '28 TPI',
    tapDrill: DrillSize(5.41, '#3'),
    clearanceClose: DrillSize(6.53, 'F'),
    clearanceFree: DrillSize(6.76, 'H'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '5/16-24',
    pitch: '24 TPI',
    tapDrill: DrillSize(6.91, 'I'),
    clearanceClose: DrillSize(8.20, 'P'),
    clearanceFree: DrillSize(8.43, 'Q'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '3/8-24',
    pitch: '24 TPI',
    tapDrill: DrillSize(8.43, 'Q'),
    clearanceClose: DrillSize(9.80, 'W'),
    clearanceFree: DrillSize(10.08, 'X'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '7/16-20',
    pitch: '20 TPI',
    tapDrill: DrillSize(9.92, '25/64'),
    clearanceClose: DrillSize(11.51, '29/64'),
    clearanceFree: DrillSize(11.91, '15/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '1/2-20',
    pitch: '20 TPI',
    tapDrill: DrillSize(11.51, '29/64'),
    clearanceClose: DrillSize(13.10, '33/64'),
    clearanceFree: DrillSize(13.49, '17/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '9/16-18',
    pitch: '18 TPI',
    tapDrill: DrillSize(13.10, '33/64'),
    clearanceClose: DrillSize(14.68, '37/64'),
    clearanceFree: DrillSize(15.08, '19/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '5/8-18',
    pitch: '18 TPI',
    tapDrill: DrillSize(14.68, '37/64'),
    clearanceClose: DrillSize(16.27, '41/64'),
    clearanceFree: DrillSize(16.67, '21/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '3/4-16',
    pitch: '16 TPI',
    tapDrill: DrillSize(17.46, '11/16'),
    clearanceClose: DrillSize(19.45, '49/64'),
    clearanceFree: DrillSize(19.84, '25/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '7/8-14',
    pitch: '14 TPI',
    tapDrill: DrillSize(20.64, '13/16'),
    clearanceClose: DrillSize(22.62, '57/64'),
    clearanceFree: DrillSize(23.02, '29/32'),
  ),
  ThreadEntry(
    series: ThreadSeries.unifiedFine,
    size: '1"-12',
    pitch: '12 TPI',
    tapDrill: DrillSize(23.42, '59/64'),
    clearanceClose: DrillSize(25.80, '1-1/64'),
    clearanceFree: DrillSize(26.19, '1-1/32'),
  ),
];
