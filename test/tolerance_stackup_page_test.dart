import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/recorded_inputs.dart';
import 'package:mechanical_engineering_toolkit/home/tolerance/page/tolerance_stackup_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/home/tolerance/page/tolerance_stackup_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The stack-up tool's id in the library.
const _toolId = 505;

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => ToolHistory()),
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

/// The page scrolls, and a control below the fold cannot be tapped where it
/// is not laid out — so bring it into view first.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _fillRow(
  WidgetTester tester, {
  required int row,
  required String nominal,
  required String plus,
  required String minus,
}) async {
  final fields = find.byType(UnitField);
  // Three fields per row, in the order they are declared.
  await tester.enterText(fields.at(row * 3), nominal);
  await tester.enterText(fields.at(row * 3 + 1), plus);
  await tester.enterText(fields.at(row * 3 + 2), minus);
  await tester.pump();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  testWidgets('opens with the smallest chain that says anything',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ToleranceStackupPage(title: 'Stack-Up', toolId: _toolId),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(UnitField), findsNWidgets(6)); // two rows of three
    // The last two rows cannot be deleted: a one-dimension stack-up is not a
    // stack-up, so offering the control would only lead to a refusal.
    expect(find.byIcon(Icons.remove_circle_outline_rounded), findsNothing);
  });

  testWidgets('adds and removes dimensions', (tester) async {
    await tester.pumpWidget(_wrap(
      const ToleranceStackupPage(title: 'Stack-Up', toolId: _toolId),
    ));
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const Key('addStackupDimension')));
    expect(find.byType(UnitField), findsNWidgets(9));
    expect(find.byIcon(Icons.remove_circle_outline_rounded), findsNWidgets(3));

    await _tap(tester, find.byIcon(Icons.remove_circle_outline_rounded).first);
    expect(find.byType(UnitField), findsNWidgets(6));
    expect(find.byIcon(Icons.remove_circle_outline_rounded), findsNothing);
  });

  testWidgets('deleting a row takes its own values with it', (tester) async {
    await tester.pumpWidget(_wrap(
      const ToleranceStackupPage(title: 'Stack-Up', toolId: _toolId),
    ));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('addStackupDimension')));

    await _fillRow(tester, row: 0, nominal: '10', plus: '0.1', minus: '0.1');
    await _fillRow(tester, row: 1, nominal: '20', plus: '0.2', minus: '0.2');
    await _fillRow(tester, row: 2, nominal: '30', plus: '0.3', minus: '0.3');

    // Drop the middle row. Rows are keyed by identity, so row 3's text must
    // not slide up into row 2's fields.
    await _tap(tester, find.byIcon(Icons.remove_circle_outline_rounded).at(1));

    expect(find.widgetWithText(UnitField, '20'), findsNothing);
    expect(find.widgetWithText(UnitField, '10'), findsOneWidget);
    expect(find.widgetWithText(UnitField, '30'), findsOneWidget);
  });

  testWidgets('refuses to calculate until every dimension is filled',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ToleranceStackupPage(title: 'Stack-Up', toolId: _toolId),
    ));
    await tester.pumpAndSettle();

    await _fillRow(tester, row: 0, nominal: '10', plus: '0.1', minus: '0.1');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    final strings = S.of(tester.element(find.byType(ToleranceStackupPage)));
    expect(find.text(strings.Err_Stackup_Dimension), findsOneWidget);
    expect(find.byType(ToleranceStackupResultPage), findsNothing);
  });

  testWidgets('calculates and records the chain under one history key',
      (tester) async {
    final history = ToolHistory();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider<ToolHistory>.value(value: history),
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
        home: const ToleranceStackupPage(title: 'Stack-Up', toolId: _toolId),
      ),
    ));
    await tester.pumpAndSettle();

    await _fillRow(tester, row: 0, nominal: '50', plus: '0.1', minus: '0.1');
    await _fillRow(tester, row: 1, nominal: '20', plus: '0.05', minus: '0.05');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(ToleranceStackupResultPage), findsOneWidget);

    // The chain has no fixed length, so it is stored as one JSON value rather
    // than a key per dimension.
    final recorded = history.entries.first.inputs!;
    expect(recorded.keys, [stackupChainKey]);
    final chain = jsonDecode(recorded[stackupChainKey]!) as List;
    expect(chain, hasLength(2));
    expect((chain.first as Map)['nominal'], 50);
    expect((chain.last as Map)['plus'], 0.05);
  });

  testWidgets('restores a saved chain of any length', (tester) async {
    final chain = jsonEncode([
      {'label': 'bore', 'nominal': 50.0, 'plus': 0.1, 'minus': 0.1,
       'subtracts': false},
      {'label': 'shaft', 'nominal': 20.0, 'plus': 0.05, 'minus': 0.05,
       'subtracts': true},
      {'label': 'shim', 'nominal': 29.0, 'plus': 0.02, 'minus': 0.02,
       'subtracts': true},
    ]);

    await tester.pumpWidget(_wrap(ToleranceStackupPage(
      title: 'Stack-Up',
      toolId: _toolId,
      initialInputs: {stackupChainKey: chain},
    )));
    await tester.pumpAndSettle();

    expect(find.byType(UnitField), findsNWidgets(9));
    expect(find.widgetWithText(TextField, 'bore'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'shim'), findsOneWidget);
  });

  testWidgets('falls back to a blank chain when the saved value is unusable',
      (tester) async {
    await tester.pumpWidget(_wrap(const ToleranceStackupPage(
      title: 'Stack-Up',
      toolId: _toolId,
      initialInputs: {stackupChainKey: 'not json'},
    )));
    await tester.pumpAndSettle();

    // Degrades to an empty tool rather than throwing on open.
    expect(find.byType(UnitField), findsNWidgets(6));
  });

  group('describeStackupChain', () {
    test('writes the chain the way a drawing writes it', () {
      final chain = jsonEncode([
        {'label': 'bore', 'nominal': 25.0, 'plus': 0.1, 'minus': 0.05,
         'subtracts': false},
        {'label': '', 'nominal': 12.0, 'plus': 0.02, 'minus': 0.02,
         'subtracts': true},
      ]);

      // Trailing zeros trimmed, a symmetric band written as ±, and the
      // direction carried by the sign — the raw JSON reaches no reader.
      expect(describeStackupChain(chain), 'bore 25 +0.1/−0.05, −12 ±0.02');
    });

    test('is null for a value that is not a chain', () {
      expect(describeStackupChain('not json'), isNull);
      expect(describeStackupChain('{}'), isNull);
      expect(describeStackupChain('[]'), isNull);
      // A row with no size describes nothing, so it is skipped.
      expect(describeStackupChain(jsonEncode([{'plus': 0.1}])), isNull);
    });
  });

  testWidgets('a recorded chain reads as dimensions, not as JSON',
      (tester) async {
    final chain = jsonEncode([
      {'label': '', 'nominal': 25.0, 'plus': 0.05, 'minus': 0.05,
       'subtracts': false},
    ]);
    late String summary;
    await tester.pumpWidget(_wrap(Builder(builder: (context) {
      summary = describeInputs(context, {stackupChainKey: chain});
      return const SizedBox.shrink();
    })));
    await tester.pumpAndSettle();

    // Keyed by the tool's own label for the chain, not by the storage key,
    // and carrying the dimensions rather than the JSON they are stored as.
    expect(summary, 'Dimension chain: 25 ±0.05');
  });

  testWidgets('inputs a tool records normally are passed through untouched',
      (tester) async {
    late Map<String, String> shown;
    await tester.pumpWidget(_wrap(Builder(builder: (context) {
      shown = displayInputs(context, {'Torque, T': '120'});
      return const SizedBox.shrink();
    })));
    await tester.pumpAndSettle();

    expect(shown, {'Torque, T': '120'});
  });
}
