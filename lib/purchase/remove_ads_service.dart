import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

const removeAdsProductId =
    'com.appsbay.mechanicalEngineeringToolkit.remove_ads';

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

class StoreKitPurchaseClient implements PurchaseClient {
  StoreKitPurchaseClient({InAppPurchase? store})
      : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseStream =>
      _store.purchaseStream.map(
        (purchases) => purchases.map(_mapPurchase).toList(growable: false),
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

  StorePurchaseUpdate _mapPurchase(PurchaseDetails purchase) {
    return StorePurchaseUpdate(
      productId: purchase.productID,
      status: switch (purchase.status) {
        PurchaseStatus.pending => StorePurchaseStatus.pending,
        PurchaseStatus.purchased => StorePurchaseStatus.purchased,
        PurchaseStatus.restored => StorePurchaseStatus.restored,
        PurchaseStatus.canceled => StorePurchaseStatus.cancelled,
        PurchaseStatus.error => StorePurchaseStatus.error,
      },
      pendingCompletePurchase: purchase.pendingCompletePurchase,
      errorMessage: purchase.error?.message,
      rawPurchase: purchase,
    );
  }
}

class RemoveAdsService extends ChangeNotifier {
  RemoveAdsService({
    PurchaseClient? client,
    EntitlementPersistence? persistence,
    bool? isIOS,
    this.restoreTimeout = const Duration(seconds: 3),
  })  : _client = client ?? StoreKitPurchaseClient(),
        _persistence = persistence ?? SharedPreferencesEntitlementPersistence(),
        isSupported = isIOS ?? Platform.isIOS;

  final PurchaseClient _client;
  final EntitlementPersistence _persistence;
  final Duration restoreTimeout;
  final bool isSupported;

  StreamSubscription<List<StorePurchaseUpdate>>? _subscription;
  Timer? _restoreTimer;
  StoreProduct? _product;
  bool _isAdsRemoved = false;
  bool _restoreFoundPurchase = false;
  RemoveAdsStatus _status = RemoveAdsStatus.idle;
  String? _errorMessage;

  bool get isAdsRemoved => _isAdsRemoved;
  StoreProduct? get product => _product;
  String? get localizedPrice => _product?.price;
  RemoveAdsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isBusy => const {
        RemoveAdsStatus.loading,
        RemoveAdsStatus.purchasing,
        RemoveAdsStatus.pending,
        RemoveAdsStatus.restoring,
      }.contains(_status);

  Future<void> init() async {
    _isAdsRemoved = _persistence.read();
    if (!isSupported) return;
    _subscription = _client.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        _setStatus(RemoveAdsStatus.failed, error.toString());
      },
    );
    await loadProducts();
    if (await _client.isAvailable()) {
      await _restore(refreshOnly: true);
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
      _product = await _client.loadProduct(removeAdsProductId);
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
      if (purchase.productId != removeAdsProductId) continue;
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
      if (purchase.pendingCompletePurchase) {
        await _client.completePurchase(purchase);
      }
    }
  }

  @protected
  Future<bool> verifyPurchase(StorePurchaseUpdate purchase) async {
    // Local StoreKit trust boundary. Replace this method with server-side
    // verification without changing entitlement consumers.
    return purchase.productId == removeAdsProductId;
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
    notifyListeners();
  }

  @override
  void dispose() {
    _restoreTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
