import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/purchase/tool_unlock_service.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
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
  Tool? rewardedTool,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: rewardedTool == null,
    isDismissible: rewardedTool == null,
    enableDrag: rewardedTool == null,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _PremiumUpsellSheet(reason: reason, rewardedTool: rewardedTool),
  );
}

/// The upsell for a tool the free tier does not include.
Future<void> showLockedToolUpsell(BuildContext context, Tool tool) {
  return showPremiumUpsell(
    context,
    reason: S.of(context).Premium_Locked_Tool(tool.title),
    rewardedTool: AppPlatform.current.supportsRewardedToolUnlocks ? tool : null,
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
    PremiumFeature.fullHistory =>
      strings.Premium_Locked_History(ToolHistory.maxEntries),
    PremiumFeature.parameterSweep => strings.Premium_Locked_Sweep,
  };
  return showPremiumUpsell(context, reason: reason);
}

class _PremiumUpsellSheet extends StatelessWidget {
  const _PremiumUpsellSheet({required this.reason, this.rewardedTool});

  final String reason;
  final Tool? rewardedTool;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;

    final busy = context.watch<ToolUnlockService?>()?.isBusy ?? false;
    final entitled = context.watch<RemoveAdsService>().isEntitled;
    return PopScope(
      canPop: !busy,
      child: SafeArea(
        child: ConstrainedBox(
          // The sheet is content, not a full screen: on a wide Mac window an
          // unbounded one would stretch the benefit list across the whole
          // display and become hard to read.
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              tokens.space5,
              rewardedTool == null ? 0 : tokens.space5,
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
                if (rewardedTool != null && !entitled) ...[
                  RewardedToolUnlockButton(toolId: rewardedTool!.id),
                  SizedBox(height: tokens.space4),
                  const Divider(),
                  SizedBox(height: tokens.space3),
                ],
                PremiumOffer(enabled: !busy),
                SizedBox(height: tokens.space2),
                TextButton(
                  onPressed:
                      busy ? null : () => Navigator.of(context).maybePop(),
                  child: Text(strings.Maybe_Later),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The reward is saved by the service before this sheet opens the selected tool.
class RewardedToolUnlockButton extends StatefulWidget {
  const RewardedToolUnlockButton({super.key, required this.toolId});
  final int toolId;

  @override
  State<RewardedToolUnlockButton> createState() =>
      _RewardedToolUnlockButtonState();
}

class _RewardedToolUnlockButtonState extends State<RewardedToolUnlockButton> {
  ToolUnlockResult? _result;

  Future<void> _watch(ToolUnlockService service) async {
    setState(() => _result = null);
    final result = await service.unlockWithAd(widget.toolId);
    if (!mounted) return;
    if (result == ToolUnlockResult.unlocked) {
      // Wait for PopScope to rebuild after the service clears its busy state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      setState(() => _result = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final service = context.watch<ToolUnlockService?>();
    final busy = service?.isBusy ?? false;
    final purchasing = context.watch<RemoveAdsService>().isBusy;
    final message = switch (_result) {
      ToolUnlockResult.skipped => strings.Rewarded_Tool_Skipped,
      ToolUnlockResult.saveFailed => strings.Rewarded_Tool_Save_Failed,
      ToolUnlockResult.unavailable => strings.Rewarded_Tool_Unavailable,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.Rewarded_Tool_Description, textAlign: TextAlign.center),
        SizedBox(height: context.tokens.space3),
        OutlinedButton.icon(
          onPressed: service == null || busy || purchasing
              ? null
              : () => _watch(service),
          icon: busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.ondemand_video_rounded),
          label: Text(busy
              ? strings.Rewarded_Tool_Loading
              : strings.Rewarded_Tool_Watch),
        ),
        if (message != null) ...[
          SizedBox(height: context.tokens.space2),
          Semantics(
              liveRegion: true,
              child: Text(message, textAlign: TextAlign.center)),
        ],
      ],
    );
  }
}

/// What the unlock includes, plus the buy and restore controls.
///
/// Shared by the upsell sheet and the Premium screen reached from the menu, so
/// the two cannot drift into describing different products.
class PremiumOffer extends StatefulWidget {
  const PremiumOffer({super.key, this.enabled = true});

  final bool enabled;

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
      store: service.store,
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
        // Play purchases restore on Android only; the Universal Purchase that
        // spans iPhone, iPad and Mac is an App Store arrangement.
        final onPlay = service.store == AppStore.playStore;
        // A pending order blocks a second purchase — the store would reject
        // it — but leaves restore available.
        final canBuy =
            widget.enabled && price != null && !service.isBusy && !isPending;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Benefit(strings.Premium_Benefit_Tools(total)),
            _Benefit(strings.Premium_Benefit_No_Ads),
            if (AppPlatform.current.gatesFeatures) ...[
              _Benefit(strings.Premium_Benefit_Export),
              _Benefit(strings.Premium_Benefit_Projects),
              _Benefit(strings.Premium_Benefit_History(ToolHistory.maxEntries)),
              _Benefit(strings.Premium_Benefit_Sweep),
            ],
            if (!onPlay) _Benefit(strings.Premium_Benefit_Universal),
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
                onPlay
                    ? strings.Premium_Description_Play
                    : strings.Premium_Description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: !widget.enabled || service.isBusy
                  ? null
                  : service.restorePurchases,
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
          subtitle: Text(service.store == AppStore.playStore
              ? strings.Premium_Unlocked_Description_Play
              : strings.Premium_Unlocked_Description),
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
