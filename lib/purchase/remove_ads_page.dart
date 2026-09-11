import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';
import 'package:mechanical_engineering_toolkit/purchase/purchase_feedback.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:provider/provider.dart';

/// The purchase screen, reached from the menu.
///
/// One product with two faces. Where nothing is gated — iOS and Android — it
/// is the Remove Ads screen it has always been. Where features are gated it
/// becomes the Premium screen instead, listing what the unlock includes; the
/// transaction underneath is identical, so a customer who bought on either
/// platform already owns the other.
class RemoveAdsPage extends StatefulWidget {
  const RemoveAdsPage({super.key});

  @override
  State<RemoveAdsPage> createState() => _RemoveAdsPageState();
}

class _RemoveAdsPageState extends State<RemoveAdsPage> {
  /// Tracked by revision rather than by status value: two restores that both
  /// come up empty end on the same status, and the user needs to hear about
  /// the second one too.
  int _lastNotifiedRevision = 0;

  @override
  void initState() {
    super.initState();
    final service = context.read<RemoveAdsService>();
    // Whatever the launch-time refresh settled on is history, not news: the
    // page opening should not announce it.
    _lastNotifiedRevision = service.statusRevision;

    // A launch with no network leaves the product unloaded, and nothing else
    // ever retries — the page would read "unavailable" for the rest of the
    // session. Retry on open, after the first frame, so the resulting status
    // change does not rebuild the tree mid-build.
    if (service.product == null && !service.isBusy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) service.loadProducts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final gate = PremiumGate.watch(context);

    if (gate.gatesFeatures) {
      // PremiumOffer runs its own status announcements, so this page must not
      // also announce them — two snackbars for one purchase.
      return Scaffold(
        appBar: AppBar(title: Text(strings.Premium)),
        body: SafeArea(
          child: AppContent(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppSectionCard(
                  title: strings.Unlock_Premium,
                  child: const PremiumOffer(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.Remove_Ads)),
      body: SafeArea(
        child: Consumer<RemoveAdsService>(
          builder: (context, service, _) {
            _notifyPurchaseStatus(service);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [RemoveAdsSection(service: service)],
            );
          },
        ),
      ),
    );
  }

  void _notifyPurchaseStatus(RemoveAdsService service) {
    if (_lastNotifiedRevision == service.statusRevision) return;
    _lastNotifiedRevision = service.statusRevision;

    final message = purchaseStatusMessage(
      S.of(context),
      service.status,
      premiumWording: false,
    );
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
    final isPending = service.hasPendingPurchase;
    // A pending order blocks a second purchase — the store would reject it —
    // but leaves restore available, since a Play order can stay pending for
    // days and the user needs a way to re-check it.
    final canBuy = price != null && !service.isBusy && !isPending;
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
                : Icon(isPending
                    ? Icons.hourglass_top_rounded
                    : Icons.shopping_bag_rounded),
            label: Text(service.status == RemoveAdsStatus.purchasing
                ? strings.Purchasing
                : isPending
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
