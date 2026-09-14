import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';

/// Statuses that are a step on the way somewhere rather than an outcome, and
/// so are never announced.
const Set<RemoveAdsStatus> kTransientPurchaseStatuses = {
  RemoveAdsStatus.idle,
  RemoveAdsStatus.loading,
  RemoveAdsStatus.ready,
  RemoveAdsStatus.purchasing,
  RemoveAdsStatus.restoring,
};

/// What to tell the user about [status], or null when it is not worth saying.
///
/// iOS and macOS use Premium wording for the existing purchase; Android keeps
/// its Remove Ads wording. Use `PremiumGate.usesPremiumWording` to choose.
String? purchaseStatusMessage(
  S strings,
  RemoveAdsStatus status, {
  required bool premiumWording,
}) {
  if (kTransientPurchaseStatuses.contains(status)) return null;
  return switch (status) {
    RemoveAdsStatus.unavailable => strings.Purchase_Unavailable,
    RemoveAdsStatus.notFound =>
      premiumWording ? strings.Premium_Not_Found : strings.Product_Not_Found,
    RemoveAdsStatus.failed => strings.Purchase_Failed,
    RemoveAdsStatus.cancelled => strings.Purchase_Cancelled,
    RemoveAdsStatus.pending => strings.Purchase_Pending,
    RemoveAdsStatus.purchased => premiumWording
        ? strings.Premium_Purchase_Success
        : strings.Purchase_Success,
    RemoveAdsStatus.restored => premiumWording
        ? strings.Premium_Restore_Success
        : strings.Restore_Success,
    RemoveAdsStatus.restoreNotFound => premiumWording
        ? strings.Premium_Restore_Not_Found
        : strings.Restore_Not_Found,
    _ => null,
  };
}
