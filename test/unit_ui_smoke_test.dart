import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/major_recommendation.dart';
import 'package:mechanical_engineering_toolkit/home/major_tools_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider(create: (_) => ToolHistory()),
      ],
      child: MaterialApp(
        // The real app theme carries the AppTokens extension that
        // AppSectionCard/AppContent depend on via context.tokens.
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

  testWidgets('UnitField shows its unit suffix before anything is typed',
      (tester) async {
    await tester.pumpWidget(_wrap(
      Scaffold(
        body: UnitField(
          label: 'Span, L',
          category: UnitCategory.span,
          initialSI: null,
          onChangedSI: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Field is empty and unfocused, yet the unit must still be visible.
    expect(find.text('m'), findsOneWidget);
  });

  testWidgets('UnitField suffix switches with the unit system', (tester) async {
    late UnitSystemPreference pref;
    await tester.pumpWidget(_wrap(
      Builder(builder: (context) {
        pref = context.read<UnitSystemPreference>();
        return Scaffold(
          body: UnitField(
            label: 'Span, L',
            category: UnitCategory.span,
            initialSI: null,
            onChangedSI: (_) {},
          ),
        );
      }),
    ));
    await tester.pumpAndSettle();
    expect(find.text('m'), findsOneWidget);

    pref.set(UnitSystem.imperial);
    await tester.pumpAndSettle();
    expect(find.text('ft'), findsOneWidget);
    expect(find.text('m'), findsNothing);
  });

  testWidgets('Recommended by major is gone from Settings', (tester) async {
    await tester.pumpWidget(_wrap(const ToolSettingPage()));
    await tester.pumpAndSettle();

    expect(find.text('RECOMMENDED BY MAJOR'), findsNothing);
    for (final major in majorRecommendations) {
      expect(find.text(major.title), findsNothing);
    }
  });

  testWidgets('Side menu lists every major and opens its tools',
      (tester) async {
    await tester.pumpWidget(_wrap(const ToolPage()));
    await tester.pumpAndSettle();

    // Open the drawer.
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('RECOMMENDED BY MAJOR'), findsOneWidget);
    for (final major in majorRecommendations) {
      expect(find.text(major.title), findsOneWidget);
    }

    // Tapping a major navigates to its curated tool list.
    await tester.tap(find.text(majorRecommendations.first.title));
    await tester.pumpAndSettle();
    expect(find.byType(MajorToolsPage), findsOneWidget);
  });
}
