import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/air_cycle_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/air_cycle_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/ideal_gas_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/ideal_gas_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/rankine_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/rankine_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/steam_tables_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/steam_tables_result_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/line_plot_card.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/theme_preference.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider(create: (_) => ToolHistory()),
        ChangeNotifierProvider(create: (_) => SavedProjects()),
        ChangeNotifierProvider(create: (_) => LanguagePreference()),
        ChangeNotifierProvider(create: (_) => ThemePreference()),
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

Future<void> _fill(WidgetTester tester, String label, String value) async {
  await tester.enterText(
    find.ancestor(of: find.text(label), matching: find.byType(TextField)),
    value,
  );
  await tester.pump();
}

Future<void> _calculate(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

/// The input pages are taller than a default 600px viewport, and an
/// off-screen field cannot be typed into.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Every value shown beside [label] on a result page, in order. A cycle
/// repeats its labels once per state, so the caller picks which one it means.
List<String> _valuesFor(WidgetTester tester, String label) {
  final rows = find.ancestor(of: find.text(label), matching: find.byType(Row));
  return [
    for (var i = 0; i < rows.evaluate().length; i++)
      tester
          .widgetList<Text>(
              find.descendant(of: rows.at(i), matching: find.byType(Text)))
          .map((t) => t.data)
          .whereType<String>()
          .firstWhere((t) => t != label),
  ];
}

/// The single value beside [label].
String _valueFor(WidgetTester tester, String label) =>
    _valuesFor(tester, label).single;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  testWidgets('Steam tables looks up a saturation row by temperature',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const SteamTablesPage(title: 'Steam Tables', toolId: 900),
    ));
    await tester.pumpAndSettle();

    // Switch the lookup from the default (p, T) to saturation by temperature.
    await tester.tap(find.text('Pressure and temperature'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saturation, by temperature').last);
    await tester.pumpAndSettle();

    await _fill(tester, 'Temperature, T', '100');
    await _calculate(tester);

    expect(find.byType(SteamTablesResultPage), findsOneWidget);
    // AppSectionCard sets its heading in upper case.
    expect(find.text('SATURATED LIQUID (F)'), findsOneWidget);
    expect(find.text('SATURATED VAPOUR (G)'), findsOneWidget);
    // 101.4 kPa at 100 °C, and the latent heat of 2256 kJ/kg.
    expect(_valueFor(tester, 'Saturation pressure, psat'),
        startsWith('101.4'));
    expect(_valueFor(tester, 'Latent heat, hfg'), startsWith('2256'));
    // The dome is drawn behind the state.
    expect(find.byType(LinePlotCard), findsOneWidget);
  });

  testWidgets('Steam tables names the phase of a superheated state',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const SteamTablesPage(title: 'Steam Tables', toolId: 900),
    ));
    await tester.pumpAndSettle();

    await _fill(tester, 'Pressure, p', '8000');
    await _fill(tester, 'Temperature, T', '500');
    await _calculate(tester);

    expect(find.text('Superheated vapour'), findsOneWidget);
    expect(_valueFor(tester, 'Specific enthalpy, h'), startsWith('3399'));
  });

  testWidgets('Steam tables explains a state it cannot compute',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const SteamTablesPage(title: 'Steam Tables', toolId: 900),
    ));
    await tester.pumpAndSettle();

    await _fill(tester, 'Pressure, p', '120000'); // 120 MPa
    await _fill(tester, 'Temperature, T', '300');
    await _calculate(tester);

    expect(find.byType(SteamTablesResultPage), findsNothing);
    expect(find.textContaining('Outside IAPWS-IF97'), findsOneWidget);
  });

  testWidgets('Ideal gas computes an isentropic compression', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const IdealGasPage(title: 'Ideal Gas Processes', toolId: 901),
    ));
    await tester.pumpAndSettle();

    await _fill(tester, 'Initial pressure, p₁', '100');
    await _fill(tester, 'Initial temperature, T₁', '26.85'); // 300 K
    await _fill(tester, 'Final pressure, p₂', '800');
    await _calculate(tester);

    expect(find.byType(IdealGasResultPage), findsOneWidget);
    // State 2: 300 K × 8^((k−1)/k) with k = 1.005/0.718 = 1.3997, so
    // 543.3 K = 270.1 °C — and no heat, the process being isentropic.
    expect(_valuesFor(tester, 'Temperature, T')[1], startsWith('270.1'));
    expect(_valueFor(tester, 'Heat transfer, Q'), startsWith('0'));
    expect(find.byType(LinePlotCard), findsOneWidget);
  });

  testWidgets('Otto cycle reports the textbook efficiency', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const AirCyclePage(title: 'Otto, Diesel & Brayton Cycles', toolId: 902),
    ));
    await tester.pumpAndSettle();

    await _fill(tester, 'Inlet temperature, T₁', '16.85'); // 290 K
    await _fill(tester, 'Inlet pressure, p₁', '95');
    await _fill(tester, 'Compression ratio, r', '8');
    await _fill(tester, 'Heat added, q_in', '750');
    await _calculate(tester);

    expect(find.byType(AirCycleResultPage), findsOneWidget);
    // 1 − 8^-0.4 = 56.47 %.
    expect(_valueFor(tester, 'Thermal efficiency, η (%)'), startsWith('56.4'));
    // A state table and both diagrams.
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.byType(LinePlotCard), findsNWidgets(2));
  });

  testWidgets('Brayton swaps in its own inputs', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const AirCyclePage(title: 'Otto, Diesel & Brayton Cycles', toolId: 902),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Brayton'));
    await tester.pumpAndSettle();

    expect(find.text('Pressure ratio, rp'), findsOneWidget);
    expect(find.text('Compression ratio, r'), findsNothing);
    expect(find.text('Turbine efficiency, ηt (%)'), findsOneWidget);

    await _fill(tester, 'Inlet temperature, T₁', '26.85');
    await _fill(tester, 'Inlet pressure, p₁', '100');
    await _fill(tester, 'Pressure ratio, rp', '8');
    await _fill(tester, 'Turbine inlet temperature, T₃', '1026.85');
    await _calculate(tester);

    // 1 − 8^(-0.4/1.4) = 44.79 %.
    expect(_valueFor(tester, 'Thermal efficiency, η (%)'), startsWith('44.7'));
    expect(_valueFor(tester, 'Back work ratio (%)'), isNotEmpty);
  });

  testWidgets('Rankine cycle works the textbook example', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const RankinePage(title: 'Rankine Cycle', toolId: 903),
    ));
    await tester.pumpAndSettle();

    await _fill(tester, 'Boiler pressure', '3000');
    await _fill(tester, 'Condenser pressure', '75');
    await _fill(tester, 'Turbine inlet temperature (optional)', '350');
    await _calculate(tester);

    expect(find.byType(RankineResultPage), findsOneWidget);
    expect(_valueFor(tester, 'Thermal efficiency, η (%)'), startsWith('26.0'));
    expect(_valueFor(tester, 'Turbine exit quality, x₄'), startsWith('0.88'));
    expect(find.byType(DataTable), findsOneWidget);
  });

  testWidgets('Rankine warns about a wet turbine exhaust', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const RankinePage(title: 'Rankine Cycle', toolId: 903),
    ));
    await tester.pumpAndSettle();

    // Saturated steam into the turbine, which is the case superheat exists
    // to avoid.
    await _fill(tester, 'Boiler pressure', '8000');
    await _fill(tester, 'Condenser pressure', '10');
    await _calculate(tester);

    expect(find.textContaining('below 88 % quality'), findsOneWidget);
  });

  testWidgets('Rankine refuses an inlet below saturation, and says why',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(
      const RankinePage(title: 'Rankine Cycle', toolId: 903),
    ));
    await tester.pumpAndSettle();

    await _fill(tester, 'Boiler pressure', '3000');
    await _fill(tester, 'Condenser pressure', '75');
    await _fill(tester, 'Turbine inlet temperature (optional)', '200');
    await _calculate(tester);

    expect(find.byType(RankineResultPage), findsNothing);
    // The message names the boiler's saturation temperature, 233.85 °C.
    expect(find.textContaining('233.8'), findsOneWidget);
  });
}
