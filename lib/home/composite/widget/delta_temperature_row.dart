import 'package:flutter/material.dart';

class DeltaTemperatureRow extends StatefulWidget {
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
  State<DeltaTemperatureRow> createState() => _DeltaTemperatureRowState();
}

class _DeltaTemperatureRowState extends State<DeltaTemperatureRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
                border: const OutlineInputBorder(),
                labelText: 'ΔT',
                errorText:
                    widget.validate && widget.value == null ? 'Required' : null,
                errorStyle: const TextStyle(fontSize: 10),
              ),
              onChanged: (v) => widget.onChanged(double.tryParse(v)),
            ),
          ),
        ],
      ),
    );
  }
}
