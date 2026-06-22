import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class MultipleRowResult extends StatelessWidget {
  final String title;
  final List<String> resultTitles;
  final List<double?> resultValues;

  const MultipleRowResult({
    Key? key,
    required this.title,
    required this.resultTitles,
    required this.resultValues,
  }) : super(key: key);

  String getValue(double? value, int precision) {
    if (value == null) return '';
    return value == 0 ? '0' : value.toStringAsExponential(precision);
  }

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
              title.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffA8866B),
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          Consumer<NumberPrecisionHelper>(
            builder: (context, precs, child) {
              return Column(
                children: List.generate(resultTitles.length, (index) {
                  final valueStr = getValue(resultValues[index], precs.precision);
                  final isLast = index == resultTitles.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: valueStr.isNotEmpty
                            ? () => _copyToClipboard(context, valueStr)
                            : null,
                        borderRadius: isLast
                            ? const BorderRadius.vertical(bottom: Radius.circular(14))
                            : BorderRadius.zero,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                resultTitles[index],
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
                      ),
                      if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
