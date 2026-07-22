import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'unit_system.dart';
import 'units.dart';

/// A numeric text field that is aware of the app-wide [UnitSystemPreference].
///
/// Callers always work in the app's SI display unit for [category] (see
/// `units.dart`) via [initialSI] / [onChangedSI] — the field itself handles
/// showing the right suffix for the current unit system and converting the
/// displayed number in place if the user switches systems mid-edit.
///
/// Pass `category: null` for dimensionless values (ratios, matrix entries,
/// values already unit-independent) — no suffix is shown and no conversion
/// happens.
class UnitField extends StatefulWidget {
  const UnitField({
    super.key,
    required this.label,
    required this.category,
    required this.initialSI,
    required this.onChangedSI,
    this.errorText,
    this.signed = true,
    this.isDense = false,
    this.contentPadding,
    this.border,
    this.errorStyle,
  });

  final String label;
  final UnitCategory? category;
  final double? initialSI;
  final ValueChanged<double?> onChangedSI;
  final String? Function(double? si)? errorText;
  final bool signed;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final TextStyle? errorStyle;

  @override
  State<UnitField> createState() => _UnitFieldState();
}

class _UnitFieldState extends State<UnitField> {
  final TextEditingController _controller = TextEditingController();
  UnitSystem? _lastSystem;
  double? _lastInitialSI;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UnitField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSI != _lastInitialSI) {
      _lastInitialSI = widget.initialSI;
      final system = _lastSystem ?? UnitSystem.si;
      final si = widget.initialSI;
      _controller.text = si == null ? '' : _fmt(_toDisplay(si, system));
    }
  }

  double _toDisplay(double si, UnitSystem system) {
    final category = widget.category;
    return category == null ? si : fromSI(si, category, system);
  }

  double? _toSI(double display, UnitSystem system) {
    final category = widget.category;
    return category == null ? display : toSI(display, category, system);
  }

  void _syncSystem(UnitSystem system) {
    if (_lastSystem == null) {
      final si = widget.initialSI;
      _controller.text = si == null ? '' : _fmt(_toDisplay(si, system));
      _lastInitialSI = si;
      _lastSystem = system;
      return;
    }
    if (_lastSystem == system) return;
    final v = double.tryParse(_controller.text);
    if (v != null) {
      final si = _toSI(v, _lastSystem!);
      if (si != null) {
        _controller.text = _fmt(_toDisplay(si, system));
      }
    }
    _lastSystem = system;
  }

  double? get _currentSI {
    final v = double.tryParse(_controller.text);
    if (v == null) return null;
    return _toSI(v, _lastSystem ?? UnitSystem.si);
  }

  String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) {
      return v.toStringAsFixed(0);
    }
    final s = v.toStringAsFixed(8);
    return s.contains('.')
        ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')
        : s;
  }

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    _syncSystem(system);
    final unit = widget.category == null
        ? null
        : unitLabel(widget.category!, system);

    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: true, signed: widget.signed),
      decoration: InputDecoration(
        labelText: widget.label,
        // Rendered as suffixIcon rather than suffixText: suffixText is only
        // painted once the field is focused or non-empty, but the unit has to
        // be readable before anything is typed.
        suffixIcon: unit == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 6, right: 12),
                child: Text(
                  unit,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        isDense: widget.isDense,
        contentPadding: widget.contentPadding,
        border: widget.border,
        errorText: widget.errorText?.call(_currentSI),
        errorStyle: widget.errorStyle,
      ),
      onChanged: (_) => widget.onChangedSI(_currentSI),
    );
  }
}
