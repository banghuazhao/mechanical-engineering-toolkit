import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/purchase_feedback.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:provider/provider.dart';

/// Offers the upgrade, explaining what prompted it.
///
/// [reason] is the one line that says why the sheet appeared — "Bearing L10
/// Life is a Premium tool", "PDF, CSV and image export are part of Premium".
/// Without it the user is asked to pay with no idea what they just tried to
/// do, which is the difference between an explanation and an interruption.
///
/// Returns once the sheet closes. The caller does not need to act on the
/// result: whatever was locked reads the entitlement from [PremiumGate] and
/// unlocks itself on the rebuild that follows a purchase.
Future<void> showPremiumUpsell(
  BuildContext context, {
  required String reason,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => _PremiumUpsellSheet(reason: reason),
  );
}

/// The upsell for a tool the free tier does not include.
Future<void> showLockedToolUpsell(BuildContext context, Tool tool) {
  return showPremiumUpsell(
    context,
    reason: S.of(context).Premium_Locked_Tool(tool.title),
  );
}

/// The upsell for one of the gated capabilities.
Future<void> showLockedFeatureUpsell(
  BuildContext context,
  PremiumFeature feature,
) {
  final strings = S.of(context);
  final reason = switch (feature) {
    PremiumFeature.pdfExport ||
    PremiumFeature.csvExport ||
    PremiumFeature.imageExport =>
      strings.Premium_Locked_Export,
    PremiumFeature.savedProjects => strings.Premium_Locked_Projects,
    PremiumFeature.fullHistory => strings.Premium_Locked_History,
    PremiumFeature.parameterSweep => strings.Premium_Locked_Sweep,
  };
  return showPremiumUpsell(context, reason: reason);
}

class _PremiumUpsellSheet extends StatelessWidget {
  const _PremiumUpsellSheet({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return SafeArea(
      child: ConstrainedBox(
        // The sheet is content, not a full screen: on a wide Mac window an
        // unbounded one would stretch the benefit list across the whole
        // display and become hard to read.
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            tokens.space5,
            0,
            tokens.space5,
            tokens.space5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 44,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: tokens.space3),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: tokens.space4),
              const PremiumOffer(),
              SizedBox(height: tokens.space2),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(strings.Maybe_Later),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the unlock includes, plus the buy and restore controls.
///
/// Shared by the upsell sheet and the Premium screen reached from the menu, so
/// the two cannot drift into describing different products.
class PremiumOffer extends StatefulWidget {
  const PremiumOffer({super.key});

  @override
  State<PremiumOffer> createState() => _PremiumOfferState();
}

class _PremiumOfferState extends State<PremiumOffer> {
  /// Tracked by revision rather than by status value: two restores that both
  /// come up empty end on the same status, and the user needs to hear about
  /// the second one too.
  int _lastNotifiedRevision = 0;

  @override
  void initState() {
    super.initState();
    final service = context.read<RemoveAdsService>();
    // Whatever the launch-time refresh settled on is history, not news.
    _lastNotifiedRevision = service.statusRevision;

    // A launch with no network leaves the product unloaded, and nothing else
    // ever retries — the offer would read "unavailable" for the rest of the
    // session. Retry on open, after the first frame, so the resulting status
    // change does not rebuild the tree mid-build.
    if (service.product == null && !service.isBusy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) service.loadProducts();
      });
    }
  }

