import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content_zh.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_localizations.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_sheet.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => ToolHistory()),
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('content', () {
    test('every entry has a summary, a formula and a reference', () {
      expect(toolHelp, isNotEmpty);
      toolHelp.forEach((id, help) {
        expect(help.summary.trim(), isNotEmpty, reason: 'tool $id summary');
        // A tool page already carries a one-line description; this is the
        // long form, so it has to say more than that one line did.
        expect(help.summary.length, greaterThan(120), reason: 'tool $id');
        expect(help.references, isNotEmpty, reason: 'tool $id references');
      });
    });

    test('every formula carries both a TeX and a plain rendering', () {
      toolHelp.forEach((id, help) {
        for (final formula in help.formulas) {
          expect(formula.tex.trim(), isNotEmpty, reason: 'tool $id tex');
          // The copy and share actions send the plain form: raw TeX pasted
          // into an email is unreadable.
          expect(formula.plain.trim(), isNotEmpty, reason: 'tool $id plain');
          expect(formula.plain, isNot(contains(r'\frac')),
              reason: 'tool $id leaked TeX into the plain form');
        }
      });
    });

    test('every symbol that carries a unit names a real one', () {
      toolHelp.forEach((id, help) {
        for (final symbol in help.symbols) {
          expect(symbol.symbol.trim(), isNotEmpty, reason: 'tool $id');
          expect(symbol.meaning.trim(), isNotEmpty, reason: 'tool $id');
          expect(symbol.unit?.trim(), isNot(''), reason: 'tool $id blank unit');
        }
      });
    });

    testWidgets('every tool in the library has an explanation', (tester) async {
      await tester.pumpWidget(_wrap(const Scaffold()));
      await tester.pumpAndSettle();
      final tools = ToolLibrary.shared
          .getTools(tester.element(find.byType(Scaffold)));

      final missing = [
        for (final tool in tools)
          if (!toolHelp.containsKey(tool.id)) '${tool.id} ${tool.title}',
      ];
      // The "?" hides itself where there is no entry, so a gap would be
      // invisible in the app. This is what makes it visible.
      expect(missing, isEmpty);
    });

    testWidgets('every entry belongs to a tool that exists', (tester) async {
      await tester.pumpWidget(_wrap(const Scaffold()));
      await tester.pumpAndSettle();
      final ids = ToolLibrary.shared
          .getTools(tester.element(find.byType(Scaffold)))
          .map((tool) => tool.id)
          .toSet();

      for (final id in toolHelp.keys) {
        expect(ids, contains(id), reason: 'help for tool $id, which is gone');
      }
    });
  });

  group('translations', () {
    test('every translated entry belongs to a documented tool', () {
      localizedToolHelp.forEach((tag, byTool) {
        for (final id in byTool.keys) {
          expect(toolHelp, contains(id),
              reason: '$tag has help for tool $id, which English does not');
        }
      });
    });

    test('every translated entry is filled in like the English one', () {
      localizedToolHelp.forEach((tag, byTool) {
        byTool.forEach((id, help) {
          final english = toolHelp[id]!;
          expect(help.summary.trim(), isNotEmpty, reason: '$tag/$id');
          // The equations are notation, not prose: a translation that dropped
          // or added one would no longer describe the same calculation.
          expect(help.formulas.length, english.formulas.length,
              reason: '$tag/$id formula count');
          expect(help.symbols.length, english.symbols.length,
              reason: '$tag/$id symbol count');
          for (var i = 0; i < help.formulas.length; i++) {
            expect(help.formulas[i].tex, english.formulas[i].tex,
                reason: '$tag/$id formula $i was altered');
          }
          for (var i = 0; i < help.symbols.length; i++) {
            expect(help.symbols[i].symbol, english.symbols[i].symbol,
                reason: '$tag/$id symbol $i glyph was altered');
            // Unit *symbols* are international and must survive translation
            // untouched — mm is mm everywhere. The one unit written as a word
            // rather than a symbol is prose, and does get translated.
            if (english.symbols[i].unit != 'million rev') {
              expect(help.symbols[i].unit, english.symbols[i].unit,
                  reason: '$tag/$id symbol $i unit was altered');
            }
          }
          // Citations stay in the language the book was published in.
          expect(help.references, english.references, reason: '$tag/$id refs');
          expect(help.diagram, english.diagram, reason: '$tag/$id diagram');
        });
      });
    });

    test('a fully translated language covers every tool', () {
      // Partial languages are allowed — helpFor falls back per tool — but a
      // language that claims to be done should not be quietly missing one.
      for (final tag in ['ja', 'zh']) {
        expect(localizedToolHelp[tag]!.keys.toSet(), toolHelp.keys.toSet(),
            reason: '$tag is incomplete');
      }
    });

    test('resolves the reader language, and falls back sensibly', () {
      const id = 100;
      expect(helpFor(id, const Locale('zh')), toolHelpZh[id]);
      // Traditional has no text of its own yet, so it takes Simplified rather
      // than English.
      expect(helpFor(id, const Locale('zh', 'HK')), toolHelpZh[id]);
      // An untranslated language falls back to English.
      expect(helpFor(id, const Locale('de')), toolHelp[id]);
      expect(helpFor(-1, const Locale('zh')), isNull);
    });

    test('tags Chinese by script rather than by language', () {
      expect(helpLocaleTag(const Locale('zh')), 'zh');
      expect(helpLocaleTag(const Locale('zh', 'HK')), 'zh_HK');
      expect(helpLocaleTag(const Locale('ja')), 'ja');
    });
  });

  group('plain text', () {
    test('carries every section, and no TeX', () {
      const help = ToolHelp(
        summary: 'A summary long enough to be worth reading.',
        formulas: [
          HelpFormula(
              tex: r'\sigma = \frac{P}{A}',
              plain: 'σ = P / A',
              caption: 'Normal stress'),
        ],
        symbols: [
          HelpSymbol('σ', 'Normal stress', 'MPa'),
          HelpSymbol('n', 'Factor of safety'),
        ],
        notes: ['Elastic only.'],
        references: ['Hibbeler, Mechanics of Materials'],
      );

      final text = toolHelpAsText(help, 'Axial Stress');

      expect(text, startsWith('Axial Stress'));
      expect(text, contains('Normal stress: σ = P / A'));
      expect(text, contains('σ — Normal stress (MPa)'));
      // A dimensionless symbol gets no empty parentheses after it.
      expect(text, contains('n — Factor of safety\n'));
      expect(text, contains('- Elastic only.'));
      expect(text, contains('Hibbeler'));
      expect(text, isNot(contains(r'\frac')));
    });
  });

  group('the sheet', () {
    /// A tool that has an entry, so the button is shown.
    final documented = toolHelp.keys.first;

    testWidgets('the button opens the sheet and shows the explanation',
        (tester) async {
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: AppBar(
          actions: [
            ToolHelpButton(toolId: documented, toolTitle: 'Axial Stress'),
          ],
        ),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('toolHelp')));
      await tester.pumpAndSettle();

      expect(find.byType(ToolHelpView), findsOneWidget);
      expect(find.text('Axial Stress'), findsOneWidget);
      expect(find.textContaining(toolHelp[documented]!.summary.substring(0, 30)),
          findsOneWidget);
    });

    testWidgets('every entry\'s TeX actually parses', (tester) async {
      // The sheet falls back to the plain form when TeX will not parse, so a
      // typo degrades silently rather than throwing. This is what notices.
      for (final id in toolHelp.keys) {
        await tester.pumpWidget(_wrap(Scaffold(
          body: ToolHelpView(toolId: id, toolTitle: 'T'),
        )));
        await tester.pumpAndSettle();
        for (final formula in toolHelp[id]!.formulas) {
          expect(find.text(formula.plain), findsNothing,
              reason: 'tool $id fell back on: ${formula.tex}');
        }
      }
    });

    testWidgets('every sheet lays out on a small phone without overflowing',
        (tester) async {
      // 360x640 is about the smallest screen still in use. A RenderFlex
      // overflow is reported as a test exception, so this catches a long
      // symbol row or a wide equation escaping its card.
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final id in toolHelp.keys) {
        await tester.pumpWidget(_wrap(Scaffold(
          body: ToolHelpView(toolId: id, toolTitle: 'A Fairly Long Tool Name'),
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tool $id');

        // And scrolled to the end, where the references sit.
        await tester.drag(find.byType(ListView), const Offset(0, -4000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'tool $id, scrolled');
      }
    });

    testWidgets('a tool with no entry shows no button at all', (tester) async {
      await tester.pumpWidget(_wrap(Scaffold(
        appBar: AppBar(
          actions: const [
            ToolHelpButton(toolId: -1, toolTitle: 'Nothing'),
          ],
        ),
      )));
      await tester.pumpAndSettle();

      // Better than a button that opens an empty sheet.
      expect(find.byKey(const Key('toolHelp')), findsNothing);
    });

    testWidgets('copy puts the plain-text explanation on the clipboard',
        (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = call.arguments['text'] as String;
          }
          return null;
        },
      );

      await tester.pumpWidget(_wrap(Scaffold(
        body: ToolHelpView(toolId: documented, toolTitle: 'Axial Stress'),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('copyToolHelp')));
      await tester.pumpAndSettle();

      expect(copied, isNotNull);
      expect(copied, startsWith('Axial Stress'));
      expect(copied, contains('References'));
      expect(copied, isNot(contains(r'\frac')));

      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
  });
}
