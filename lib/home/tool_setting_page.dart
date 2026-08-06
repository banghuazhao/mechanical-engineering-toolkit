import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown in-app as well as on both store listings, so the two never drift.
const privacyPolicyUrl = 'https://apps-bay.github.io/Apps-Bay-Website/privacy/';

String _fmtPreview(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String _unitSystemPreview(UnitSystem system) {
  final length = fromSI(125, UnitCategory.length, system);
  final force = fromSI(42, UnitCategory.force, system);
  final stress = fromSI(15, UnitCategory.stress, system);
  return '${_fmtPreview(length)} ${unitLabel(UnitCategory.length, system)} · '
      '${_fmtPreview(force)} ${unitLabel(UnitCategory.force, system)} · '
      '${_fmtPreview(stress)} ${unitLabel(UnitCategory.stress, system)}';
}

class ToolSettingPage extends StatelessWidget {
  const ToolSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Settings),
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: Consumer2<NumberPrecisionHelper, UnitSystemPreference>(
          builder: (context, precs, unitPref, child) => SafeArea(
                child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        children: [
                          // --- Unit System ---
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 14, 16, 0),
                                  child: Text(
                                    S.of(context).Unit_System,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: primary,
                                          letterSpacing: 0.8,
                                        ),
                                  ),
                                ),
                                const Divider(height: 14),
                                ...UnitSystem.values
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final system = entry.value;
                                  final isLast =
                                      entry.key == UnitSystem.values.length - 1;
                                  final isSelected = unitPref.system == system;
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () => unitPref.set(system),
                                        borderRadius: isLast
                                            ? const BorderRadius.vertical(
                                                bottom: Radius.circular(14))
                                            : BorderRadius.zero,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      system == UnitSystem.si
                                                          ? S
                                                              .of(context)
                                                              .Metric_SI
                                                          : S
                                                              .of(context)
                                                              .Imperial_US,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            color: isSelected
                                                                ? primary
                                                                : null,
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w600
                                                                    : null,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _unitSystemPreview(
                                                          system),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                            fontFamily:
                                                                'monospace',
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(Icons.check_circle_rounded,
                                                    color: primary, size: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        const Divider(
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // --- Precision ---
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 14, 16, 0),
                                  child: Text(
                                    S.of(context).Precision,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: primary,
                                          letterSpacing: 0.8,
                                        ),
                                  ),
                                ),
                                const Divider(height: 14),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 12, 18),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).Result_Precision,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            S.of(context).Preview_Value(
                                                precs.formatValue(123456.789)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          _stepButton(
                                            context,
                                            icon: Icons.remove,
                                            onTap: precs.precision > 1
                                                ? () => precs
                                                    .set(precs.precision - 1)
                                                : null,
                                          ),
                                          SizedBox(
                                            width: 36,
                                            child: Text(
                                              precs.precision.toString(),
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          _stepButton(
                                            context,
                                            icon: Icons.add,
                                            onTap: precs.precision < 9
                                                ? () => precs
                                                    .set(precs.precision + 1)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // --- Display Format ---
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 14, 16, 0),
                                  child: Text(
                                    S.of(context).Display_Format,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: primary,
                                          letterSpacing: 0.8,
                                        ),
                                  ),
                                ),
                                const Divider(height: 14),
                                ...NumberDisplayFormat.values
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final fmt = entry.value;
                                  final isLast = entry.key ==
                                      NumberDisplayFormat.values.length - 1;
                                  final isSelected = precs.displayFormat == fmt;
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () => precs.setFormat(fmt),
                                        borderRadius: isLast
                                            ? const BorderRadius.vertical(
                                                bottom: Radius.circular(14))
                                            : BorderRadius.zero,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      fmt.label(context),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            color: isSelected
                                                                ? primary
                                                                : null,
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .w600
                                                                    : null,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      fmt.example(
                                                          precs.precision),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                            fontFamily:
                                                                'monospace',
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(Icons.check_circle_rounded,
                                                    color: primary, size: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        const Divider(
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppSectionCard(
                            title: S.of(context).Privacy,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  leading: const Icon(Icons.policy_rounded),
                                  title: Text(S.of(context).Privacy_Policy),
                                  trailing:
                                      const Icon(Icons.open_in_new_rounded),
                                  onTap: () => launchUrl(
                                    Uri.parse(privacyPolicyUrl),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                ),
                                // Only meaningful where a consent choice was
                                // actually collected (EEA/UK and similar).
                                FutureBuilder<bool>(
                                  future: AdsManager.isPrivacyOptionsRequired(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data != true) {
                                      return const SizedBox.shrink();
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Divider(
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16),
                                        ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 4),
                                          leading: const Icon(
                                              Icons.privacy_tip_rounded),
                                          title: Text(
                                              S.of(context).Privacy_Choices),
                                          subtitle: Text(
                                            S
                                                .of(context)
                                                .Privacy_Choices_Description,
                                          ),
                                          trailing: const Icon(
                                              Icons.chevron_right_rounded),
                                          onTap: () async {
                                            final error = await AdsManager
                                                .showPrivacyOptions();
                                            if (!context.mounted ||
                                                error == null) {
                                              return;
                                            }
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  S
                                                      .of(context)
                                                      .Privacy_Choices_Unavailable,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
              )),
    );
  }

  Widget _stepButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onTap != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}
