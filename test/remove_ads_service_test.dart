import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
        isIOS: true,
      );

      await service.init();

      expect(service.isAdsRemoved, isTrue);
      expect(service.status, RemoveAdsStatus.unavailable);
      await client.close();
      service.dispose();
    });

    test('does not connect to a store on Android', () async {
      final client = FakePurchaseClient();
      final service = RemoveAdsService(
        client: client,
        persistence: FakePersistence(),
        isIOS: false,
      );

      await service.init();

      expect(service.isSupported, isFalse);
      expect(client.availabilityChecks, 0);
      expect(client.restoreCalls, 0);
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
        isIOS: true,
      );
      await service.init();

      await service.buyRemoveAds();
      client.emit(const StorePurchaseUpdate(
        productId: removeAdsProductId,
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
        isIOS: true,
      );
      await service.init();

      client.emit(const StorePurchaseUpdate(
        productId: removeAdsProductId,
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
        isIOS: true,
        restoreTimeout: const Duration(milliseconds: 10),
      );
      await service.init();

      await service.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(service.status, RemoveAdsStatus.restoreNotFound);

      await service.restorePurchases();
      client.emit(const StorePurchaseUpdate(
        productId: removeAdsProductId,
        status: StorePurchaseStatus.restored,
      ));
      await flushEvents();
      expect(service.status, RemoveAdsStatus.restored);
      expect(service.isAdsRemoved, isTrue);
      await client.close();
      service.dispose();
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
  FakePurchaseClient({this.available = true});

  final bool available;
  final _controller =
      StreamController<List<StorePurchaseUpdate>>.broadcast(sync: true);
  int availabilityChecks = 0;
  int restoreCalls = 0;
  int completeCalls = 0;

  @override
  Stream<List<StorePurchaseUpdate>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async {
    availabilityChecks++;
    return available;
  }

  @override
  Future<StoreProduct?> loadProduct(String productId) async {
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
