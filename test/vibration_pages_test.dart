import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/beam_natural_frequency_page.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/beam_natural_frequency_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/shaft_critical_speed_page.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/shaft_critical_speed_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/torsional_frequency_page.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/torsional_frequency_result_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
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

/// Types [value] into the field labelled [label], which is how a user reaches
/// a [UnitField] — the label is the only handle the widget exposes.
Future<void> _fill(WidgetTester tester, String label, String value) async {
  await tester.enterText(
    find.ancestor(
      of: find.text(label),
      matching: find.byType(TextField),
    ),
    value,
  );
  await tester.pump();
}

Future<void> _calculate(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

/// The tall input pages overflow a default 600px test viewport, and an
/// off-screen field cannot be typed into.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  testWidgets('beam natural frequency: inputs reach a result page',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(const BeamNaturalFrequencyPage(
      title: 'Beam Natural Frequency',
      toolId: 710,
    )));
    await tester.pumpAndSettle();

    await _fill(tester, 'Elastic modulus, E', '200');
    await _fill(tester, 'Second moment, I', '10000000');
    await _fill(tester, 'Area, A', '10000');
    await _fill(tester, 'Beam length, L', '5');
    await _fill(tester, 'Density', '7850');
    await _calculate(tester);

    expect(find.byType(BeamNaturalFrequencyResultPage), findsOneWidget);
    // All three modes are listed, and the fundamental is the hand-checked
    // 10.03 Hz for this beam.
    expect(find.text('Mode 1'), findsWidgets);
    expect(find.text('Mode 3'), findsOneWidget);
    expect(find.textContaining('10.029'), findsWidgets);
  });

  testWidgets('beam natural frequency: an empty form is refused',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(const BeamNaturalFrequencyPage(
      title: 'Beam Natural Frequency',
      toolId: 710,
    )));
    await tester.pumpAndSettle();

    await _calculate(tester);

    expect(find.byType(BeamNaturalFrequencyResultPage), findsNothing);
    expect(find.text('Enter E, I, A, the length, and the density.'),
        findsOneWidget);
  });

  testWidgets('shaft critical speed: inputs reach a result page',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(const ShaftCriticalSpeedPage(
      title: 'Shaft Critical Speed',
      toolId: 709,
    )));
    await tester.pumpAndSettle();

    // The shaft's own mass is asked for by default, so its density field is
    // on screen and required.
    expect(find.text('Density'), findsOneWidget);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Density'), findsNothing);

    await _fill(tester, 'Elastic modulus, E', '200');
    await _fill(tester, 'Shaft diameter, d', '50');
    await _fill(tester, 'Span, L', '1');
    await _fill(tester, 'Rotor mass, m', '100');
    await _fill(tester, 'Rotor position from left, a', '0.5');
    await _calculate(tester);

    expect(find.byType(ShaftCriticalSpeedResultPage), findsOneWidget);
    expect(find.textContaining('1638.8'), findsWidgets);
  });

  testWidgets('shaft critical speed: a rotor on a support is refused',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(const ShaftCriticalSpeedPage(
      title: 'Shaft Critical Speed',
      toolId: 709,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await _fill(tester, 'Elastic modulus, E', '200');
    await _fill(tester, 'Shaft diameter, d', '50');
    await _fill(tester, 'Span, L', '1');
    await _fill(tester, 'Rotor mass, m', '100');
    await _fill(tester, 'Rotor position from left, a', '1');
    await _calculate(tester);

    expect(find.byType(ShaftCriticalSpeedResultPage), findsNothing);
    expect(
      find.text('The rotor must sit along the shaft, clear of the supports.'),
      findsOneWidget,
    );
  });

  testWidgets('torsional frequency: the second rotor field follows the mode',
      (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(_wrap(const TorsionalFrequencyPage(
      title: 'Torsional Natural Frequency',
      toolId: 711,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Second rotor inertia, J2'), findsNothing);
    await tester.tap(find.text('Two rotors, free shaft'));
    await tester.pumpAndSettle();
    expect(find.text('Second rotor inertia, J2'), findsOneWidget);

    await _fill(tester, 'Shear modulus, G', '80');
    await _fill(tester, 'Shaft diameter, d', '50');
    await _fill(tester, 'Shaft length, L', '1');
    await _fill(tester, 'Rotor inertia, J1', '1');
    await _fill(tester, 'Second rotor inertia, J2', '1');
    await _calculate(tester);

    expect(find.byType(TorsionalFrequencyResultPage), findsOneWidget);
    // Two equal rotors: f = √2 × the single-rotor 35.26 Hz, node at midspan.
    expect(find.textContaining('49.86'), findsWidgets);
    expect(find.text('Node, from rotor 1'), findsOneWidget);
  });
}
