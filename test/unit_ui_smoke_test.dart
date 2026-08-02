import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/major_list_page.dart';
import 'package:mechanical_engineering_toolkit/home/major_recommendation.dart';
import 'package:mechanical_engineering_toolkit/home/major_tools_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
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
        ChangeNotifierProvider(create: (_) => LanguagePreference()),
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

/// Major names in the active locale. Resolved from a context inside the
/// pumped app so the localizations delegate is in scope.
List<String> _majorTitles(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return [for (final major in majorRecommendations) major.title(context)];
}

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
    for (final title in _majorTitles(tester)) {
      expect(find.text(title), findsNothing);
    }
  });

  testWidgets(
      'Side menu has a single Recommended by Major row that opens the major list',
      (tester) async {
    await tester.pumpWidget(_wrap(const ToolPage()));
    await tester.pumpAndSettle();

    // Open the drawer.
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    final row = find.text('Recommended by Major');
    expect(row, findsOneWidget);
    // Majors themselves are not inlined in the drawer anymore.
    for (final title in _majorTitles(tester)) {
      expect(find.text(title), findsNothing);
    }

    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(find.byType(MajorListPage), findsOneWidget);
    for (final title in _majorTitles(tester)) {
      expect(find.text(title), findsOneWidget);
    }

    // Tapping a major navigates to its curated tool list.
    await tester.tap(find.text(_majorTitles(tester).first));
    await tester.pumpAndSettle();
    expect(find.byType(MajorToolsPage), findsOneWidget);
  });

  testWidgets('Tool search filters tools and can be cleared', (tester) async {
    await tester.pumpWidget(_wrap(const ToolPage()));
    await tester.pumpAndSettle();

    final searchField = find.byKey(const Key('toolSearchField'));
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'unit converter');
    await tester.pump();

    expect(find.text('Unit Converter'), findsOneWidget);
    expect(find.byType(ToolGridTile), findsOneWidget);

    await tester.enterText(searchField, 'tool that does not exist');
    await tester.pump();

    expect(find.text('No tools found'), findsOneWidget);
    expect(find.byType(ToolGridTile), findsNothing);

    await tester.tap(find.byKey(const Key('clearToolSearch')));
    await tester.pump();

    expect(find.text('No tools found'), findsNothing);
    expect(find.byType(ToolGridTile), findsWidgets);
  });

  testWidgets('Side menu language row picks and remembers a language',
      (tester) async {
    await tester.pumpWidget(_wrap(const ToolPage()));
    await tester.pumpAndSettle();

    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    // Defaults to following the device locale.
    expect(find.text('System default'), findsOneWidget);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    // Every option is listed under its own endonym.
    expect(find.text('English'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);

    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();

    expect(LanguagePreference().language, AppLanguage.simplifiedChinese);
    // The drawer row now reflects the pick.
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('System default'), findsNothing);
  });
}
