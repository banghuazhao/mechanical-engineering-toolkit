import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';

void main() {
  group('RemoveAdsService', () {
    test('loads a persisted entitlement for offline launch', () async {
      final persistence = FakePersistence(value: true);
      final client = FakePurchaseClient(available: false);
      final service = RemoveAdsService(
        client: client,
        persistence: persistence,
        store: AppStore.appStore,
      );

      await service.init();

      expect(service.isAdsRemoved, isTrue);
      expect(service.status, RemoveAdsStatus.unavailable);
      await client.close();
      service.dispose();
    });

    test('does not connect to a store on a host without one', () async {
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: FakePersistence(),
        store: AppStore.none,
      );

      await service.init();

      expect(service.isSupported, isFalse);
      expect(client.availabilityChecks, 0);
      expect(client.restoreCalls, 0);
      await client.close();
      service.dispose();
    });

    test('buys the Play product id on Android', () async {
      final persistence = FakePersistence();
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: persistence,
        store: AppStore.playStore,
      );
      await service.init();

      expect(service.isSupported, isTrue);
      // Play rejects the App Store's mixed-case reverse-DNS identifier.
      expect(service.productId, 'remove_ads');
      expect(service.productId, matches(RegExp(r'^[a-z0-9][a-z0-9_.]*$')));
      expect(client.loadedProductIds, ['remove_ads']);

      await service.buyRemoveAds();
      client.emit(StorePurchaseUpdate(
        productId: service.productId,
        status: StorePurchaseStatus.purchased,
        pendingCompletePurchase: true,
      ));
      await flushEvents();

      expect(service.isAdsRemoved, isTrue);
      expect(service.status, RemoveAdsStatus.purchased);
      expect(persistence.value, isTrue);
      // Play voids a purchase that is never acknowledged.
      expect(client.completeCalls, 1);
      await client.close();
      service.dispose();
    });

    test('ignores a purchase for another store\'s product id', () async {
      final persistence = FakePersistence();
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: persistence,
        store: AppStore.playStore,
      );
      await service.init();

      client.emit(StorePurchaseUpdate(
        productId: AppStore.appStore.removeAdsProductId,
        status: StorePurchaseStatus.purchased,
        pendingCompletePurchase: true,
      ));
      await flushEvents();

      expect(service.isAdsRemoved, isFalse);
      expect(persistence.value, isFalse);
      // Still finalised: an unfinished transaction is redelivered forever on
      // StoreKit and auto-refunded after three days on Play.
      expect(client.completeCalls, 1);
      await client.close();
      service.dispose();
    });

    test('a pending Play purchase grants nothing until payment clears',
        () async {
      final persistence = FakePersistence();
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: persistence,
        store: AppStore.playStore,
      );
      await service.init();

      // What the adapter produces for an order Play returned from a restore
      // while its payment is still uncleared: pending, and not to be
      // acknowledged.
      client.emit(StorePurchaseUpdate(
        productId: service.productId,
        status: StorePurchaseStatus.pending,
      ));
      await flushEvents();

      expect(service.isAdsRemoved, isFalse);
      expect(persistence.value, isFalse);
      expect(service.status, RemoveAdsStatus.pending);
      expect(client.completeCalls, 0);
      // A Play order can stay pending for days and every launch rediscovers
      // it, so this must not read as work in flight — that would spin the buy
      // button and disable restore until the payment cleared.
      expect(service.hasPendingPurchase, isTrue);
      expect(service.isBusy, isFalse);
      await client.close();
      service.dispose();
    });

    test('reads the persisted entitlement without touching the store',
        () async {
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: FakePersistence(value: true),
        store: AppStore.playStore,
      );

      service.loadPersistedEntitlement();

      // Synchronous, so the first frame can suppress ads without waiting on a
      // billing connection that may be slow or unreachable.
      expect(service.isAdsRemoved, isTrue);
      expect(client.availabilityChecks, 0);
      expect(client.loadedProductIds, isEmpty);
      await client.close();
      service.dispose();
    });

    test('init survives a store that cannot be reached', () async {
      final client = FakePurchaseClient(throwOnAvailability: true);
      final service = RemoveAdsService(
        client: client,
        persistence: FakePersistence(value: true),
        store: AppStore.playStore,
      );

      // main() leaves init() unawaited, so a throw here would surface as an
      // unhandled async error rather than a caught failure.
      await expectLater(service.init(), completes);

      expect(service.isAdsRemoved, isTrue);
      expect(service.status, RemoveAdsStatus.unavailable);
      await client.close();
      service.dispose();
    });

    test('grants and persists entitlement after a completed purchase',
        () async {
      final persistence = FakePersistence();
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: persistence,
        store: AppStore.appStore,
      );
      await service.init();

      await service.buyRemoveAds();
      client.emit(StorePurchaseUpdate(
        productId: service.productId,
        status: StorePurchaseStatus.purchased,
        pendingCompletePurchase: true,
      ));
      await flushEvents();

      expect(service.isAdsRemoved, isTrue);
      expect(service.status, RemoveAdsStatus.purchased);
      expect(persistence.value, isTrue);
      expect(client.completeCalls, 1);
      await client.close();
      service.dispose();
    });

    test('cancel leaves entitlement unchanged', () async {
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: FakePersistence(),
        store: AppStore.appStore,
      );
      await service.init();

      client.emit(StorePurchaseUpdate(
        productId: service.productId,
        status: StorePurchaseStatus.cancelled,
      ));
      await flushEvents();

      expect(service.isAdsRemoved, isFalse);
      expect(service.status, RemoveAdsStatus.cancelled);
      await client.close();
      service.dispose();
    });

    test('restore reports both restored and not-found outcomes', () async {
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: FakePersistence(),
        store: AppStore.appStore,
        restoreTimeout: const Duration(milliseconds: 10),
      );
      await service.init();

      await service.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(service.status, RemoveAdsStatus.restoreNotFound);

      await service.restorePurchases();
      client.emit(StorePurchaseUpdate(
        productId: service.productId,
        status: StorePurchaseStatus.restored,
      ));
      await flushEvents();
      expect(service.status, RemoveAdsStatus.restored);
      expect(service.isAdsRemoved, isTrue);
      await client.close();
      service.dispose();
    });
  });

  group('PlatformPurchaseClient mapping', () {
    // Play's restore path relabels every queried order `restored` and flags it
    // for acknowledgement regardless of whether its payment cleared, so the
    // adapter has to fall back on the billing state.
    GooglePlayPurchaseDetails playPurchase({
      required PurchaseStateWrapper purchaseState,
      required PurchaseStatus status,
    }) {
      return GooglePlayPurchaseDetails(
        purchaseID: 'order-1',
        productID: AppStore.playStore.removeAdsProductId,
        verificationData: PurchaseVerificationData(
          localVerificationData: '{}',
          serverVerificationData: 'token',
          source: 'google_play',
        ),
        transactionDate: '0',
        status: status,
        billingClientPurchase: PurchaseWrapper(
          orderId: 'order-1',
          packageName: 'com.appsbay.mechanical_engineering_toolkit',
          purchaseTime: 0,
          purchaseToken: 'token',
          signature: 'signature',
          products: [AppStore.playStore.removeAdsProductId],
          isAutoRenewing: false,
          originalJson: '{}',
          isAcknowledged: false,
          purchaseState: purchaseState,
        ),
      );
    }

    test('demotes an uncleared Play order to pending', () {
      final update = PlatformPurchaseClient.mapPurchase(playPurchase(
        purchaseState: PurchaseStateWrapper.pending,
        status: PurchaseStatus.restored,
      ));

      expect(update.status, StorePurchaseStatus.pending);
      // Play rejects acknowledging an order that has not been paid for.
      expect(update.pendingCompletePurchase, isFalse);
    });

    test('keeps a paid Play order restorable and acknowledgeable', () {
      final update = PlatformPurchaseClient.mapPurchase(playPurchase(
        purchaseState: PurchaseStateWrapper.purchased,
        status: PurchaseStatus.restored,
      ));

      expect(update.status, StorePurchaseStatus.restored);
      expect(update.pendingCompletePurchase, isTrue);
    });

    test('leaves a cancelled Play order alone', () {
      final update = PlatformPurchaseClient.mapPurchase(playPurchase(
        purchaseState: PurchaseStateWrapper.unspecified_state,
        status: PurchaseStatus.canceled,
      ));

      expect(update.status, StorePurchaseStatus.cancelled);
    });
  });

  test('ad requests are denied when the entitlement is active', () async {
    AdsManager.setAdsRemoved(true);
    expect(await AdsManager.canRequestAds(), isFalse);
    AdsManager.setAdsRemoved(false);
  });
}

