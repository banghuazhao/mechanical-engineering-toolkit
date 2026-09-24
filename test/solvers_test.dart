import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/solve/root_finder.dart';
import 'package:mechanical_engineering_toolkit/solve/solve_for_card.dart';
import 'package:mechanical_engineering_toolkit/solve/solvers.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A realistic calculation for every solvable tool, written in the exact
/// form its input page records — so these double as a check that each
/// solver reads the keys its page writes.
const _samples = <int, Map<String, String>>{
  100: {'F': '1000.0', 'A': '50.0'},
  101: {'F': '1000.0', 'L': '500.0', 'E': '200.0', 'A': '50.0'},
  103: {'T': '50000.0', 'r': '10.0', 'Ip': '15708.0'},
  104: {'M': '1000000.0', 'y': '50.0', 'I': '8330000.0'},
  111: {
    'E': '200.0',
    'I': '1000000.0',
    'L': '2000.0',
    'End Condition': 'Pinned-pinned column',
  },
  114: {'T': '50000.0', 'L': '1000.0', 'G': '80.0', 'J': '98175.0'},
  115: {'Mode': 'torque', 'P': '10.0', 'T': '', 'n': '1500.0'},
  119: {'σa': '100.0', 'σm': '80.0', 'Su': '600.0', 'Se': '250.0'},
  122: {
    'section': 'rectangle',
    'loading': 'hook',
    'ri': '50.0',
    'h': '100.0',
    'b': '20.0',
    'N': '10000.0',
  },
  701: {
    'd': '3.0',
    'D': '24.0',
    'Na': '10.0',
    'G': '79.0',
    'F': '100.0',
    'rho': '',
  },
  702: {
    'm': '3.0',
    'N1': '20',
    'N2': '60',
    'F': '30.0',
    'Wt': '2000.0',
    'Cp': '191.0',
  },
  703: {
    'Ma': '70000.0',
    'Mm': '0.0',
    'Ta': '0.0',
    'Tm': '45000.0',
    'Kf': '1.6',
    'Kfs': '1.3',
    'Se': '200.0',
    'Sut': '700.0',
    'n': '2.0',
  },
  704: {'Type': 'ball', 'C': '30.0', 'P': '5.0', 'n': '1500.0'},
  705: {'d1': '100.0', 'd2': '200.0', 'C': '500.0', 'n1': '1450.0', 'P': '5.0'},
  706: {'F': '20000.0', 'd': '12.0', 'K': '0.2'},
  707: {'w': '6.0', 'L': '100.0', 'F': '20000.0', 'allow': '120.0'},
  708: {
    'r': '25.0',
    'ro': '50.0',
    'delta': '0.04',
    'E': '200.0',
    'nu': '0.3',
  },
  709: {
    'Support': 'simplySupported',
    'E': '200.0',
    'd': '40.0',
    'L': '1.0',
    'm': '20.0',
    'a': '0.5',
    'ShaftMass': 'on',
    'rho': '7850.0',
  },
  710: {
    'End Condition': 'simplySupported',
    'E': '200.0',
    'I': '8330000.0',
    'A': '5000.0',
    'L': '3.0',
    'rho': '7850.0',
  },
  711: {
    'System': 'singleRotor',
    'G': '80.0',
    'd': '40.0',
    'L': '1.0',
    'J1': '0.5',
  },
  712: {
    'd': '32.0',
    'p': '4.0',
    'F': '6400.0',
    'starts': '1',
    'form': 'square',
    'mu': '0.08',
    'muc': '0.08',
    'dc': '40.0',
  },
  800: {'D': '50.0', 'V': '2.0', 'rho': '998.0', 'mu': '0.001'},
  801: {
    'D': '50.0',
    'L': '100.0',
    'Q': '5.0',
    'rho': '998.0',
    'mu': '0.001',
    'eps': '0.045',
    'K': '2.0',
  },
  802: {'Q': '10.0', 'dp': '300.0', 'rho': '998.0', 'eta': '70.0'},
  811: {
    'L': '50.0',
    't': '2.0',
    'w': '100.0',
    'k': '200.0',
    'h': '25.0',
    'Tb': '100.0',
    'Tinf': '25.0',
  },
  812: {
    'Flow': 'counter',
    'Thi': '150.0',
    'Tho': '90.0',
    'Tci': '30.0',
    'Tco': '70.0',
    'U': '500.0',
    'Q': '100000.0',
  },
  902: {
    'airCycle': 'otto',
    'T1': '27.0',
    'p1': '100.0',
    'cp': '1.005',
    'k': '1.4',
    'given': 'qin',
    'r': '8.0',
    'qin': '800.0',
  },
  903: {
    'pb': '8000.0',
    'pc': '10.0',
    'T3': '480.0',
    'etaT': '85.0',
    'etaP': '80.0',
    'm': '100.0',
  },
};

