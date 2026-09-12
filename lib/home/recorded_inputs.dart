import 'package:flutter/widgets.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_solver.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/air_standard_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/ideal_gas_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/steam_tables_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/air_cycle_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/ideal_gas_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/steam_tables_page.dart';
import 'package:mechanical_engineering_toolkit/home/tolerance/page/tolerance_stackup_page.dart';

/// A recorded calculation's inputs, in the form a reader should see them.
///
/// [ToolHistory] and [SavedProjects] store exactly what a calculator needs to
/// replay itself, which is not always what a list row or a report should
/// print. Almost every tool records one number per labelled field and needs no
/// help; the exceptions are the tolerance stack-up and the beam analysis,
/// whose chain of dimensions and list of loads have no fixed length and are
/// each stored as a single JSON value. Showing those raw is a wall of braces
/// where the rest of the app shows numbers.
///
/// Anything this function does not recognise is passed through untouched, so a
/// tool added later reads as it always did without knowing about this.
Map<String, String> displayInputs(
  BuildContext context,
  Map<String, String> inputs,
) {
  final display = <String, String>{};
  for (final entry in inputs.entries) {
    if (entry.key == stackupChainKey) {
      final chain = describeStackupChain(entry.value);
      if (chain != null) {
        display[S.of(context).Stackup_Dimensions] = chain;
        continue;
      }
    }
    if (entry.key == beamLoadsKey) {
      final loads = describeBeamLoads(entry.value);
      if (loads != null) {
        display[S.of(context).Beam_Loads] = loads;
        continue;
      }
    }
    // Stored as the enum's own name so it survives a translation change;
    // shown as the arrangement's name in the reader's language.
    if (entry.key == beamSupportCaseKey) {
      BeamSupportCase? match;
      for (final value in BeamSupportCase.values) {
        if (value.name == entry.value) match = value;
      }
      if (match != null) {
        display[S.of(context).Support_Arrangement] =
            supportCaseLabel(context, match);
        continue;
      }
    }
    // The thermodynamics tools store their mode the same way.
    final mode = _modeLabel(context, entry.key, entry.value);
    if (mode != null) {
      display[mode.$1] = mode.$2;
      continue;
    }
    display[entry.key] = entry.value;
  }
  return display;
}

/// (heading, value) for a stored enum name, or null when [key] is not one.
(String, String)? _modeLabel(BuildContext context, String key, String value) {
  T? named<T extends Enum>(List<T> values) {
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    return null;
  }

  final l10n = S.of(context);
  switch (key) {
    case steamLookupKey:
      final lookup = named(SteamLookup.values);
      return lookup == null
          ? null
          : (l10n.Steam_Lookup, steamLookupLabel(context, lookup));
    case gasProcessKey:
      final process = named(GasProcess.values);
      return process == null
          ? null
          : (l10n.Process_Label, gasProcessLabel(context, process));
    case airCycleKey:
      final cycle = named(AirCycle.values);
      return cycle == null
          ? null
          : (l10n.Cycle_Label, airCycleLabel(context, cycle));
  }
  return null;
}

/// [displayInputs] as one line, the way a list row shows it.
String describeInputs(BuildContext context, Map<String, String> inputs) =>
    displayInputs(context, inputs)
        .entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
