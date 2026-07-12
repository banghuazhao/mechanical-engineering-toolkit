import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class ToolSettingPage extends StatefulWidget {
  const ToolSettingPage({super.key});

  @override
  State<ToolSettingPage> createState() => _ToolSettingPageState();
}

class _ToolSettingPageState extends State<ToolSettingPage> {
  RemoveAdsStatus? _lastNotifiedStatus;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Settings),
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: Consumer<NumberPrecisionHelper>(
          builder: (context, precs, child) => SafeArea(
                child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        children: [
                          // --- Precision ---
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 14, 16, 0),
                                  child: Text(
                                    'PRECISION',
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
                                      const EdgeInsets.fromLTRB(16, 4, 12, 14),
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
                                            'Preview: ${precs.formatValue(123456.789)}',
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
                                    'DISPLAY FORMAT',
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
                                              horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      fmt.label,
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
                          Consumer<RemoveAdsService>(
                            builder: (context, purchases, _) {
                              if (!purchases.isSupported) {
                                return const SizedBox.shrink();
                              }
                              _notifyPurchaseStatus(context, purchases.status);
                              return RemoveAdsSettingsSection(
                                  service: purchases);
                            },
                          ),
                          if (context.read<RemoveAdsService>().isSupported)
                            const SizedBox(height: 12),
                          FutureBuilder<bool>(
                            future: AdsManager.isPrivacyOptionsRequired(),
                            builder: (context, snapshot) {
                              if (snapshot.data != true) {
                                return const SizedBox.shrink();
                              }
                              return AppSectionCard(
                                title: 'Privacy',
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading:
                                      const Icon(Icons.privacy_tip_rounded),
                                  title: const Text('Privacy choices'),
                                  subtitle: const Text(
                                    'Review or change your advertising consent.',
                                  ),
                                  trailing:
                                      const Icon(Icons.chevron_right_rounded),
                                  onTap: () async {
                                    final error =
                                        await AdsManager.showPrivacyOptions();
                                    if (!context.mounted || error == null) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Privacy choices are unavailable. Try again later.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ]),
              )),
    );
  }

  void _notifyPurchaseStatus(
    BuildContext context,
    RemoveAdsStatus status,
  ) {
    if (_lastNotifiedStatus == status ||
        const {
          RemoveAdsStatus.idle,
          RemoveAdsStatus.loading,
          RemoveAdsStatus.ready,
          RemoveAdsStatus.purchasing,
          RemoveAdsStatus.restoring,
        }.contains(status)) {
      return;
    }
    _lastNotifiedStatus = status;
    final strings = S.of(context);
    final message = switch (status) {
      RemoveAdsStatus.unavailable => strings.Purchase_Unavailable,
      RemoveAdsStatus.notFound => strings.Product_Not_Found,
      RemoveAdsStatus.failed => strings.Purchase_Failed,
      RemoveAdsStatus.cancelled => strings.Purchase_Cancelled,
      RemoveAdsStatus.pending => strings.Purchase_Pending,
      RemoveAdsStatus.purchased => strings.Purchase_Success,
      RemoveAdsStatus.restored => strings.Restore_Success,
      RemoveAdsStatus.restoreNotFound => strings.Restore_Not_Found,
      _ => null,
    };
    if (message == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Widget _stepButton({required IconData icon, VoidCallback? onTap}) {
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

class RemoveAdsSettingsSection extends StatelessWidget {
  const RemoveAdsSettingsSection({super.key, required this.service});

  final RemoveAdsService service;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (service.isAdsRemoved) {
      return AppSectionCard(
        title: strings.Remove_Ads,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.verified_rounded,
                color: scheme.secondary,
              ),
              title: Text(strings.Ads_Removed),
              subtitle: Text(strings.Ads_Removed_Description),
            ),
            TextButton.icon(
              onPressed: service.isBusy ? null : service.restorePurchases,
              icon: const Icon(Icons.restore_rounded),
              label: Text(
                service.status == RemoveAdsStatus.restoring
                    ? strings.Restoring
                    : strings.Restore_Purchases,
              ),
            ),
          ],
        ),
      );
    }

    final price = service.localizedPrice;
    final canBuy = price != null && !service.isBusy;
    return AppSectionCard(
      title: strings.Remove_Ads,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.block_rounded),
            title: Text(strings.Remove_Ads),
            subtitle: Text(strings.Remove_Ads_Description),
          ),
          FilledButton.icon(
            onPressed: canBuy ? service.buyRemoveAds : null,
            icon: service.isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.shopping_bag_rounded),
            label: Text(
              service.status == RemoveAdsStatus.purchasing
                  ? strings.Purchasing
                  : service.status == RemoveAdsStatus.pending
                      ? strings.Purchase_Pending
                      : price == null
                          ? strings.Purchase_Unavailable
                          : '${strings.Remove_Ads} — $price',
            ),
          ),
          TextButton.icon(
            onPressed: service.isBusy ? null : service.restorePurchases,
            icon: const Icon(Icons.restore_rounded),
            label: Text(
              service.status == RemoveAdsStatus.restoring
                  ? strings.Restoring
                  : strings.Restore_Purchases,
            ),
          ),
        ],
      ),
    );
  }
}
