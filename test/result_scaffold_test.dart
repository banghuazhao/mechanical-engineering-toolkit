import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
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

  testWidgets('renders every child and the standard actions', (tester) async {
    await tester.pumpWidget(_wrap(ResultScaffold(
      toolName: 'Widget Test Tool',
      shareLines: () => const ['a = 1'],
      children: const [
        AppSectionCard(title: 'First', child: Text('one')),
        AppSectionCard(title: 'Second', child: Text('two')),
      ],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Result'), findsOneWidget);
    expect(find.text('one'), findsOneWidget);
    expect(find.text('two'), findsOneWidget);
    expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('hides the text-share action when no lines are supplied',
      (tester) async {
    await tester.pumpWidget(_wrap(const ResultScaffold(
      toolName: 'Widget Test Tool',
      children: [AppSectionCard(title: 'Only', child: Text('body'))],
    )));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.share_rounded), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  group('declared results', () {
    const sections = [
      ResultSection(
        title: 'Spring',
        values: [
          ResultValue(label: 'Spring index, C', valueSI: 10),
          ResultValue(
            label: 'Solid height',
            valueSI: 25.4,
            category: UnitCategory.length,
          ),
        ],
      ),
    ];

    testWidgets('renders one card per section with its values',
        (tester) async {
      await tester.pumpWidget(_wrap(const ResultScaffold(
        toolName: 'Widget Test Tool',
        results: sections,
      )));
      await tester.pumpAndSettle();

      expect(find.text('SPRING'), findsOneWidget);
      expect(find.text('Spring index, C'), findsOneWidget);
      expect(find.text('Solid height'), findsOneWidget);
      expect(find.textContaining('25.400 mm'), findsOneWidget);
    });

    testWidgets('offers CSV and PDF export, and share comes for free',
        (tester) async {
      await tester.pumpWidget(_wrap(const ResultScaffold(
        toolName: 'Widget Test Tool',
        results: sections,
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
      // No shareLines was supplied; declaring results supplies it.
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.file_download_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Export PDF'), findsOneWidget);
    });

    testWidgets('withholds export from an unmigrated page',
        (tester) async {
      // Hand-written share lines have already fused label, value, and unit
      // into one string, so there is nothing to put in columns.
      await tester.pumpWidget(_wrap(ResultScaffold(
        toolName: 'Widget Test Tool',
        shareLines: () => const ['a = 1'],
        children: const [AppSectionCard(title: 'Only', child: Text('body'))],
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download_outlined), findsNothing);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });

    testWidgets('renders declared results above hand-built children',
        (tester) async {
      await tester.pumpWidget(_wrap(const ResultScaffold(
        toolName: 'Widget Test Tool',
        results: sections,
        children: [FormulaCard(steps: ['k = G·d⁴/(8·D³·Na)'])],
      )));
      await tester.pumpAndSettle();

      expect(find.text('SPRING'), findsOneWidget);
      expect(find.text('FORMULA'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('SPRING')).dy,
        lessThan(tester.getTopLeft(find.text('FORMULA')).dy),
      );
    });
  });

  testWidgets('an explicit title overrides the default "Result"',
      (tester) async {
    await tester.pumpWidget(_wrap(const ResultScaffold(
      toolName: 'Widget Test Tool',
      title: 'Centroid of Composite Area',
      children: [AppSectionCard(title: 'Only', child: Text('body'))],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Centroid of Composite Area'), findsOneWidget);
    expect(find.text('Result'), findsNothing);
  });

  testWidgets('a custom body replaces the default list', (tester) async {
    await tester.pumpWidget(_wrap(const ResultScaffold(
      toolName: 'Widget Test Tool',
      body: Center(child: Text('custom body')),
    )));
    await tester.pumpAndSettle();

    expect(find.text('custom body'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('FormulaCard joins its steps under a Formula heading',
      (tester) async {
    await tester.pumpWidget(_wrap(const ResultScaffold(
      toolName: 'Widget Test Tool',
      children: [
        FormulaCard(steps: ['σ = F / A', '= 100 N / 2 mm²', '= 50 MPa']),
      ],
    )));
    await tester.pumpAndSettle();

    expect(find.text('FORMULA'), findsOneWidget);
    expect(find.text('σ = F / A\n= 100 N / 2 mm²\n= 50 MPa'), findsOneWidget);
  });

  group('formatSI', () {
    test('appends the unit label for the active system', () {
      final precs = NumberPrecisionHelper();
      expect(precs.formatSI(25.4, UnitCategory.length, UnitSystem.si),
          endsWith(' mm'));
      expect(precs.formatSI(25.4, UnitCategory.length, UnitSystem.imperial),
          endsWith(' in'));
    });

    test('omits the unit for a dimensionless value', () {
      final precs = NumberPrecisionHelper();
      final formatted = precs.formatSI(2.5, null, UnitSystem.si);
      expect(formatted, isNot(contains(' ')));
    });
  });

  group('formatFixed', () {
    test('drops trailing zeros', () {
      expect(formatFixed(1000), '1000');
      expect(formatFixed(1200.5), '1200.5');
      expect(formatFixed(0), '0');
    });

    test('honours the requested decimal count', () {
      expect(formatFixed(1.23456, decimals: 3), '1.235');
      expect(formatFixed4(1.23456), '1.2346');
    });
  });
}
