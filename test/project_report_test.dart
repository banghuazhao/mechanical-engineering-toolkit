import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_snapshot.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/pdf_export.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

ResultSnapshot _snapshot({String toolName = 'Bearing L10 Life'}) =>
    ResultSnapshot(
      toolName: toolName,
      capturedAt: DateTime.utc(2026, 8, 20, 9, 30),
      formulaSteps: const ['L10 = (C/P)^p'],
      sections: const [
        ResultSection(
          title: 'Bearing L10 Life',
          values: [
            ResultValue(label: 'L10, million rev', valueSI: 1000),
            ResultValue(
              label: 'Solid height',
              valueSI: 24,
              category: UnitCategory.length,
            ),
            ResultValue(label: 'Bearing type', value: 'Ball'),
          ],
        ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('ResultSnapshot', () {
    test('round-trips values as SI plus category, not as rendered text', () {
      final restored =
          ResultSnapshot.fromJson(jsonDecode(jsonEncode(_snapshot().toJson())));

      final values = restored.sections.single.values;
      expect(restored.toolName, 'Bearing L10 Life');
      expect(restored.formulaSteps, ['L10 = (C/P)^p']);
      expect(values[1].valueSI, 24);
      // Kept as a magnitude and a category so a report renders in whatever
      // unit system the reader has set today, not the one in force when the
      // calculation was saved.
      expect(values[1].category, UnitCategory.length);
      expect(values[1].value, isNull);
    });

    test('keeps a dimensionless value dimensionless', () {
      final restored =
          ResultSnapshot.fromJson(jsonDecode(jsonEncode(_snapshot().toJson())));
      expect(restored.sections.single.values.first.valueSI, 1000);
      expect(restored.sections.single.values.first.category, isNull);
    });

    test('keeps a preformatted value as text', () {
      final restored =
          ResultSnapshot.fromJson(jsonDecode(jsonEncode(_snapshot().toJson())));
      expect(restored.sections.single.values.last.value, 'Ball');
      expect(restored.sections.single.values.last.valueSI, isNull);
    });

    test('a category this build no longer has leaves the number readable', () {
      final restored = ResultSnapshot.fromJson({
        'toolName': 'X',
        'capturedAt': '2026-01-01T00:00:00.000Z',
        'sections': [
          {
            'title': 'S',
            'values': [
              {'label': 'v', 'si': 5.0, 'cat': 'unitCategoryFromTheFuture'},
            ],
          },
        ],
      });

      final value = restored.sections.single.values.single;
      expect(value.valueSI, 5.0);
      // Dimensionless rather than unreadable: it stops converting, but the
      // number still renders.
      expect(value.category, isNull);
    });

    test('a value with neither a number nor text does not throw on read', () {
      final restored = ResultSnapshot.fromJson({
        'toolName': 'X',
        'capturedAt': 'not a date',
        'sections': [
          {
            'title': 'S',
            'values': [
              {'label': 'v'},
            ],
          },
        ],
      });

      expect(restored.sections.single.values.single.value, '');
      expect(restored.capturedAt.millisecondsSinceEpoch, 0);
    });
  });

  group('SavedProject schema', () {
    test('reads a version 1 record as a project of one calculation', () {
      final project = SavedProject.fromJson({
        'v': 1,
        'id': 'a',
        'name': 'Gearbox',
        'toolId': 300,
        'inputs': {'Force, F': '10'},
        'createdAt': '2026-08-01T10:00:00.000Z',
        'updatedAt': '2026-08-02T10:00:00.000Z',
      });

      expect(project.entries, hasLength(1));
      expect(project.toolId, 300);
      expect(project.inputs['Force, F'], '10');
      expect(project.primary.snapshot, isNull);
      // The entry inherits the project's creation time, since a v1 record
      // never carried one of its own.
      expect(project.primary.addedAt, DateTime.parse('2026-08-01T10:00:00Z'));
    });

    test('writes version 2 and round-trips its entries', () {
      final store = SavedProjects();
      final saved = store.save(
        name: 'Gearbox',
        toolId: 300,
        inputs: const {'C': '50000'},
        snapshot: _snapshot(),
      );
      store.addEntry(saved.id,
          toolId: 301, inputs: const {'d': '2'}, snapshot: _snapshot());

      final reloaded = SavedProjects().byId(saved.id)!;
      expect(reloaded.entries, hasLength(2));
      expect(reloaded.entries.first.toolId, 300);
      expect(reloaded.entries.last.toolId, 301);
      expect(reloaded.entries.last.snapshot!.sections, hasLength(1));
      expect(SavedProject.currentSchemaVersion, 2);
    });

    test('drops one unreadable entry without losing the project', () {
      final project = SavedProject.fromJson({
        'v': 2,
        'id': 'a',
        'name': 'Mixed',
        'entries': [
          {'toolId': 300, 'inputs': {}, 'addedAt': '2026-08-01T10:00:00.000Z'},
          {'inputs': {}}, // no toolId
        ],
        'createdAt': '2026-08-01T10:00:00.000Z',
        'updatedAt': '2026-08-01T10:00:00.000Z',
      });

      expect(project.entries, hasLength(1));
      expect(project.toolId, 300);
    });

    test('rejects a record whose every entry is unreadable', () {
      expect(
        () => SavedProject.fromJson({
          'v': 2,
          'id': 'a',
          'name': 'Broken',
          'entries': [
            {'inputs': {}},
          ],
          'createdAt': '2026-08-01T10:00:00.000Z',
          'updatedAt': '2026-08-01T10:00:00.000Z',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SavedProjects entries', () {
    test('reportable skips entries that never had a result', () {
      final store = SavedProjects();
      final saved =
          store.save(name: 'Shaft', toolId: 300, inputs: const {});
      store.addEntry(saved.id,
          toolId: 301, inputs: const {}, snapshot: _snapshot());

      final project = store.byId(saved.id)!;
      expect(project.entries, hasLength(2));
      expect(project.reportable, hasLength(1));
      expect(project.reportable.single.toolId, 301);
    });

    test('removing an entry leaves the rest in order', () {
      final store = SavedProjects();
      final saved = store.save(name: 'Shaft', toolId: 300, inputs: const {});
      store.addEntry(saved.id, toolId: 301, inputs: const {});
      store.addEntry(saved.id, toolId: 302, inputs: const {});

      store.removeEntry(saved.id, 1);

      expect(store.byId(saved.id)!.entries.map((e) => e.toolId), [300, 302]);
    });

    test('removing the last entry deletes the project', () {
      final store = SavedProjects();
      final saved = store.save(name: 'Shaft', toolId: 300, inputs: const {});

      store.removeEntry(saved.id, 0);

      // An empty project cannot be reopened or reported on, so leaving a shell
      // behind would only be something else to tidy up.
      expect(store.byId(saved.id), isNull);
      expect(store.projects, isEmpty);
    });

    test('an out-of-range removal changes nothing', () {
      final store = SavedProjects();
      final saved = store.save(name: 'Shaft', toolId: 300, inputs: const {});
      store.addEntry(saved.id, toolId: 301, inputs: const {});

      store.removeEntry(saved.id, 9);
      store.removeEntry('no such project', 0);

      expect(store.byId(saved.id)!.entries, hasLength(2));
    });

    test('saving over the inputs drops a result that described the old ones',
        () {
      final store = SavedProjects();
      final saved = store.save(
        name: 'Shaft',
        toolId: 300,
        inputs: const {'F': '10'},
        snapshot: _snapshot(),
      );

      store.updateInputs(saved.id, const {'F': '20'});

      final project = store.byId(saved.id)!;
      expect(project.inputs['F'], '20');
      expect(project.primary.snapshot, isNull);
    });
  });

  group('buildProjectReportPdf', () {
    final items = [
      ReportItem(
        title: 'Bearing L10 Life',
        sections: _snapshot().sections,
        formulaSteps: _snapshot().formulaSteps,
        capturedAt: DateTime.utc(2026, 8, 20, 9, 30),
      ),
      ReportItem(
        title: 'Shaft Fatigue',
        sections: _snapshot().sections,
        capturedAt: DateTime.utc(2026, 8, 21, 9, 30),
      ),
    ];

    test('produces a well-formed PDF covering every calculation', () async {
      final bytes = await buildProjectReportPdf(
        projectName: 'Gearbox rev C',
        items: items,
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
        generatedAt: DateTime.utc(2026, 8, 22, 14, 22),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(String.fromCharCodes(bytes.skip(bytes.length - 6)),
          contains('%%EOF'));
    });

    test('renders an entry that only ever had inputs', () async {
      final bytes = await buildProjectReportPdf(
        projectName: 'Gearbox',
        items: const [
          ReportItem(title: 'Spur Gear', inputs: {'Module, m': '2'}),
        ],
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
      );

      expect(bytes, isNotEmpty);
    });

    test('renders an entry with neither a result nor inputs', () async {
      final bytes = await buildProjectReportPdf(
        projectName: 'Gearbox',
        items: const [ReportItem(title: 'Spur Gear')],
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
      );

      expect(bytes, isNotEmpty);
    });

    test('renders both unit systems from one set of stored values', () async {
      for (final system in UnitSystem.values) {
        final bytes = await buildProjectReportPdf(
          projectName: 'Gearbox',
          items: items,
          precs: NumberPrecisionHelper(),
          system: system,
        );
        expect(bytes, isNotEmpty, reason: 'failed for $system');
      }
    });

    test('handles an empty report', () async {
      final bytes = await buildProjectReportPdf(
        projectName: 'Empty',
        items: const [],
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
      );
      expect(bytes, isNotEmpty);
    });
  });

  group('project report glyph coverage', () {
    test('reaches titles, labels, formula steps and input rows', () {
      final strings = projectReportStrings(
        projectName: 'Gearbox',
        items: [
          ReportItem(
            title: 'Bearing L10 Life',
            sections: _snapshot().sections,
            formulaSteps: const ['L10 = (C/P)^p'],
            inputs: const {'Dynamic load rating': '50000'},
          ),
        ],
      ).toList();

      expect(strings, contains('Gearbox'));
      expect(strings, contains('Bearing L10 Life'));
      expect(strings, contains('L10, million rev'));
      expect(strings, contains('L10 = (C/P)^p'));
      expect(strings, contains('Dynamic load rating'));
      expect(strings, contains('50000'));
      // Preformatted values are drawn as-is, so they need checking too.
      expect(strings, contains('Ball'));
    });

    test('rejects a project name the bundled faces cannot draw', () {
      expect(
        canRenderProjectReport(
          fonts: PdfReportFonts.standard,
          projectName: 'Проект',
          items: const [],
        ),
        isFalse,
      );
    });
  });
}
