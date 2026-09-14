import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:mechanical_engineering_toolkit/purchase/tool_unlock_service.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:provider/provider.dart';

/// The tools iOS and macOS include without a purchase or rewarded ad.
///
/// Chosen so the free app is a usable engineering companion rather than a
/// demo: every lookup table, and at least one working calculator from each of
/// the nine categories, weighted towards the first-year staples an engineer
/// reaches for most (axial stress, torsion, bending, buckling, von Mises).
/// Additional tools require Premium or, on iOS, a rewarded ad.
///
/// Ids are the ones registered in `lib/home/tool_model.dart`; a tool missing
/// from that library simply never comes up.
///
/// Android remains ungated. iOS can unlock each additional tool with an ad.
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

  // Thermodynamics — the steam tables, which are a lookup like the reference
  // tables above; the cycles built on them are what Premium adds.
  900,
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
/// iOS gates tools; macOS also gates advanced features. Rewarded unlocks
/// apply only to individual iOS tools and never grant Premium.
@immutable
class PremiumGate {
  const PremiumGate({
    required this.isEntitled,
    required this.gatesFeatures,
    bool? gatesTools,
    this.rewardedToolIds = const {},
  }) : gatesTools = gatesTools ?? gatesFeatures;

  /// Nothing is gated, as on Android.
  const PremiumGate.ungated()
      : isEntitled = true,
        gatesFeatures = false,
        gatesTools = false,
        rewardedToolIds = const {};

  /// The purchase has been made (or restored from another device).
  final bool isEntitled;

  /// This platform gates advanced features. False on iOS and Android.
  final bool gatesFeatures;
  final bool gatesTools;
  final Set<int> rewardedToolIds;

  bool get usesPremiumWording => gatesTools || gatesFeatures;

  /// How many history entries a free macOS build keeps visible. The rest are
  /// still recorded — the unlock reveals them rather than starting over.
  static const int freeHistoryLimit = 5;

  /// Rebuilds the caller when the entitlement changes.
  static PremiumGate watch(BuildContext context) => _from(
      context.watch<RemoveAdsService>(), context.watch<ToolUnlockService?>());

  /// The same answer without subscribing, for callbacks.
  static PremiumGate read(BuildContext context) => _from(
      context.read<RemoveAdsService>(), context.read<ToolUnlockService?>());

  static PremiumGate _from(
          RemoveAdsService service, ToolUnlockService? unlocks) =>
      PremiumGate(
        isEntitled: service.isEntitled,
        gatesFeatures: AppPlatform.current.gatesFeatures,
        gatesTools: AppPlatform.current.gatesTools,
        rewardedToolIds: AppPlatform.current.supportsRewardedToolUnlocks
            ? unlocks?.unlockedToolIds ?? const {}
            : const {},
      );

  /// Everything is available: either this platform gates nothing, or the
  /// purchase has been made.
  bool get isUnlocked => !(gatesFeatures || gatesTools) || isEntitled;

  /// Something is being held back right now, so the UI should show locks and
  /// offer the upgrade. The inverse of [isUnlocked], named for readability at
  /// the call site.
  bool get showsLocks => !isUnlocked;

  /// Whether opening the tool with this id should offer the upgrade instead.
  bool isToolLocked(int toolId) =>
      gatesTools &&
      !isEntitled &&
      !kFreeToolIds.contains(toolId) &&
      !rewardedToolIds.contains(toolId);

  /// Whether [feature] should offer the upgrade instead of running.
  bool isFeatureLocked(PremiumFeature feature) => gatesFeatures && !isEntitled;

  /// How many history entries to show. Null means all of them.
  int? get historyLimit =>
      isFeatureLocked(PremiumFeature.fullHistory) ? freeHistoryLimit : null;

  @override
  bool operator ==(Object other) =>
      other is PremiumGate &&
      other.isEntitled == isEntitled &&
      other.gatesFeatures == gatesFeatures &&
      other.gatesTools == gatesTools &&
      setEquals(other.rewardedToolIds, rewardedToolIds);

  @override
  int get hashCode => Object.hash(isEntitled, gatesFeatures, gatesTools,
      Object.hashAllUnordered(rewardedToolIds));
}
