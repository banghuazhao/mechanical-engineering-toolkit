import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:provider/provider.dart';

import 'remove_ads_service_test.dart' show FakePersistence, FakePurchaseClient;

Widget _wrap(RemoveAdsService service) => ChangeNotifierProvider.value(
      value: service,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const RemoveAdsPage(),
      ),
    );

bool _enabled<T extends ButtonStyleButton>(WidgetTester tester) =>
    tester.widget<T>(find.byType(T)).onPressed != null;

void main() {
  testWidgets('a pending order blocks buying but still allows restoring',
      (tester) async {
    final client = FakePurchaseClient();
    final service = RemoveAdsService(
      client: client,
      persistence: FakePersistence(),
      store: AppStore.playStore,
    );
    // The store round trips use real timers, so they cannot run on the fake
    // clock the widget tester installs.
    await tester.runAsync(service.init);

    await tester.pumpWidget(_wrap(service));
    await tester.pump();
    expect(_enabled<FilledButton>(tester), isTrue);

    client.emit(StorePurchaseUpdate(
      productId: service.productId,
      status: StorePurchaseStatus.pending,
    ));
    await tester.pump();

    expect(_enabled<FilledButton>(tester), isFalse);
    // The whole point of keeping `pending` out of `isBusy`: a Play order can
    // sit unpaid for days, and the user must still be able to re-check it.
    expect(_enabled<TextButton>(tester), isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await client.close();
    service.dispose();
  });

  testWidgets('a second restore with the same outcome still reports back',
      (tester) async {
    final client = FakePurchaseClient();
    final service = RemoveAdsService(
      client: client,
      persistence: FakePersistence(),
      store: AppStore.playStore,
      restoreTimeout: const Duration(milliseconds: 10),
    );
    await tester.runAsync(service.init);

    await tester.pumpWidget(_wrap(service));
    await tester.pump();

    final strings = S.of(tester.element(find.byType(RemoveAdsPage)));
    final notFound = strings.Restore_Not_Found;

    await tester.tap(find.byType(TextButton));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
    expect(find.text(notFound), findsOneWidget);

    // Dismiss it, then repeat the exact same action. Silence on the second tap
    // would leave the user unsure it did anything at all.
    ScaffoldMessenger.of(tester.element(find.byType(RemoveAdsPage)))
        .removeCurrentSnackBar();
    await tester.pump();
    expect(find.text(notFound), findsNothing);

    await tester.tap(find.byType(TextButton));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump();
    expect(find.text(notFound), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(RemoveAdsPage)))
        .removeCurrentSnackBar();
    await tester.pump();
    await client.close();
    service.dispose();
  });

  testWidgets('opening the page retries a product load that never happened',
      (tester) async {
    final client = FakePurchaseClient();
    final service = RemoveAdsService(
      client: client,
      persistence: FakePersistence(),
      store: AppStore.playStore,
    );
    // Stands in for a launch with no network: nothing was ever loaded, and
    // without the retry the page would read "unavailable" all session.
    expect(service.product, isNull);

    await tester.pumpWidget(_wrap(service));
    await tester.pump();
    await tester.pump();

    expect(client.loadedProductIds, ['remove_ads']);
    expect(service.product, isNotNull);
    expect(_enabled<FilledButton>(tester), isTrue);

    await client.close();
    service.dispose();
  });

  testWidgets('opening the page does not announce a launch-time restore',
      (tester) async {
    final client = FakePurchaseClient();
    final service = RemoveAdsService(
      client: client,
      persistence: FakePersistence(),
      store: AppStore.playStore,
    );
    await tester.runAsync(() async {
      await service.init();
      client.emit(StorePurchaseUpdate(
        productId: service.productId,
        status: StorePurchaseStatus.restored,
      ));
      await Future<void>.delayed(Duration.zero);
    });
    expect(service.status, RemoveAdsStatus.restored);

    await tester.pumpWidget(_wrap(service));
    await tester.pump();

    // The restore happened at launch, before this page existed; announcing it
    // on open would read as a response to opening the page.
    expect(find.byType(SnackBar), findsNothing);
    final strings = S.of(tester.element(find.byType(RemoveAdsPage)));
    expect(find.text(strings.Ads_Removed), findsOneWidget);

    await client.close();
    service.dispose();
  });
}
