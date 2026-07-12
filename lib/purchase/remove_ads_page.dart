import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:provider/provider.dart';

class RemoveAdsPage extends StatefulWidget {
  const RemoveAdsPage({super.key});

  @override
  State<RemoveAdsPage> createState() => _RemoveAdsPageState();
}

class _RemoveAdsPageState extends State<RemoveAdsPage> {
  RemoveAdsStatus? _lastNotifiedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).Remove_Ads)),
      body: SafeArea(
        child: Consumer<RemoveAdsService>(
          builder: (context, service, _) {
            _notifyPurchaseStatus(service.status);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [RemoveAdsSection(service: service)],
            );
          },
        ),
      ),
    );
  }

  void _notifyPurchaseStatus(RemoveAdsStatus status) {
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
}

class RemoveAdsSection extends StatelessWidget {
  const RemoveAdsSection({super.key, required this.service});

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
              leading: Icon(Icons.verified_rounded, color: scheme.secondary),
              title: Text(strings.Ads_Removed),
              subtitle: Text(strings.Ads_Removed_Description),
            ),
            TextButton.icon(
              onPressed: service.isBusy ? null : service.restorePurchases,
              icon: const Icon(Icons.restore_rounded),
              label: Text(service.status == RemoveAdsStatus.restoring
                  ? strings.Restoring
                  : strings.Restore_Purchases),
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
            label: Text(service.status == RemoveAdsStatus.purchasing
                ? strings.Purchasing
                : service.status == RemoveAdsStatus.pending
                    ? strings.Purchase_Pending
                    : price == null
                        ? strings.Purchase_Unavailable
                        : '${strings.Remove_Ads} — $price'),
          ),
          TextButton.icon(
            onPressed: service.isBusy ? null : service.restorePurchases,
            icon: const Icon(Icons.restore_rounded),
            label: Text(service.status == RemoveAdsStatus.restoring
                ? strings.Restoring
                : strings.Restore_Purchases),
          ),
        ],
      ),
    );
  }
}
