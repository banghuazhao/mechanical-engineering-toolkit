import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/theme_preference.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child, {ThemePreference? themePref}) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => themePref ?? ThemePreference()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: child,
      ),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('ThemePreference', () {
    test('defaults to following the system', () {
      final pref = ThemePreference();
      expect(pref.appThemeMode, AppThemeMode.system);
      expect(pref.themeMode, ThemeMode.system);
    });

    test('each choice maps to the matching ThemeMode', () {
      final pref = ThemePreference();

      pref.set(AppThemeMode.light);
      expect(pref.themeMode, ThemeMode.light);

      pref.set(AppThemeMode.dark);
      expect(pref.themeMode, ThemeMode.dark);

      pref.set(AppThemeMode.system);
      expect(pref.themeMode, ThemeMode.system);
    });

    test('persists the choice across instances', () {
      ThemePreference().set(AppThemeMode.dark);
      // A fresh instance reads the same backing store the app would on
      // relaunch.
      expect(ThemePreference().appThemeMode, AppThemeMode.dark);
      expect(ThemePreference().themeMode, ThemeMode.dark);
    });

    test('notifies listeners so MaterialApp rebuilds', () {
      final pref = ThemePreference();
      var notifications = 0;
      pref.addListener(() => notifications++);

      pref.set(AppThemeMode.dark);
      expect(notifications, 1);

      pref.set(AppThemeMode.light);
      expect(notifications, 2);
    });

    test('falls back to system when the stored value is unrecognized', () {
      // Guards against a crash if the enum is ever renamed under an
      // already-installed app.
      SharedPreferences.setMockInitialValues({'App_Theme_Mode': 'sepia'});
      return SharedPreferencesHelper.init().then((_) {
        expect(ThemePreference().appThemeMode, AppThemeMode.system);
      });
    });
  });

  group('Settings appearance card', () {
    testWidgets('offers all three appearance choices', (tester) async {
      await tester.pumpWidget(_wrap(const ToolSettingPage()));
      await tester.pumpAndSettle();

      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('tapping a choice records it', (tester) async {
      final pref = ThemePreference();
      await tester.pumpWidget(_wrap(const ToolSettingPage(), themePref: pref));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(pref.appThemeMode, AppThemeMode.dark);
      expect(pref.themeMode, ThemeMode.dark);
    });

    testWidgets('the other setting sections still render', (tester) async {
      // The appearance card was added by extracting the picker the unit and
      // format sections already used; make sure both survived the refactor.
      await tester.pumpWidget(_wrap(const ToolSettingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Metric (SI)'), findsOneWidget);
      expect(find.text('Imperial (US)'), findsOneWidget);

      // The display format card sits below the fold now that appearance is
      // above it, so scroll it into view before asserting.
      await tester.scrollUntilVisible(find.text('Engineering'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Scientific'), findsOneWidget);
      expect(find.text('Decimal'), findsOneWidget);
      expect(find.text('Engineering'), findsOneWidget);
    });
  });
}
