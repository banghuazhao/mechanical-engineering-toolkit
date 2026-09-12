import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_menu_bar.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider(create: (_) => SavedProjects()),
        ChangeNotifierProvider(create: (_) => ToolHistory()),
        ChangeNotifierProvider(create: (_) => MaterialLibrary()),
        ChangeNotifierProvider(create: (_) => LanguagePreference()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        navigatorObservers: [AppCommands.instance.routeObserver],
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

/// A stand-in calculator: a Calculate button that shows a result.
class _FakeToolPage extends StatelessWidget {
  const _FakeToolPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fake Tool')),
      floatingActionButton: CalculateButton(
        onPressed: () => showToolResult(
          context,
          (context) => const ResultScaffold(
            toolName: 'Fake Tool',
            results: [
              ResultSection(
                title: 'Fake Tool',
                values: [ResultValue(label: 'Answer', value: '42')],
              ),
            ],
          ),
        ),
      ),
      body: const Center(child: Text('inputs')),
    );
  }
}

Future<void> _openTool(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              ToolPageRoute(builder: (context) => const _FakeToolPage()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  tearDown(AppPlatform.clearOverride);

  group('results beside the inputs', () {
    testWidgets('a narrow window pushes the result over the inputs',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _openTool(tester);
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pumpAndSettle();

      expect(find.text('Answer'), findsOneWidget);
      // The inputs are behind the result page, not beside it.
      expect(find.text('inputs'), findsNothing);
      expect(find.byKey(const Key('closeResultPane')), findsNothing);
    });

    testWidgets('a wide window shows the result beside the inputs',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _openTool(tester);
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pumpAndSettle();

      expect(find.text('Answer'), findsOneWidget);
      expect(find.text('inputs'), findsOneWidget);

      // The pane closes without closing the tool.
      await tester.tap(find.byKey(const Key('closeResultPane')));
      await tester.pumpAndSettle();
      expect(find.text('Answer'), findsNothing);
      expect(find.text('inputs'), findsOneWidget);
    });

    testWidgets('the pane keeps what was typed into the inputs',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  ToolPageRoute(builder: (context) => const _TypingToolPage()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '12.5');
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pumpAndSettle();

      // Laying the page out in two columns moves it in the widget tree; the
      // value has to survive that.
      expect(find.text('12.5'), findsOneWidget);
      expect(find.text('Answer'), findsOneWidget);
    });
  });

  group('app commands', () {
    testWidgets('⌘↩ reaches the Calculate button of the open tool',
        (tester) async {
      await _openTool(tester);

      expect(AppCommands.instance.canInvoke(AppCommand.calculate), isTrue);
      AppCommands.instance.invoke(AppCommand.calculate);
      await tester.pumpAndSettle();
      expect(find.text('Answer'), findsOneWidget);
    });

    testWidgets('a result page answers share and save', (tester) async {
      await _openTool(tester);
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pumpAndSettle();

      expect(AppCommands.instance.canInvoke(AppCommand.share), isTrue);
      expect(AppCommands.instance.canInvoke(AppCommand.saveToProject), isTrue);

      AppCommands.instance.invoke(AppCommand.share);
      await tester.pumpAndSettle();
      // The share picker is the sheet that opens.
      expect(find.byKey(const Key('shareFormatText')), findsOneWidget);
    });

    testWidgets('a command goes quiet once its page is covered',
        (tester) async {
      await _openTool(tester);
      expect(AppCommands.instance.canInvoke(AppCommand.calculate), isTrue);

      _navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (context) => const Scaffold()),
      );
      await tester.pumpAndSettle();
      expect(AppCommands.instance.canInvoke(AppCommand.calculate), isFalse);

      _navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(AppCommands.instance.canInvoke(AppCommand.calculate), isTrue);
    });

    testWidgets('nothing is registered once the tool closes', (tester) async {
      await _openTool(tester);
      expect(AppCommands.instance.canInvoke(AppCommand.calculate), isTrue);

      _navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(AppCommands.instance.canInvoke(AppCommand.calculate), isFalse);
    });
  });

  group('the Mac menu bar', () {
    /// Every leaf item in the tree, flattened.
    List<PlatformMenuItem> leaves(List<PlatformMenuItem> menus) => [
          for (final item in menus)
            if (item is PlatformMenu)
              ...leaves(item.menus)
            else if (item is PlatformMenuItemGroup)
              ...leaves(item.members)
            else
              item,
        ];

    // The menus as built into the tree, rather than rebuilt from outside it.
    List<PlatformMenuItem> menusOf(WidgetTester tester) =>
        tester.widget<PlatformMenuBar>(find.byType(PlatformMenuBar)).menus;

    testWidgets('names the menus a Mac app has, and no others',
        (tester) async {
      AppPlatform.overrideWith(AppPlatform.macOS);
      await tester.pumpWidget(_wrap(
        AppMenuBar(navigatorKey: _navigatorKey, child: const Scaffold()),
      ));
      await tester.pumpAndSettle();

      final titles = [
        for (final menu in menusOf(tester))
          if (menu is PlatformMenu) menu.label,
      ];
      expect(titles, [
        'ME Toolkit',
        'File',
        'Edit',
        'View',
        'Go',
        'Window',
        'Help',
      ]);
    });

    testWidgets('greys out the tool commands until a tool is open',
        (tester) async {
      AppPlatform.overrideWith(AppPlatform.macOS);
      await tester.pumpWidget(_wrap(
        AppMenuBar(navigatorKey: _navigatorKey, child: const Scaffold()),
      ));
      await tester.pumpAndSettle();

      PlatformMenuItem item(String label) => leaves(menusOf(tester))
          .whereType<PlatformMenuItem>()
          .firstWhere((i) => i.label == label);

      expect(item('Calculate').onSelected, isNull);
      expect(item('Save to Project…').onSelected, isNull);
      // App-level items are always available.
      expect(item('Settings…').onSelected, isNotNull);
      expect(item('Find Tool…').onSelected, isNotNull);
    });

    testWidgets('offers Calculate once a calculator is on screen',
        (tester) async {
      AppPlatform.overrideWith(AppPlatform.macOS);
      await tester.pumpWidget(_wrap(
        AppMenuBar(
          navigatorKey: _navigatorKey,
          child: const _FakeToolPage(),
        ),
      ));
      await tester.pumpAndSettle();

      final calculate = leaves(menusOf(tester))
          .whereType<PlatformMenuItem>()
          .firstWhere((i) => i.label == 'Calculate');
      expect(calculate.onSelected, isNotNull);
      calculate.onSelected!();
      await tester.pumpAndSettle();
      expect(find.text('Answer'), findsOneWidget);
    });

    testWidgets('renders nothing of its own off macOS', (tester) async {
      await tester.pumpWidget(_wrap(
        AppMenuBar(navigatorKey: _navigatorKey, child: const Scaffold()),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(PlatformMenuBar), findsNothing);
    });
  });

  group('the library sidebar', () {
    testWidgets('a wide window trades the drawer for a sidebar',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const ToolPage()));
      await tester.pumpAndSettle();

      expect(find.text('All tools'), findsOneWidget);
      expect(tester.widget<Scaffold>(find.byType(Scaffold).first).drawer,
          isNull);

      // Every category is listed, and picking one narrows the library.
      expect(find.text('Thermodynamics'), findsWidgets);
      await tester.tap(find.text('Thermodynamics').first);
      await tester.pumpAndSettle();
      expect(find.text('Rankine Cycle'), findsOneWidget);
      expect(find.text('Unit Converter'), findsNothing);
    });

    testWidgets('a narrow window keeps the drawer', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(const ToolPage()));
      await tester.pumpAndSettle();

      expect(find.text('All tools'), findsNothing);
      expect(tester.widget<Scaffold>(find.byType(Scaffold).first).drawer,
          isNotNull);
    });
  });
}

/// A calculator with something typed into it, for the state-preservation test.
class _TypingToolPage extends StatelessWidget {
  const _TypingToolPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typing Tool')),
      floatingActionButton: CalculateButton(
        onPressed: () => showToolResult(
          context,
          (context) => const ResultScaffold(
            toolName: 'Typing Tool',
            results: [
              ResultSection(
                title: 'Typing Tool',
                values: [ResultValue(label: 'Answer', value: '42')],
              ),
            ],
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: TextField(),
      ),
    );
  }
}
