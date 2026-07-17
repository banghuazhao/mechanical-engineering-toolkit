import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class EngineeringConstantsWidget extends StatelessWidget {
  final String title;
  final Map<String, double> constants;

  /// Optional lookup returning the [UnitCategory] for a given entry key.
  /// When it returns non-null for a key, that entry's value is
  /// converted/labelled reactively via the app's [UnitSystemPreference].
  /// Defaults to null for every key, preserving the previous
  /// (unconverted) behavior for call sites that don't pass this.
  final UnitCategory? Function(String key)? categoryForKey;

  const EngineeringConstantsWidget({
    Key? key,
    required this.title,
    required this.constants,
    this.categoryForKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final entries = constants.entries.toList();
    final system = context.watch<UnitSystemPreference>().system;
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
                    color: primary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          Consumer<NumberPrecisionHelper>(
            builder: (context, precs, _) => Column(
              children: entries.asMap().entries.map((e) {
                final isLast = e.key == entries.length - 1;
                final key = e.value.key;
                final category = categoryForKey?.call(key);
                final val = category == null
                    ? e.value.value
                    : fromSI(e.value.value, category, system);
                final displayKey = category == null
                    ? key
                    : '$key (${unitLabel(category, system)})';
                final valStr = precs.formatValue(val);
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: valStr));
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Copied: $valStr'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          width: 220,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                      },
                      borderRadius: isLast
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(14))
                          : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(displayKey,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: const Color(0xFF6E6E73))),
                            Row(
                              children: [
                                Text(
                                  valStr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.copy_rounded,
                                    size: 12, color: Colors.grey[400]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
