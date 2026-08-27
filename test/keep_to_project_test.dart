import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/keep_to_project.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sections = [
  ResultSection(
    title: 'Bearing L10 Life',
    values: [
      ResultValue(label: 'L10, million rev', valueSI: 1000),
      ResultValue(label: 'Solid height', valueSI: 24,
          category: UnitCategory.length),
    ],
  ),
];

Widget _wrap(Widget child, SavedProjects projects, ToolHistory history) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider<SavedProjects>.value(value: projects),
        ChangeNotifierProvider<ToolHistory>.value(value: history),
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

/// A result page named after a real tool, so the title lookup resolves the
/// same way it does in the app.
Widget _resultPage(String toolName) => ResultScaffold(
      toolName: toolName,
      formulaSteps: const ['L10 = (C/P)^p'],
      results: _sections,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  testWidgets('a tool title resolves back to its id', (tester) async {
    await tester.pumpWidget(
        _wrap(const Scaffold(), SavedProjects(), ToolHistory()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    final tools = ToolLibrary.shared.getTools(context);

    // The lookup that saves threading a toolId through every result page.
    for (final tool in tools.take(10)) {
      expect(toolIdForName(context, tool.title), tool.id,
          reason: tool.title);
    }
    expect(toolIdForName(context, 'no such tool'), isNull);
  });

  testWidgets('tool titles are unique, so the lookup is unambiguous',
      (tester) async {
    await tester.pumpWidget(
        _wrap(const Scaffold(), SavedProjects(), ToolHistory()));
    await tester.pumpAndSettle();

    final tools = ToolLibrary.shared.getTools(tester.element(find.byType(Scaffold)));
    final titles = tools.map((t) => t.title).toList();
    expect(titles.toSet(), hasLength(titles.length));
  });

  testWidgets('keeping a result creates a project carrying its numbers',
      (tester) async {
    final projects = SavedProjects();
    final history = ToolHistory();
    late String toolName;

    await tester.pumpWidget(
        _wrap(const Scaffold(), SavedProjects(), ToolHistory()));
    await tester.pumpAndSettle();
    final tool = ToolLibrary.shared
        .getTools(tester.element(find.byType(Scaffold)))
        .first;
    toolName = tool.title;
    history.record(tool.id, inputs: {'C': '50000'});

    await tester.pumpWidget(_wrap(_resultPage(toolName), projects, history));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('keepInProject')));
    await tester.pumpAndSettle();
    // No projects yet, so the picker is skipped and the name prompt opens.
    await tester.enterText(find.byKey(const Key('projectNameField')), 'Gearbox');
    await tester.tap(find.byKey(const Key('confirmProjectName')));
    await tester.pumpAndSettle();

    final project = projects.projects.single;
    expect(project.name, 'Gearbox');
    expect(project.entries, hasLength(1));
    expect(project.primary.toolId, tool.id);
    // The inputs come from the history entry for the same tool, so the saved
    // calculation can be reopened as well as reported on.
    expect(project.primary.inputs['C'], '50000');

    final snapshot = project.primary.snapshot!;
    expect(snapshot.toolName, toolName);
    expect(snapshot.formulaSteps, ['L10 = (C/P)^p']);
    expect(snapshot.sections.single.values.first.valueSI, 1000);
    expect(snapshot.sections.single.values.last.category, UnitCategory.length);
  });

  testWidgets('a second result can be added to the same project',
      (tester) async {
    final projects = SavedProjects();
    final history = ToolHistory();

    await tester.pumpWidget(
        _wrap(const Scaffold(), SavedProjects(), ToolHistory()));
    await tester.pumpAndSettle();
    final tool = ToolLibrary.shared
        .getTools(tester.element(find.byType(Scaffold)))
        .first;
    projects.save(name: 'Gearbox', toolId: tool.id, inputs: const {});

    await tester.pumpWidget(_wrap(_resultPage(tool.title), projects, history));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('keepInProject')));
    await tester.pumpAndSettle();
    // A project exists, so the picker offers it.
    await tester.tap(find.text('Gearbox'));
    await tester.pumpAndSettle();

    final project = projects.projects.single;
    expect(project.entries, hasLength(2));
    expect(project.reportable, hasLength(1));
    expect(projects.projects, hasLength(1), reason: 'no second project');
  });

  testWidgets('backing out of the picker saves nothing', (tester) async {
    final projects = SavedProjects();
    final history = ToolHistory();

    await tester.pumpWidget(
        _wrap(const Scaffold(), SavedProjects(), ToolHistory()));
    await tester.pumpAndSettle();
    final tool = ToolLibrary.shared
        .getTools(tester.element(find.byType(Scaffold)))
        .first;
    projects.save(name: 'Gearbox', toolId: tool.id, inputs: const {});

    await tester.pumpWidget(_wrap(_resultPage(tool.title), projects, history));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('keepInProject')));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Gearbox'))).pop();
    await tester.pumpAndSettle();

    expect(projects.projects.single.entries, hasLength(1));
  });

  testWidgets('a page that declares no results offers no save action',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ResultScaffold(
        toolName: 'Custom',
        // A page rendering its own body has no declared numbers to keep.
        body: SizedBox(),
      ),
      SavedProjects(),
      ToolHistory(),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('keepInProject')), findsNothing);
  });
}
