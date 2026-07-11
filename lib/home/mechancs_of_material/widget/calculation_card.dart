import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';

class CalculationCard extends StatelessWidget {
  final List<String> steps;

  const CalculationCard({super.key, required this.steps});

  void _copyToClipboard(BuildContext context) {
    final text = steps.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSectionCard(
      title: 'Calculation',
      contentPadding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _copyToClipboard(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...steps.asMap().entries.map((e) {
                final isFirst = e.key == 0;
                return Padding(
                  padding: EdgeInsets.only(
                      top: isFirst ? 0 : 4, left: isFirst ? 0 : 12),
                  child: Text(
                    e.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isFirst
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary,
                          fontWeight:
                              isFirst ? FontWeight.normal : FontWeight.w500,
                        ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Row(
                spacing: 6,
                children: [
                  Icon(Icons.content_copy_rounded,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  Text(
                    'Tap to copy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
