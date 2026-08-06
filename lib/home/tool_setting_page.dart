import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/theme_preference.dart';
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

/// One row of a [_SelectionCard]: a title, a monospaced example or hint
/// underneath, and a check mark when it is the active choice.
class _Choice {
  const _Choice({
    required this.label,
    required this.detail,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool isSelected;
  final VoidCallback onTap;
}

/// A titled card of mutually exclusive choices — the shape every picker in
/// Settings uses (unit system, display format, appearance).
class _SelectionCard extends StatelessWidget {
  const _SelectionCard({required this.title, required this.choices});

  final String title;
  final List<_Choice> choices;

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
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          ...choices.asMap().entries.map((entry) {
            final choice = entry.value;
            final isLast = entry.key == choices.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: choice.onTap,
                  borderRadius: isLast
                      ? const BorderRadius.vertical(bottom: Radius.circular(14))
                      : BorderRadius.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                choice.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color:
                                          choice.isSelected ? primary : null,
                                      fontWeight: choice.isSelected
                                          ? FontWeight.w600
                                          : null,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                choice.detail,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontFamily: 'monospace',
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (choice.isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: primary, size: 20),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

String _themeLabel(BuildContext context, AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return S.of(context).Theme_System;
    case AppThemeMode.light:
      return S.of(context).Theme_Light;
    case AppThemeMode.dark:
      return S.of(context).Theme_Dark;
  }
}

String _themeDescription(BuildContext context, AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return S.of(context).Theme_System_Description;
    case AppThemeMode.light:
      return S.of(context).Theme_Light_Description;
    case AppThemeMode.dark:
      return S.of(context).Theme_Dark_Description;
  }
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
      body: Consumer3<NumberPrecisionHelper, UnitSystemPreference,
              ThemePreference>(
          builder: (context, precs, unitPref, themePref, child) => SafeArea(
                child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        children: [
                          // --- Appearance ---
                          _SelectionCard(
                            title: S.of(context).Appearance,
                            choices: [
                              for (final mode in AppThemeMode.values)
                                _Choice(
                                  label: _themeLabel(context, mode),
                                  detail: _themeDescription(context, mode),
                                  isSelected: themePref.appThemeMode == mode,
                                  onTap: () => themePref.set(mode),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // --- Unit System ---
                          _SelectionCard(
                            title: S.of(context).Unit_System,
                            choices: [
                              for (final system in UnitSystem.values)
                                _Choice(
                                  label: system == UnitSystem.si
                                      ? S.of(context).Metric_SI
                                      : S.of(context).Imperial_US,
                                  detail: _unitSystemPreview(system),
                                  isSelected: unitPref.system == system,
                                  onTap: () => unitPref.set(system),
                                ),
                            ],
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
                          _SelectionCard(
                            title: S.of(context).Display_Format,
                            choices: [
                              for (final fmt in NumberDisplayFormat.values)
                                _Choice(
                                  label: fmt.label(context),
                                  detail: fmt.example(precs.precision),
                                  isSelected: precs.displayFormat == fmt,
                                  onTap: () => precs.setFormat(fmt),
                                ),
                            ],
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
