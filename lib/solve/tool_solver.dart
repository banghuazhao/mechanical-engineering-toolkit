import 'package:flutter/widgets.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// One quantity a [ToolSolver] can vary or aim at.
@immutable
class SolveQuantity {
  const SolveQuantity(
    this.key,
    this.label, {
    this.category,
    this.positive = true,
  });

  /// For an input, the key the tool records it under in its history entry —
  /// which is also the key its input page reads back from `initialInputs`, so
  /// a solved value can reopen the tool with that field filled in. For an
  /// output, any key [ToolSolver.evaluate] returns it under.
  final String key;

  /// The field's name as the tool's own page shows it.
  final String Function(S l10n) label;

  /// Its unit, or null when dimensionless. Values are in the app's SI
  /// display unit for this category, as everywhere else.
  final UnitCategory? category;

  /// Whether only values above zero make sense — true of nearly every
  /// dimension, load and property. A stress or a temperature may be signed.
  final bool positive;
}

/// Runs a tool backwards: given its recorded inputs, which of them can be
/// varied and which outputs can be aimed at, and a pure function from inputs
/// to outputs.
///
/// A calculator is written forwards — diameter in, stress out — but the
/// design question is usually the reverse: what diameter keeps the stress at
/// 150 MPa? Every calculator already records its inputs as a string map to
/// replay itself from history, so that map is the solver's currency: vary
/// one entry, evaluate, compare, repeat. A solver adds no new model of the
/// physics; [evaluate] calls the tool's own calculator.
@immutable
class ToolSolver {
  const ToolSolver({
    required this.inputs,
    required this.outputs,
    required this.evaluate,
  });

  /// The inputs that can be solved for, given the recorded inputs — a tool
  /// with modes or section shapes offers only the fields that mode uses.
  final List<SolveQuantity> Function(Map<String, String> recorded) inputs;

  /// The outputs that can be aimed at, likewise.
  final List<SolveQuantity> Function(Map<String, String> recorded) outputs;

  /// Every output, keyed as in [outputs], for one set of inputs. Throws — any
  /// exception — where the inputs describe nothing, which the solver treats
  /// as "undefined here" rather than as a failure.
  final Map<String, double> Function(Map<String, String> inputs) evaluate;

  /// A solver whose inputs and outputs do not depend on a mode.
  factory ToolSolver.fixed({
    required List<SolveQuantity> inputs,
    required List<SolveQuantity> outputs,
    required Map<String, double> Function(Map<String, String> inputs) evaluate,
  }) =>
      ToolSolver(
        inputs: (_) => inputs,
        outputs: (_) => outputs,
        evaluate: evaluate,
      );
}

/// Reads a recorded number, treating a missing or blank entry as [fallback].
double inputValue(Map<String, String> inputs, String key,
        [double fallback = 0]) =>
    double.tryParse(inputs[key] ?? '') ?? fallback;

/// Reads a recorded number that the calculation cannot do without.
double requiredInput(Map<String, String> inputs, String key) {
  final value = double.tryParse(inputs[key] ?? '');
  if (value == null) throw FormatException('missing $key');
  return value;
}
