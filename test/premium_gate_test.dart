import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';

import 'remove_ads_service_test.dart' show FakePersistence, FakePurchaseClient;

const _mobile = PremiumGate(isEntitled: false, gatesFeatures: false);
const _macFree = PremiumGate(isEntitled: false, gatesFeatures: true);
const _macPaid = PremiumGate(isEntitled: true, gatesFeatures: true);

void main() {
  group('what the gate lets through', () {
    test('a platform that gates nothing locks nothing', () {
      expect(_mobile.isUnlocked, isTrue);
      expect(_mobile.showsLocks, isFalse);
      expect(_mobile.historyLimit, isNull);
      for (final feature in PremiumFeature.values) {
        expect(_mobile.isFeatureLocked(feature), isFalse, reason: '$feature');
      }
      // Including a tool that is not in the free set: the set is macOS-only.
      expect(_mobile.isToolLocked(704), isFalse);
    });

    test('a gating platform without the purchase locks all but the free set',
        () {
      expect(_macFree.showsLocks, isTrue);
      expect(_macFree.historyLimit, PremiumGate.freeHistoryLimit);
      for (final feature in PremiumFeature.values) {
        expect(_macFree.isFeatureLocked(feature), isTrue, reason: '$feature');
      }
      expect(_macFree.isToolLocked(500), isFalse, reason: 'unit converter');
      expect(_macFree.isToolLocked(704), isTrue, reason: 'bearing L10 life');
    });

    test('the purchase unlocks everything on a gating platform', () {
      expect(_macPaid.isUnlocked, isTrue);
      expect(_macPaid.showsLocks, isFalse);
      expect(_macPaid.historyLimit, isNull);
      expect(_macPaid.isToolLocked(704), isFalse);
      for (final feature in PremiumFeature.values) {
        expect(_macPaid.isFeatureLocked(feature), isFalse, reason: '$feature');
      }
    });
  });

  group('the free tool set', () {
    testWidgets('names only tools that exist, and gives every category one',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(),
      ));
      await tester.pumpAndSettle();

      final tools =
          ToolLibrary.shared.getTools(tester.element(find.byType(Scaffold)));
      final ids = tools.map((t) => t.id).toSet();

      // A typo'd id would silently shrink the free tier with no other symptom.
      expect(kFreeToolIds.difference(ids), isEmpty,
          reason: 'free ids with no tool behind them');

      // The whole point of the curated set: a free user should find something
      // that works in every section of the library, not a wall of padlocks.
      final freeTypes = tools
          .where((t) => kFreeToolIds.contains(t.id))
          .map((t) => t.type)
          .toSet();
      expect(freeTypes, containsAll(ToolType.values),
          reason: 'a category with nothing free in it');

      // And it has to stay a taster, not the whole app.
      expect(kFreeToolIds.length, lessThan(tools.length / 2));
    });
  });

  group('the entitlement behind the gate', () {
    test('macOS transacts against the same product as iOS', () {
      // Universal Purchase: one App Store Connect record, one in-app purchase.
      // If these ever diverge, a customer who bought on iPhone would be asked
      // to pay again on their Mac.
      expect(
        AppStore.macAppStore.removeAdsProductId,
        AppStore.appStore.removeAdsProductId,
      );
      expect(AppStore.macAppStore.removeAdsProductId, isNotEmpty);
    });

    test('isEntitled and isAdsRemoved are the one flag under two names', () {
      final service = RemoveAdsService(
        // A fake client, because the default one reaches for a real billing
        // connection the moment it is constructed.
        client: FakePurchaseClient(),
        persistence: FakePersistence(value: true),
        store: AppStore.macAppStore,
      )..loadPersistedEntitlement();
      expect(service.isEntitled, isTrue);
      expect(service.isEntitled, service.isAdsRemoved);
      expect(service.isSupported, isTrue);
      service.dispose();
    });
  });

  group('platform capabilities', () {
    tearDown(AppPlatform.clearOverride);

    test('a test host starts ungated, so unrelated tests are not gated', () {
      expect(AppPlatform.current.gatesFeatures, isFalse);
      expect(AppPlatform.current.supportsAds, isTrue);
    });

    test('macOS gates features and serves no ads', () {
      AppPlatform.overrideWith(AppPlatform.macOS);
      expect(AppPlatform.current.gatesFeatures, isTrue);
      expect(AppPlatform.current.supportsAds, isFalse);
    });
  });
}
