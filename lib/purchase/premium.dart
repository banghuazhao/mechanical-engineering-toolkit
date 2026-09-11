import 'package:flutter/widgets.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:provider/provider.dart';

/// The tools a macOS build hands out without a purchase.
///
/// Chosen so the free app is a usable engineering companion rather than a
/// demo: every lookup table, and at least one working calculator from each of
/// the eight categories, weighted towards the first-year staples an engineer
/// reaches for most (axial stress, torsion, bending, buckling, von Mises).
/// Everything else — and every export — is what the unlock is for.
///
/// Ids are the ones registered in `lib/home/tool_model.dart`; a tool missing
/// from that library simply never comes up.
///
/// This set has no effect on iOS or Android, where nothing is gated.
const Set<int> kFreeToolIds = {
  // Reference and utilities — lookups, free in full.
  500, // Unit Converter
  501, // Drill & Tap Chart
  502, // Fits & Tolerances
  503, // Standard Sections
  504, // Pipe Schedules
  506, // Bolt Grades & Torque

  // Mechanics of Material
  100, // General stress
  101, // Force–displacement relation of bar
  103, // Torsion formula of bar
  111, // Buckling load of column
  116, // Failure criteria (von Mises / Tresca)

  // Beam Engineering
  102, // Moments of inertia of plane areas
  104, // Flexure formula of beam

  // One from each remaining category, so every section of the library shows
  // something that works before the user is asked for anything.
  701, // Machine Design — helical compression spring
  400, // Statics — resultant of forces (2D)
  200, // Theory of Elasticity — linear elastic constitutive relation
  300, // Composite Material — lamina stress/strain
  800, // Fluids & Thermal — Reynolds number
};

/// The things a macOS build holds back, beyond the locked tools themselves.
enum PremiumFeature {
  /// The typeset PDF report, and the multi-calculation project report.
  pdfExport,

  /// The spreadsheet export.
  csvExport,

  /// Sharing the result cards as a PNG.
  imageExport,

  /// Collecting calculations into named projects.
  savedProjects,

  /// History beyond [PremiumGate.freeHistoryLimit] entries.
  fullHistory,

  /// The what-if chart that sweeps one input across a range.
  parameterSweep,
}

/// Answers "may this build do that yet?".
///
/// One object rather than a `Platform.isMacOS && !purchased` test at each call
/// site, because the two halves of that condition are easy to get subtly wrong
/// in opposite directions: forget the platform check and an iPhone loses its
/// PDF export; forget the entitlement check and the unlock does nothing.
///
/// Immutable and cheap — build one per widget build from [watch] or [read].
@immutable
class PremiumGate {
  const PremiumGate({required this.isEntitled, required this.gatesFeatures});

  /// Nothing is gated: the mobile builds, which monetize with ads instead.
  const PremiumGate.ungated()
      : isEntitled = true,
        gatesFeatures = false;

  /// The purchase has been made (or restored from another device).
  final bool isEntitled;

  /// This platform gates anything at all. False on iOS and Android.
  final bool gatesFeatures;

  /// How many history entries a free macOS build keeps visible. The rest are
  /// still recorded — the unlock reveals them rather than starting over.
  static const int freeHistoryLimit = 5;

  /// Rebuilds the caller when the entitlement changes.
  static PremiumGate watch(BuildContext context) =>
      _from(context.watch<RemoveAdsService>());

  /// The same answer without subscribing, for callbacks.
  static PremiumGate read(BuildContext context) =>
      _from(context.read<RemoveAdsService>());

  static PremiumGate _from(RemoveAdsService service) => PremiumGate(
        isEntitled: service.isEntitled,
        gatesFeatures: AppPlatform.current.gatesFeatures,
      );

  /// Everything is available: either this platform gates nothing, or the
  /// purchase has been made.
  bool get isUnlocked => !gatesFeatures || isEntitled;

  /// Something is being held back right now, so the UI should show locks and
  /// offer the upgrade. The inverse of [isUnlocked], named for readability at
  /// the call site.
  bool get showsLocks => !isUnlocked;

  /// Whether opening the tool with this id should offer the upgrade instead.
  bool isToolLocked(int toolId) =>
      showsLocks && !kFreeToolIds.contains(toolId);

  /// Whether [feature] should offer the upgrade instead of running.
  bool isFeatureLocked(PremiumFeature feature) => showsLocks;

  /// How many history entries to show. Null means all of them.
  int? get historyLimit => showsLocks ? freeHistoryLimit : null;

  @override
  bool operator ==(Object other) =>
      other is PremiumGate &&
      other.isEntitled == isEntitled &&
      other.gatesFeatures == gatesFeatures;

  @override
  int get hashCode => Object.hash(isEntitled, gatesFeatures);
}
