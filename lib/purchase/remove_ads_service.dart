import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

/// The storefront this build transacts against.
///
/// Product identifiers are per-store rather than global: App Store Connect
/// takes the reverse-DNS id below, while Google Play only accepts lowercase
/// letters, digits, underscores and periods and so cannot reuse it. The id
/// therefore travels with the store.
///
/// Threading the store through the service — instead of reading [Platform]
/// wherever a decision depends on it — is also what lets tests exercise the
/// Play and App Store paths on a desktop host.
enum AppStore {
  appStore('com.appsbay.mechanicalEngineeringToolkit.remove_ads'),

  /// The Mac App Store, which sells the *same* product as [appStore].
  ///
  /// macOS is a second platform on one App Store Connect record — a Universal
  /// Purchase, keyed off the shared bundle identifier — and in-app purchases
  /// belong to the record rather than to a platform. So there is one product
  /// to configure, one price, and a customer who buys on either side gets the
  /// other for free when StoreKit restores. What the purchase *unlocks*
  /// differs by platform: ads on iOS, the gated tools and exports on macOS
  /// (see `lib/purchase/premium.dart`).
  macAppStore('com.appsbay.mechanicalEngineeringToolkit.remove_ads'),

  playStore('remove_ads'),

  /// Web and test hosts, which have no billing backend at all.
  none('');

  const AppStore(this.removeAdsProductId);

  /// The product identifier to query and buy. Must match the id configured in
  /// App Store Connect / the Play Console for that store.
  final String removeAdsProductId;

  static AppStore get current {
    if (Platform.isIOS) return AppStore.appStore;
    if (Platform.isMacOS) return AppStore.macAppStore;
    if (Platform.isAndroid) return AppStore.playStore;
    return AppStore.none;
  }
}

enum RemoveAdsStatus {
  idle,
  loading,
  ready,
  purchasing,
  pending,
  restoring,
  purchased,
  restored,
  cancelled,
  unavailable,
  notFound,
  failed,
  restoreNotFound,
}

enum StorePurchaseStatus { pending, purchased, restored, cancelled, error }

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.rawProduct,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final Object? rawProduct;
}

class StorePurchaseUpdate {
  const StorePurchaseUpdate({
    required this.productId,
    required this.status,
    this.pendingCompletePurchase = false,
    this.errorMessage,
    this.rawPurchase,
  });

  final String productId;
  final StorePurchaseStatus status;
  final bool pendingCompletePurchase;
  final String? errorMessage;
  final Object? rawPurchase;
}

abstract interface class PurchaseClient {
  Stream<List<StorePurchaseUpdate>> get purchaseStream;
  Future<bool> isAvailable();
  Future<StoreProduct?> loadProduct(String productId);
  Future<bool> buyNonConsumable(StoreProduct product);
  Future<void> restorePurchases();
  Future<void> completePurchase(StorePurchaseUpdate purchase);
}

abstract interface class EntitlementPersistence {
  bool read();
  Future<void> write(bool value);
}

class SharedPreferencesEntitlementPersistence
    implements EntitlementPersistence {
  static const _key = 'REMOVE_ADS_ENTITLEMENT_V1';

  @override
  bool read() => SharedPreferencesHelper.localStorage.getBool(_key) ?? false;

  @override
  Future<void> write(bool value) =>
      SharedPreferencesHelper.localStorage.setBool(_key, value);
}

/// Bridges [InAppPurchase] — StoreKit on iOS, Play Billing on Android — onto
/// the store-neutral surface [RemoveAdsService] consumes.
class PlatformPurchaseClient implements PurchaseClient {
  PlatformPurchaseClient({InAppPurchase? store})
      : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseStream =>
      _store.purchaseStream.map(
        (purchases) => purchases.map(mapPurchase).toList(growable: false),
      );

  @override
  Future<bool> isAvailable() => _store.isAvailable();

  @override
  Future<StoreProduct?> loadProduct(String productId) async {
    final response = await _store.queryProductDetails({productId});
    if (response.error != null || response.productDetails.isEmpty) return null;
    final product = response.productDetails.first;
    return StoreProduct(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      rawProduct: product,
    );
  }

