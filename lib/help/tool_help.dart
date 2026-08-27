import 'package:flutter/foundation.dart';

/// One governing equation.
///
/// Carries the same equation twice on purpose. [tex] is what a reader sees,
/// typeset the way a textbook prints it; [plain] is what the copy and share
/// actions put on the clipboard, because raw TeX pasted into an email is
/// noise. Keeping both in one place is what stops them drifting apart.
@immutable
class HelpFormula {
  const HelpFormula({
    required this.tex,
    required this.plain,
    this.caption,
  });

  /// The equation in TeX, for [Math.tex].
  final String tex;

  /// The same equation in plain Unicode, e.g. `σ = M·y / I`.
  final String plain;

  /// What the equation is for, when a block has more than one and the reader
  /// would otherwise have to guess which is which.
  final String? caption;
}

/// One symbol in the equations above, with the unit the app expects it in.
///
/// The unit matters more than it looks: most of these formulas are only
/// dimensionally consistent in one particular combination, and "N·mm or N·m?"
/// is the question that actually costs people an hour.
@immutable
class HelpSymbol {
  const HelpSymbol(this.symbol, this.meaning, [this.unit]);

  final String symbol;
  final String meaning;

  /// SI unit as the tool takes it, or null for a dimensionless quantity.
  final String? unit;
}

/// The long-form explanation behind a tool's one-line description.
///
/// The tool page already carries a `Desc_*` line saying what the tool
/// computes. This is the rest of it: where the equation comes from, what each
/// symbol is, what the model assumes, and where to read more — the things a
/// user needs before trusting a number enough to put it on a drawing.
@immutable
class ToolHelp {
  const ToolHelp({
    required this.summary,
    this.formulas = const [],
    this.symbols = const [],
    this.notes = const [],
    this.references = const [],
    this.diagram,
  });

  /// What the tool does and when you would reach for it. Two to four
  /// sentences — longer than the one-liner on the input page, shorter than a
  /// textbook section.
  final String summary;

  final List<HelpFormula> formulas;
  final List<HelpSymbol> symbols;

  /// What the model assumes, and where it stops being true. Written as the
  /// limits of *this* calculation rather than as general theory: "slender
  /// columns only" is useful, "elasticity is complicated" is not.
  final List<String> notes;

  /// Where the relations come from — a standard, or a textbook a reader can
  /// actually find. Enough to look up, not a full bibliography.
  final List<String> references;

  /// Asset path of a diagram that makes the geometry unambiguous, where the
  /// app already ships one. Sign conventions are far easier to show than to
  /// describe.
  final String? diagram;
}
