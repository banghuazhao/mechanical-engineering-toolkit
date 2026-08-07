import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_history_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/theme_preference.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child, {SavedProjects? projects, ToolHistory? history}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider(create: (_) => history ?? ToolHistory()),
        ChangeNotifierProvider(create: (_) => LanguagePreference()),
        ChangeNotifierProvider(create: (_) => ThemePreference()),
        ChangeNotifierProvider(create: (_) => projects ?? SavedProjects()),
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

  group('SavedProjects store', () {
    test('starts empty', () {
      expect(SavedProjects().projects, isEmpty);
      expect(SavedProjects().isEmpty, isTrue);
    });

    test('saves a project and reads it back', () {
      final store = SavedProjects();
      final saved = store.save(
        name: 'Valve spring — rev C',
        toolId: 300,
        inputs: {'Wire diameter d': '2', 'Coil diameter D': '20'},
      );

      final projects = store.projects;
      expect(projects, hasLength(1));
      expect(projects.single.id, saved.id);
      expect(projects.single.name, 'Valve spring — rev C');
      expect(projects.single.toolId, 300);
      expect(projects.single.inputs['Wire diameter d'], '2');
    });

    test('trims the name', () {
      final store = SavedProjects();
      store.save(name: '  Bracket  ', toolId: 100, inputs: const {});
      expect(store.projects.single.name, 'Bracket');
    });

    test('persists across instances', () {
      SavedProjects().save(
        name: 'Shaft A',
        toolId: 110,
        inputs: {'Torque, T': '50'},
      );
      // A fresh instance reads the same backing store the app would on
      // relaunch. This is the whole point of a project over a history entry.
      final reloaded = SavedProjects().projects;
      expect(reloaded, hasLength(1));
      expect(reloaded.single.name, 'Shaft A');
      expect(reloaded.single.inputs['Torque, T'], '50');
    });

    test('keeps far more than history\'s 50-entry cap', () {
      final store = SavedProjects();
      for (var i = 0; i < 120; i++) {
        store.save(name: 'Project $i', toolId: 100, inputs: const {});
      }
      expect(store.projects, hasLength(120));
    });

    test('orders newest-updated first', () async {
      final store = SavedProjects();
      final first = store.save(name: 'First', toolId: 100, inputs: const {});
      await Future<void>.delayed(const Duration(milliseconds: 5));
      store.save(name: 'Second', toolId: 100, inputs: const {});

      expect(store.projects.map((p) => p.name), ['Second', 'First']);

      await Future<void>.delayed(const Duration(milliseconds: 5));
      store.rename(first.id, 'First again');
      // Touching a project floats it back to the top.
      expect(store.projects.map((p) => p.name), ['First again', 'Second']);
    });

    test('renames without disturbing the inputs', () {
      final store = SavedProjects();
      final saved = store.save(
        name: 'Old',
        toolId: 100,
        inputs: {'Force, F': '1000'},
      );
      store.rename(saved.id, 'New');

      final project = store.byId(saved.id)!;
      expect(project.name, 'New');
      expect(project.inputs['Force, F'], '1000');
      expect(project.createdAt, saved.createdAt);
    });

    test('updates inputs for a save-over', () {
      final store = SavedProjects();
      final saved =
          store.save(name: 'Beam', toolId: 100, inputs: {'Length, L': '3'});
      store.updateInputs(saved.id, {'Length, L': '4.5'});

      expect(store.byId(saved.id)!.inputs['Length, L'], '4.5');
      expect(store.byId(saved.id)!.name, 'Beam');
    });

    test('deletes only the named project', () {
      final store = SavedProjects();
      final keep = store.save(name: 'Keep', toolId: 100, inputs: const {});
      final drop = store.save(name: 'Drop', toolId: 100, inputs: const {});

      store.delete(drop.id);

      expect(store.projects.map((p) => p.name), ['Keep']);
      expect(store.byId(keep.id), isNotNull);
      expect(store.byId(drop.id), isNull);
    });

    test('notifies listeners on every mutation', () {
      final store = SavedProjects();
      var notifications = 0;
      store.addListener(() => notifications++);

      final saved = store.save(name: 'A', toolId: 100, inputs: const {});
      expect(notifications, 1);
      store.rename(saved.id, 'B');
      expect(notifications, 2);
      store.updateInputs(saved.id, const {'x': '1'});
      expect(notifications, 3);
      store.delete(saved.id);
      expect(notifications, 4);
      store.clear();
      expect(notifications, 5);
    });
  });

  group('SavedProject storage compatibility', () {
    test('stores a schema version so a future shape can be migrated', () {
      SavedProjects().save(name: 'A', toolId: 100, inputs: const {});
      final raw =
          SharedPreferencesHelper.localStorage.getStringList('SAVED_PROJECTS')!;
      expect(jsonDecode(raw.single)['v'], SavedProject.currentSchemaVersion);
    });

    test('an unrecognized input key is ignored rather than fatal', () {
      // The documented degradation: renaming a calculator's input label costs
      // the user that one prefilled field, not the whole project.
      final project = SavedProject.fromJson({
        'v': 1,
        'id': 'x',
        'name': 'A',
        'toolId': 100,
        'inputs': {'Renamed since': '5', 'Force, F': '10'},
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      });
      expect(project.inputs['Force, F'], '10');
      expect(project.inputs['Renamed since'], '5');
      expect(project.inputs['Never written'], isNull);
    });

    test('coerces non-string input values', () {
      final project = SavedProject.fromJson({
        'id': 'x',
        'name': 'A',
        'toolId': 100,
        'inputs': {'Force, F': 10, 'Ratio': 0.5},
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      });
      expect(project.inputs['Force, F'], '10');
      expect(project.inputs['Ratio'], '0.5');
    });

    test('a record with no id or toolId is rejected', () {
      expect(
        () => SavedProject.fromJson({'name': 'A'}),
        throwsFormatException,
      );
    });

    test('one corrupt row does not hide the others', () {
      final store = SavedProjects();
      store.save(name: 'Good', toolId: 100, inputs: const {});
      final raw =
          SharedPreferencesHelper.localStorage.getStringList('SAVED_PROJECTS')!;
      SharedPreferencesHelper.localStorage.setStringList(
        'SAVED_PROJECTS',
        ['not json at all', ...raw, '{"name":"no id"}'],
      );

      expect(store.projects.map((p) => p.name), ['Good']);
    });

    test('missing timestamps fall back instead of throwing', () {
      final project = SavedProject.fromJson({
        'id': 'x',
        'name': 'A',
        'toolId': 100,
        'inputs': const {},
      });
      expect(project.createdAt, isA<DateTime>());
      expect(project.updatedAt, project.createdAt);
    });
  });

  group('SavedProjectsPage', () {
    testWidgets('shows the empty state with nothing saved', (tester) async {
      await tester.pumpWidget(_wrap(const SavedProjectsPage()));
      await tester.pumpAndSettle();

      expect(find.text('No saved projects yet'), findsOneWidget);
    });

    testWidgets('lists a saved project by its name and tool', (tester) async {
      final store = SavedProjects();
      store.save(
        name: 'Valve spring — rev C',
        toolId: 100,
        inputs: {'Force, F': '1000'},
      );

      await tester
          .pumpWidget(_wrap(const SavedProjectsPage(), projects: store));
      await tester.pumpAndSettle();

      expect(find.text('Valve spring — rev C'), findsOneWidget);
      expect(find.textContaining('Force, F: 1000'), findsOneWidget);
    });

    testWidgets('renames a project through the overflow menu', (tester) async {
      final store = SavedProjects();
      final saved =
          store.save(name: 'Before', toolId: 100, inputs: const {});

      await tester
          .pumpWidget(_wrap(const SavedProjectsPage(), projects: store));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename project').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('projectNameField')), 'After');
      await tester.tap(find.byKey(const Key('confirmProjectName')));
      await tester.pumpAndSettle();

      expect(store.byId(saved.id)!.name, 'After');
    });

    testWidgets('deletes a project after confirming', (tester) async {
      final store = SavedProjects();
      store.save(name: 'Doomed', toolId: 100, inputs: const {});

      await tester
          .pumpWidget(_wrap(const SavedProjectsPage(), projects: store));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('Delete this project?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(store.projects, isEmpty);
    });

    testWidgets('an empty name is rejected', (tester) async {
      final store = SavedProjects();
      store.save(name: 'Before', toolId: 100, inputs: const {});

      await tester
          .pumpWidget(_wrap(const SavedProjectsPage(), projects: store));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename project').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('projectNameField')), '   ');
      await tester.tap(find.byKey(const Key('confirmProjectName')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a name'), findsOneWidget);
      expect(store.projects.single.name, 'Before');
    });
  });

  group('Saving from history', () {
    testWidgets('a history entry can be promoted to a project',
        (tester) async {
      final history = ToolHistory();
      history.record(100, inputs: {'Force, F': '1000', 'Area, A': '50'});
      final store = SavedProjects();

      await tester.pumpWidget(
        _wrap(const ToolHistoryPage(), projects: store, history: history),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
      await tester.pumpAndSettle();

      // The name defaults to the tool title, so the common case is one tap.
      expect(find.byKey(const Key('projectNameField')), findsOneWidget);
      await tester.enterText(
          find.byKey(const Key('projectNameField')), 'Lug plate');
      await tester.tap(find.byKey(const Key('confirmProjectName')));
      await tester.pumpAndSettle();

      expect(store.projects, hasLength(1));
      expect(store.projects.single.name, 'Lug plate');
      expect(store.projects.single.toolId, 100);
      expect(store.projects.single.inputs['Force, F'], '1000');
      expect(store.projects.single.inputs['Area, A'], '50');
    });

    testWidgets('backing out of the name dialog saves nothing', (tester) async {
      final history = ToolHistory();
      history.record(100, inputs: {'Force, F': '1000'});
      final store = SavedProjects();

      await tester.pumpWidget(
        _wrap(const ToolHistoryPage(), projects: store, history: history),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(store.projects, isEmpty);
    });
  });
}
