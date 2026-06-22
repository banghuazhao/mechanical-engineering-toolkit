import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class SingleRowResult extends StatelessWidget {
  final String title;
  final String resultTitle;
  final double? resultValue;

  const SingleRowResult({
    Key? key,
    required this.title,
    required this.resultTitle,
    required this.resultValue,
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
              final valueStr = precs.formatValue(resultValue);
              return InkWell(
                onTap: valueStr.isNotEmpty
                    ? () => _copyToClipboard(context, valueStr)
                    : null,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        resultTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF6E6E73),
                            ),
                      ),
                      Row(
                        children: [
                          Text(
                            valueStr.isNotEmpty ? valueStr : '—',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                          ),
                          if (valueStr.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.copy_rounded, size: 14, color: Colors.grey[400]),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
