import 'package:flutter/material.dart';

class DeltaTemperatureRow extends StatelessWidget {
  final ValueChanged<double?> onChanged;
  final double? value;
  final bool validate;

  const DeltaTemperatureRow({
    Key? key,
    required this.onChanged,
    required this.validate,
    this.value,
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
              'TEMPERATURE CHANGE',
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
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(
                labelText: 'ΔT',
                errorText: validate && value == null ? 'Required' : null,
              ),
              onChanged: (v) => onChanged(double.tryParse(v)),
            ),
          ),
        ],
      ),
    );
  }
}
