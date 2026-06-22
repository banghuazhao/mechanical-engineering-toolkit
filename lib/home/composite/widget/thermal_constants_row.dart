import 'package:flutter/material.dart';

class ThermalConstants {
  double? alpha11;
  double? alpha22;
  double? alpha12;

  bool isValid({bool requireAlpha12 = true}) {
    if (alpha11 == null || alpha22 == null) return false;
    if (requireAlpha12 && alpha12 == null) return false;
    return true;
  }
}

class ThermalConstantsRow extends StatelessWidget {
  final ThermalConstants thermalConstants;
  final bool validate;
  final bool showAlpha12;

  const ThermalConstantsRow({
    Key? key,
    required this.thermalConstants,
    required this.validate,
    this.showAlpha12 = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'THERMAL CONSTANTS (CTE)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _field(context, 'α₁₁', (v) => thermalConstants.alpha11 = v,
                    thermalConstants.alpha11, validate),
                const SizedBox(height: 10),
                _field(context, 'α₂₂', (v) => thermalConstants.alpha22 = v,
                    thermalConstants.alpha22, validate),
                if (showAlpha12) ...[
                  const SizedBox(height: 10),
                  _field(context, 'α₁₂', (v) => thermalConstants.alpha12 = v,
                      thermalConstants.alpha12, validate),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(BuildContext context, String label, ValueChanged<double?> onChanged,
      double? currentValue, bool validate) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: label,
        errorText: validate && currentValue == null ? 'Required' : null,
      ),
      onChanged: (v) => onChanged(double.tryParse(v)),
    );
  }
}
