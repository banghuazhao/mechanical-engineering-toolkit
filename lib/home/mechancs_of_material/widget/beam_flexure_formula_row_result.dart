import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamFlexureFormulaRowResult extends StatelessWidget {
  final String resultFormula;
  final double? resultValue;
  final UnitCategory? category;

  const BeamFlexureFormulaRowResult({
    Key? key,
    required this.resultFormula,
    required this.resultValue,
    this.category,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $value'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 220,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
              S.of(context).Stress.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffA8866B),
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'σx Formula',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF6E6E73),
                      ),
                ),
                Expanded(
                  child: Text(
                    resultFormula,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (resultValue != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Consumer2<NumberPrecisionHelper, UnitSystemPreference>(
              builder: (context, precs, unitPref, child) {
                final display = category == null
                    ? resultValue
                    : fromSI(resultValue!, category!, unitPref.system);
                final unit =
                    category == null ? '' : unitLabel(category!, unitPref.system);
                final numStr = precs.formatValue(display);
                final valueStr =
                    numStr.isEmpty || unit.isEmpty ? numStr : '$numStr $unit';
                return InkWell(
                  onTap: valueStr.isNotEmpty
                      ? () => _copyToClipboard(context, valueStr)
                      : null,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'σx Value',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF6E6E73),
                              ),
                        ),
                        Row(
                          children: [
                            Text(
                              valueStr.isNotEmpty ? valueStr : '—',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                            ),
                            if (valueStr.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.copy_rounded, size: 12, color: Colors.grey[400]),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