  @override
  Future<bool> buyNonConsumable(StoreProduct product) {
    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: product.rawProduct! as ProductDetails,
      ),
    );
  }

  @override
  Future<void> restorePurchases() => _store.restorePurchases();

  @override
  Future<void> completePurchase(StorePurchaseUpdate purchase) =>
      _store.completePurchase(purchase.rawPurchase! as PurchaseDetails);

  /// Translates one store purchase into [StorePurchaseUpdate]. Static because
  /// it depends only on the purchase — constructing a client would spin up a
  /// real billing connection.
  @visibleForTesting
  static StorePurchaseUpdate mapPurchase(PurchaseDetails purchase) {
    var status = switch (purchase.status) {
      PurchaseStatus.pending => StorePurchaseStatus.pending,
      PurchaseStatus.purchased => StorePurchaseStatus.purchased,
      PurchaseStatus.restored => StorePurchaseStatus.restored,
      PurchaseStatus.canceled => StorePurchaseStatus.cancelled,
      PurchaseStatus.error => StorePurchaseStatus.error,
    };
    var pendingCompletePurchase = purchase.pendingCompletePurchase;

    // Google Play's restore path stamps *every* queried order as `restored`
    // and flags it for acknowledgement, including orders whose payment has not
    // cleared yet (cash, bank transfer, parental approval). Taking that at face
    // value would hand out the entitlement for an unpaid order, and Play
    // forbids acknowledging anything not yet in the purchased state — so
    // re-derive both from the billing state it came with.
    if ((status == StorePurchaseStatus.purchased ||
            status == StorePurchaseStatus.restored) &&
        purchase is GooglePlayPurchaseDetails &&
        purchase.billingClientPurchase.purchaseState !=
            PurchaseStateWrapper.purchased) {
      status = StorePurchaseStatus.pending;
      pendingCompletePurchase = false;
    }

    return StorePurchaseUpdate(
      productId: purchase.productID,
      status: status,
      pendingCompletePurchase: pendingCompletePurchase,
      errorMessage: purchase.error?.message,
      rawPurchase: purchase,
    );
  }
}

class RemoveAdsService extends ChangeNotifier {
  RemoveAdsService({
    PurchaseClient? client,
    EntitlementPersistence? persistence,
    AppStore? store,
    this.restoreTimeout = const Duration(seconds: 3),
  })  : _client = client ?? PlatformPurchaseClient(),
        _persistence = persistence ?? SharedPreferencesEntitlementPersistence(),
        store = store ?? AppStore.current;

  final PurchaseClient _client;
  final EntitlementPersistence _persistence;
  final Duration restoreTimeout;
  final AppStore store;

  /// Whether this build has a store to buy from at all.
  bool get isSupported => store != AppStore.none;

  /// The identifier of the remove-ads product on [store].
  String get productId => store.removeAdsProductId;

  StreamSubscription<List<StorePurchaseUpdate>>? _subscription;
  Timer? _restoreTimer;
  StoreProduct? _product;
  bool _isAdsRemoved = false;
  bool _restoreFoundPurchase = false;
  RemoveAdsStatus _status = RemoveAdsStatus.idle;
  String? _errorMessage;
  int _statusRevision = 0;

  bool get isAdsRemoved => _isAdsRemoved;

  /// The same flag as [isAdsRemoved], under the name the macOS build uses.
  ///
  /// One purchase, two meanings: it suppresses advertising on iOS and Android,
  /// and it unlocks the gated tools and exports on macOS. Reading it through
  /// this name keeps the Mac call sites from looking like they care about ads
  /// in a build that has none. Prefer [PremiumGate] over touching this
  /// directly — it also answers whether the platform gates anything.
  bool get isEntitled => _isAdsRemoved;

  StoreProduct? get product => _product;
  String? get localizedPrice => _product?.price;
  RemoveAdsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// Counts status changes, so a listener can tell "the same outcome, again"
  /// from "the outcome I have already reported".
  ///
  /// Two restores that both find nothing land on the same [status], and a
  /// frame can coalesce the transient state between them out of existence —
  /// so the value alone cannot say whether an outcome is new.
  int get statusRevision => _statusRevision;
  /// Work is in flight right now, so the screen should show a spinner and
  /// refuse a second tap. Deliberately excludes [RemoveAdsStatus.pending],
  /// which is not in-flight work — see [hasPendingPurchase].
  bool get isBusy => const {
        RemoveAdsStatus.loading,
        RemoveAdsStatus.purchasing,
        RemoveAdsStatus.restoring,
      }.contains(_status);

  /// An order exists whose payment has not cleared: an iOS transaction still
  /// being processed, or a Play order awaiting cash, bank transfer or a
  /// parent's approval.
  ///
  /// A Play order can sit here for days, and every launch rediscovers it, so
  /// this must block a *second* purchase without freezing the rest of the
  /// screen the way [isBusy] does — otherwise the buy button spins and the
  /// restore button stays disabled until the payment clears.
  bool get hasPendingPurchase => _status == RemoveAdsStatus.pending;

  /// Reads the entitlement that was persisted at the last successful purchase.
  ///
  /// Synchronous by design: whether to suppress ads has to be settled before
  /// the first frame, and it must not wait on a store that may be slow or
  /// unreachable. [init] performs the same read, so calling both is safe.
  void loadPersistedEntitlement() {
    final persisted = _persistence.read();
    if (persisted == _isAdsRemoved) return;
    _isAdsRemoved = persisted;
    notifyListeners();
  }