  void _notify(RemoveAdsService service) {
    if (_lastNotifiedRevision == service.statusRevision) return;
    _lastNotifiedRevision = service.statusRevision;
    final message = purchaseStatusMessage(
      S.of(context),
      service.status,
      premiumWording: true,
    );
    if (message == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final tokens = context.tokens;
    final total = ToolLibrary.shared.getTools(context).length;

    return Consumer<RemoveAdsService>(
      builder: (context, service, _) {
        _notify(service);

        if (service.isEntitled) {
          return _PremiumUnlocked(service: service);
        }

        final price = service.localizedPrice;
        final isPending = service.hasPendingPurchase;
        // A pending order blocks a second purchase — the store would reject
        // it — but leaves restore available.
        final canBuy = price != null && !service.isBusy && !isPending;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Benefit(strings.Premium_Benefit_Tools(total)),
            _Benefit(strings.Premium_Benefit_Export),
            _Benefit(strings.Premium_Benefit_Projects),
            _Benefit(strings.Premium_Benefit_History),
            _Benefit(strings.Premium_Benefit_Sweep),
            _Benefit(strings.Premium_Benefit_Universal),
            SizedBox(height: tokens.space4),
            FilledButton.icon(
              onPressed: canBuy ? service.buyRemoveAds : null,
              icon: service.isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isPending
                      ? Icons.hourglass_top_rounded
                      : Icons.workspace_premium_rounded),
              label: Text(service.status == RemoveAdsStatus.purchasing
                  ? strings.Purchasing
                  : isPending
                      ? strings.Purchase_Pending
                      : price == null
                          ? strings.Purchase_Unavailable
                          : '${strings.Unlock_Premium} — $price'),
            ),
            Padding(
              padding: EdgeInsets.only(top: tokens.space2),
              child: Text(
                strings.Premium_Description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: service.isBusy ? null : service.restorePurchases,
              icon: const Icon(Icons.restore_rounded),
              label: Text(service.status == RemoveAdsStatus.restoring
                  ? strings.Restoring
                  : strings.Restore_Purchases),
            ),
          ],
        );
      },
    );
  }
}

class _PremiumUnlocked extends StatelessWidget {
  const _PremiumUnlocked({required this.service});

  final RemoveAdsService service;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.verified_rounded, color: scheme.secondary),
          title: Text(strings.Premium_Unlocked),
          subtitle: Text(strings.Premium_Unlocked_Description),
        ),
        TextButton.icon(
          onPressed: service.isBusy ? null : service.restorePurchases,
          icon: const Icon(Icons.restore_rounded),
          label: Text(service.status == RemoveAdsStatus.restoring
              ? strings.Restoring
              : strings.Restore_Purchases),
        ),
      ],
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.tokens.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: context.tokens.space3),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// The small "Premium" chip that marks a locked tool in the library.
class PremiumLockBadge extends StatelessWidget {
  const PremiumLockBadge({super.key, this.compact = false});

  /// Drops the label and shows only the padlock, for the grid tiles where
  /// there is no room for a word.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = S.of(context);
    final icon = Icon(
      Icons.lock_rounded,
      size: compact ? 11 : 13,
      color: scheme.onSecondaryContainer,
    );
    return Semantics(
      label: strings.Premium_Badge,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 7,
          vertical: compact ? 3 : 3,
        ),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: compact
            ? icon
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 4),
                  Text(
                    strings.Premium_Badge,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// An app-bar icon with a small padlock in its corner, marking an action that
/// will offer the upgrade rather than run.
///
/// A locked action stays visible and stays tappable — hiding it would leave
/// the user unaware the app can do the thing at all — so it needs a cue that
/// reads before the tap rather than after it.
class PremiumLockedIcon extends StatelessWidget {
  const PremiumLockedIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -3,
          bottom: -3,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              size: 10,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

/// A whole screen's worth of "this is Premium", with the offer inline.
///
/// For features that have no useful free form to show — saved projects being
/// the case in point, where a free build has nothing to list. Where a partial
/// view does exist (history, the tool library) show that instead and mark
/// what is missing; an empty screen behind a paywall teaches the user nothing
/// about what they would be buying.
class PremiumLockedView extends StatelessWidget {
  const PremiumLockedView({
    super.key,
    required this.icon,
    required this.reason,
  });

  final IconData icon;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: 56, color: theme.colorScheme.primary),
              SizedBox(height: tokens.space4),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: tokens.space5),
              const PremiumOffer(),
            ],
          ),
        ),
      ),
    );
  }
}