Widget _app(Widget home, ToolHistory history) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider.value(value: history),
        ChangeNotifierProvider(create: (_) => SavedProjects()),
        ChangeNotifierProvider(create: (_) => MaterialLibrary()),
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
        home: home,
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  test('every solver has a sample calculation here', () {
    expect(_samples.keys.toSet(), toolSolvers.keys.toSet());
  });

  group('each solver runs its tool backwards', () {
    for (final MapEntry(key: id, value: sample) in _samples.entries) {
      test('tool $id', () {
        final solver = toolSolvers[id]!;
        final base = solver.evaluate(sample);
        final outputs =
            solver.outputs(sample).where((q) => base.containsKey(q.key));
        expect(outputs, isNotEmpty, reason: 'tool $id produces no outputs');
        final inputs = solver
            .inputs(sample)
            .where((q) => double.tryParse(sample[q.key] ?? '') != null)
            .toList();
        expect(inputs, isNotEmpty, reason: 'tool $id offers nothing to vary');

        var checked = 0;
        for (final input in inputs) {
          final start = double.parse(sample[input.key]!);
          // Somewhere the formula is defined, a little way off the start.
          final moved = start == 0 ? 1.0 : start * 1.15;
          for (final output in outputs) {
            double f(double x) {
              final value =
                  solver.evaluate({...sample, input.key: '$x'})[output.key];
              if (value == null) throw StateError('undefined');
              return value;
            }

            double target;
            try {
              target = f(moved);
            } catch (_) {
              continue;
            }
            final outcome = solveForInput(
              evaluate: f,
              target: target,
              start: start,
              positive: input.positive,
            );
            expect(outcome.found, isTrue,
                reason: 'tool $id: ${input.key} → ${output.key}');
            expect(
              f(outcome.value!),
              closeTo(target, 1e-6 * (target.abs() + 1e-12)),
              reason: 'tool $id: ${input.key} → ${output.key}',
            );
            checked++;
          }
        }
        expect(checked, greaterThan(0), reason: 'tool $id');
      });
    }
  });

  group('each solver reads the keys its page records', () {
    for (final MapEntry(key: id, value: sample) in _samples.entries) {
      testWidgets('tool $id', (tester) async {
        final history = ToolHistory();
        late BuildContext host;
        await tester.pumpWidget(_app(
          Builder(builder: (context) {
            host = context;
            return const Scaffold();
          }),
          history,
        ));
        final tool = ToolLibrary.shared.item(id, host);
        tool.action(host, tool.title, tool.id, initialInputs: sample);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('calculateButton')));
        await tester.pumpAndSettle();

        final recorded = history.entries.first;
        expect(recorded.toolId, id);
        final solver = toolSolvers[id]!;
        for (final input in solver.inputs(sample)) {
          final expected = double.tryParse(sample[input.key] ?? '');
          if (expected == null) continue;
          expect(double.tryParse(recorded.inputs?[input.key] ?? ''), expected,
              reason: 'tool $id records ${input.key} differently');
        }

        // And the result page carries the card.
        // The result page's own list: formulas and charts nest horizontal
        // scrollables of their own.
        final resultList = find.byWidgetPredicate((widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down);
        await tester.scrollUntilVisible(find.byType(SolveForCard), 300,
            scrollable: resultList.last);
        expect(find.byKey(const Key('solveButton')), findsOneWidget);
      });
    }
  });

  testWidgets('solves, then reopens the tool with the answer filled in',
      (tester) async {
    final history = ToolHistory();
    late BuildContext host;
    await tester.pumpWidget(_app(
      Builder(builder: (context) {
        host = context;
        return const Scaffold();
      }),
      history,
    ));
    final tool = ToolLibrary.shared.item(100, host);
    // σ = F/A = 1000/50 = 20 MPa. Which area gives 40 MPa?
    tool.action(host, tool.title, tool.id, initialInputs: _samples[100]);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pumpAndSettle();

    final card = find.byType(SolveForCard);
    await tester.scrollUntilVisible(card, 300,
        scrollable: find
            .byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down)
            .last);
    final target = find.descendant(of: card, matching: find.byType(TextField));
    await tester.enterText(target.first, '40');
    await tester.tap(find.byKey(const Key('solveButton')));
    await tester.pumpAndSettle();
    final shown = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('solvedValue')),
            matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .join(' ');
    expect(shown, contains('mm²'));
    expect(double.parse(RegExp(r'[\d.]+(?= mm²)').firstMatch(shown)![0]!),
        closeTo(25, 1e-6));

    await tester.ensureVisible(find.byKey(const Key('applySolvedValue')));
    await tester.tap(find.byKey(const Key('applySolvedValue')));
    await tester.pumpAndSettle();

    // Back on a fresh input page, with the area in its field.
    expect(find.byType(SolveForCard), findsNothing);
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pumpAndSettle();
    expect(
        double.parse(history.entries.first.inputs!['A']!), closeTo(25, 1e-9));
    expect(history.entries.first.inputs!['F'], '1000.0');
  });

  testWidgets('says what is reachable when nothing is', (tester) async {
    final history = ToolHistory();
    late BuildContext host;
    await tester.pumpWidget(_app(
      Builder(builder: (context) {
        host = context;
        return const Scaffold();
      }),
      history,
    ));
    final tool = ToolLibrary.shared.item(119, host);
    tool.action(host, tool.title, tool.id, initialInputs: _samples[119]);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calculateButton')));
    await tester.pumpAndSettle();
    final card = find.byType(SolveForCard);
    await tester.scrollUntilVisible(card, 300,
        scrollable: find
            .byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down)
            .last);
    // A safety factor of 50 is out of reach by changing σa alone: even at
    // σa → 0 it tops out at Su/σm = 7.5.
    await tester.enterText(
        find.descendant(of: card, matching: find.byType(TextField)).first,
        '50');
    await tester.tap(find.byKey(const Key('solveButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('solveNoSolution')), findsOneWidget);
  });
}