Future<void> flushEvents() => Future<void>.delayed(Duration.zero);

class FakePersistence implements EntitlementPersistence {
  FakePersistence({this.value = false});

  bool value;

  @override
  bool read() => value;

  @override
  Future<void> write(bool newValue) async => value = newValue;
}

class FakePurchaseClient implements PurchaseClient {
  FakePurchaseClient({this.available = true, this.throwOnAvailability = false});

  final bool available;
  final bool throwOnAvailability;
  final _controller =
      StreamController<List<StorePurchaseUpdate>>.broadcast(sync: true);
  int availabilityChecks = 0;
  int restoreCalls = 0;
  int completeCalls = 0;
  final List<String> loadedProductIds = [];

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async {
    availabilityChecks++;
    if (throwOnAvailability) throw StateError('store unreachable');
    return available;
  }

  @override
  Future<StoreProduct?> loadProduct(String productId) async {
    loadedProductIds.add(productId);
    return StoreProduct(
      id: productId,
      title: 'Remove Ads',
      description: 'Remove ads permanently.',
      price: r'$2.99',
    );
  }

  @override
  Future<bool> buyNonConsumable(StoreProduct product) async => true;

  @override
  Future<void> restorePurchases() async => restoreCalls++;

  @override
  Future<void> completePurchase(StorePurchaseUpdate purchase) async {
    completeCalls++;
  }

  void emit(StorePurchaseUpdate purchase) => _controller.add([purchase]);

  Future<void> close() => _controller.close();
}
