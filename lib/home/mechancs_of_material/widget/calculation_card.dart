import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculationCard extends StatelessWidget {
  final List<String> steps;

  const CalculationCard({Key? key, required this.steps}) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    final text = steps.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Calculation copied'),
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
              'CALCULATION',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          InkWell(
            onTap: () => _copyToClipboard(context),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...steps.asMap().entries.map((e) {
                    final isFirst = e.key == 0;
                    return Padding(
                      padding: EdgeInsets.only(
                          top: isFirst ? 0 : 4,
                          left: isFirst ? 0 : 12),
                      child: Text(
                        e.value,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontFamily: 'monospace',
                              fontFeatures: const [FontFeature.tabularFigures()],
                              color: isFirst
                                  ? Theme.of(context).textTheme.bodyMedium?.color
                                  : primary,
                              fontWeight: isFirst
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to copy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
