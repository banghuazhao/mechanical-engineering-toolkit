import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';

class AnalysisTypeRow extends StatelessWidget {
  final AnalysisType value;
  final ValueChanged<AnalysisType> onChanged;

  const AnalysisTypeRow(
      {Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Analysis Type',
                style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<AnalysisType>(
              segments: const [
                ButtonSegment(
                    value: AnalysisType.elastic, label: Text('Elastic')),
                ButtonSegment(
                    value: AnalysisType.thermalElastic, label: Text('Thermal')),
              ],
              selected: {value},
              onSelectionChanged: (s) => onChanged(s.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.white
                        : primary),
                backgroundColor: WidgetStateProperty.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? primary
                        : Colors.transparent),
                side: WidgetStateProperty.all(BorderSide(color: primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