  /// Connects to the store, loads the product and re-checks past purchases.
  ///
  /// Every step here is a round trip that can take seconds on a cold billing
  /// connection or hang on a bad network, so this is safe to leave unawaited —
  /// it never throws, and [loadPersistedEntitlement] has already settled what
  /// the UI needs to render.
  Future<void> init() async {
    loadPersistedEntitlement();
    if (!isSupported) return;
    _subscription = _client.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        _setStatus(RemoveAdsStatus.failed, error.toString());
      },
    );
    await loadProducts();
    try {
      if (await _client.isAvailable()) {
        await _restore(refreshOnly: true);
      }
    } catch (error) {
      debugPrint('Remove Ads: could not reach the store on launch: $error');
    }
  }

  Future<void> loadProducts() async {
    if (!isSupported) return;
    _setStatus(RemoveAdsStatus.loading);
    try {
      if (!await _client.isAvailable()) {
        _setStatus(RemoveAdsStatus.unavailable);
        return;
      }
      _product = await _client.loadProduct(productId);
      _setStatus(
        _product == null ? RemoveAdsStatus.notFound : RemoveAdsStatus.ready,
      );
    } catch (error) {
      _setStatus(RemoveAdsStatus.unavailable, error.toString());
    }
  }

  Future<void> buyRemoveAds() async {
    if (!isSupported || _isAdsRemoved) return;
    final product = _product;
    if (product == null) {
      await loadProducts();
      if (_product == null) return;
    }
    _setStatus(RemoveAdsStatus.purchasing);
    try {
      final started = await _client.buyNonConsumable(_product!);
      if (!started) _setStatus(RemoveAdsStatus.failed);
    } catch (error) {
      _setStatus(RemoveAdsStatus.failed, error.toString());
    }
  }

  Future<void> restorePurchases() => _restore(refreshOnly: false);

  Future<void> _restore({required bool refreshOnly}) async {
    if (!isSupported) return;
    _restoreFoundPurchase = false;
    if (!refreshOnly) _setStatus(RemoveAdsStatus.restoring);
    try {
      await _client.restorePurchases();
      _restoreTimer?.cancel();
      _restoreTimer = Timer(restoreTimeout, () {
        if (!_restoreFoundPurchase && !refreshOnly) {
          _setStatus(RemoveAdsStatus.restoreNotFound);
        }
      });
    } catch (error) {
      if (!refreshOnly) {
        _setStatus(RemoveAdsStatus.failed, error.toString());
      }
    }
  }

  Future<void> _handlePurchases(
    List<StorePurchaseUpdate> purchases,
  ) async {
    for (final purchase in purchases) {
      if (purchase.productId == productId) {
        switch (purchase.status) {
          case StorePurchaseStatus.pending:
            _setStatus(RemoveAdsStatus.pending);
          case StorePurchaseStatus.cancelled:
            _setStatus(RemoveAdsStatus.cancelled);
          case StorePurchaseStatus.error:
            _setStatus(RemoveAdsStatus.failed, purchase.errorMessage);
          case StorePurchaseStatus.purchased:
          case StorePurchaseStatus.restored:
            if (await verifyPurchase(purchase)) {
              _restoreFoundPurchase = true;
              _restoreTimer?.cancel();
              await _grantEntitlement();
              _setStatus(
                purchase.status == StorePurchaseStatus.restored
                    ? RemoveAdsStatus.restored
                    : RemoveAdsStatus.purchased,
              );
            }
        }
      }

      // Completed for every delivered purchase, including ids this build does
      // not know: an unfinished StoreKit transaction is redelivered on every
      // launch and blocks the queue behind it, and Play refunds an order that
      // goes unacknowledged for three days. A failure here is not fatal — the
      // purchase stays outstanding and the next launch's restore retries it —
      // so it must not take down the entitlement we just granted.
      if (purchase.pendingCompletePurchase) {
        try {
          await _client.completePurchase(purchase);
        } catch (error) {
          debugPrint('Remove Ads: could not finalise a purchase: $error');
        }
      }
    }
  }

  @protected
  Future<bool> verifyPurchase(StorePurchaseUpdate purchase) async {
    // Local, on-device trust boundary for both stores. Replace this method
    // with server-side receipt/token validation without changing entitlement
    // consumers.
    return purchase.productId == productId;
  }

  Future<void> _grantEntitlement() async {
    if (_isAdsRemoved) return;
    _isAdsRemoved = true;
    await _persistence.write(true);
    notifyListeners();
  }

  void _setStatus(RemoveAdsStatus value, [String? error]) {
    _status = value;
    _errorMessage = error;
    _statusRevision++;
    // The UI shows a localized headline, so the store's own wording is only
    // useful here, where a bug report can pick it up.
    if (error != null) debugPrint('Remove Ads: $value — $error');
    notifyListeners();
  }

  @override
  void dispose() {
    _restoreTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
