import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/csv_export.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _generatedAt = DateTime.utc(2026, 8, 7, 14, 22, 5);

List<ResultSection> _springSections() => const [
      ResultSection(
        title: 'Helical Compression Spring',
        values: [
          ResultValue(label: 'Spring index, C', valueSI: 10),
          ResultValue(
            label: 'Spring rate, k',
            valueSI: 2,
            category: UnitCategory.distributedLoadSmall,
          ),
          ResultValue(
            label: 'Solid height',
            valueSI: 24,
            category: UnitCategory.length,
          ),
        ],
      ),
    ];

/// The rows after the preamble and the blank separator line.
List<String> _dataRows(String csv) {
  final lines = const LineSplitter().convert(csv);
  return lines.sublist(lines.indexOf('') + 1);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('csvEscape', () {
    test('leaves an ordinary field alone', () {
      expect(csvEscape('Spring rate'), 'Spring rate');
      expect(csvEscape('2.5'), '2.5');
      expect(csvEscape(''), '');
    });

    test('quotes a field containing a comma', () {
      // Every input label in this app is of the form "Force, F", so this is
      // the common case rather than an edge case.
      expect(csvEscape('Force, F'), '"Force, F"');
    });

    test('quotes and doubles embedded quotes', () {
      expect(csvEscape('3" bolt'), '"3"" bolt"');
    });

    test('quotes a field containing a newline or carriage return', () {
      expect(csvEscape('a\nb'), '"a\nb"');
      expect(csvEscape('a\r\nb'), '"a\r\nb"');
    });

    test('leaves non-ASCII engineering symbols unquoted', () {
      expect(csvEscape('τ_max'), 'τ_max');
      expect(csvEscape('mm⁴'), 'mm⁴');
    });
  });

  group('buildResultCsv', () {
    test('writes the preamble with tool, timestamp, and unit system', () {
      final csv = buildResultCsv(
        toolName: 'Helical Compression Spring',
        sections: _springSections(),
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
        generatedAt: _generatedAt,
      );
      final lines = const LineSplitter().convert(csv);

      expect(lines[0],
          'Mechanical Engineering Toolkit,Helical Compression Spring');
      expect(lines[1], 'Generated,${_generatedAt.toIso8601String()}');
      expect(lines[2], 'Unit system,Metric (SI)');
      expect(lines[3], '');
      expect(lines[4], 'Section,Quantity,Value,Unit');
    });

    test('splits label, value, and unit into their own columns', () {
      final precs = NumberPrecisionHelper()..set(3);
      final csv = buildResultCsv(
        toolName: 'Spring',
        sections: _springSections(),
        precs: precs,
        system: UnitSystem.si,
        generatedAt: _generatedAt,
      );

      expect(_dataRows(csv), [
        'Section,Quantity,Value,Unit',
        'Helical Compression Spring,"Spring index, C",10.000,',
        'Helical Compression Spring,"Spring rate, k",2.000,N/mm',
        'Helical Compression Spring,Solid height,24.000,mm',
      ]);
    });

    test('converts to the reader\'s unit system at export time', () {
      final precs = NumberPrecisionHelper()..set(3);
      final csv = buildResultCsv(
        toolName: 'Spring',
        sections: _springSections(),
        precs: precs,
        system: UnitSystem.imperial,
        generatedAt: _generatedAt,
      );
      final rows = _dataRows(csv);

      expect(rows.first, 'Section,Quantity,Value,Unit');
      // 2 N/mm -> lbf/in, 24 mm -> in. The numbers come from units.dart, so
      // assert against it rather than restating the factors here.
      final expectedRate =
          precs.formatValue(fromSI(2, UnitCategory.distributedLoadSmall,
              UnitSystem.imperial));
      final expectedHeight = precs
          .formatValue(fromSI(24, UnitCategory.length, UnitSystem.imperial));
      expect(rows[2], endsWith('$expectedRate,lbf/in'));
      expect(rows[3], endsWith('$expectedHeight,in'));
    });

    test('records which unit system the numbers are in', () {
      final csv = buildResultCsv(
        toolName: 'Spring',
        sections: _springSections(),
        precs: NumberPrecisionHelper(),
        system: UnitSystem.imperial,
        generatedAt: _generatedAt,
      );
      expect(csv, contains('Unit system,Imperial (US)'));
    });

    test('follows the user precision setting', () {
      final precs = NumberPrecisionHelper()..set(1);
      final csv = buildResultCsv(
        toolName: 'Spring',
        sections: _springSections(),
        precs: precs,
        system: UnitSystem.si,
        generatedAt: _generatedAt,
      );
      expect(csv, contains('"Spring index, C",10.0,'));
    });

    test('a dimensionless value gets an empty unit column, not a bogus one',
        () {
      final csv = buildResultCsv(
        toolName: 'x',
        sections: const [
          ResultSection(
            title: 'S',
            values: [ResultValue(label: 'Ratio', valueSI: 0.5)],
          ),
        ],
        precs: NumberPrecisionHelper()..set(2),
        system: UnitSystem.si,
        generatedAt: _generatedAt,
      );
      expect(_dataRows(csv).last, 'S,Ratio,0.50,');
    });

    test('a pre-formatted value passes through with no unit column', () {
      // Documented limitation: the unit is already fused into the text, so it
      // cannot be split out or converted. This is the reason to prefer valueSI.
      final csv = buildResultCsv(
        toolName: 'x',
        sections: const [
          ResultSection(
            title: 'S',
            values: [ResultValue(label: 'Note', value: '2.5 N/mm')],
          ),
        ],
        precs: NumberPrecisionHelper(),
        system: UnitSystem.imperial,
        generatedAt: _generatedAt,
      );
      expect(_dataRows(csv).last, 'S,Note,2.5 N/mm,');
    });

    test('emits every section, tagged with its title', () {
      final csv = buildResultCsv(
        toolName: 'x',
        sections: const [
          ResultSection(
            title: 'Stresses',
            values: [ResultValue(label: 'a', valueSI: 1)],
          ),
          ResultSection(
            title: 'Factor of Safety',
            values: [ResultValue(label: 'b', valueSI: 2)],
          ),
        ],
        precs: NumberPrecisionHelper()..set(0),
        system: UnitSystem.si,
        generatedAt: _generatedAt,
      );
      final rows = _dataRows(csv);
      expect(rows[1], 'Stresses,a,1,');
      expect(rows[2], 'Factor of Safety,b,2,');
    });

    test('uses CRLF line endings', () {
      final csv = buildResultCsv(
        toolName: 'x',
        sections: _springSections(),
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
        generatedAt: _generatedAt,
      );
      expect(csv, contains('\r\n'));
      expect(csv, endsWith('\r\n'));
    });
  });

  group('csvBytes', () {
    test('leads with a UTF-8 BOM so Excel reads µ and ° correctly', () {
      final bytes = csvBytes('a,µm\r\n');
      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(bytes.skip(3).toList()), 'a,µm\r\n');
    });
  });

  group('csvFileName', () {
    test('derives an ASCII stem from the tool name', () {
      expect(csvFileName('Helical Compression Spring'),
          'Helical_Compression_Spring.csv');
      expect(csvFileName("Mohr's Circle"), 'Mohr_s_Circle.csv');
    });

    test('falls back when the localized name sanitizes to nothing', () {
      // A Chinese or Japanese tool name has no ASCII to keep; without the
      // fallback the file would be called "_.csv".
      expect(csvFileName('莫尔圆'), 'me_toolkit_result.csv');
      expect(csvFileName(''), 'me_toolkit_result.csv');
    });
  });

  group('resultShareLines', () {
    test('renders each section with its values and units', () {
      final precs = NumberPrecisionHelper()..set(1);
      expect(
        resultShareLines(_springSections(), precs, UnitSystem.si),
        [
          'Helical Compression Spring',
          'Spring index, C: 10.0',
          'Spring rate, k: 2.0 N/mm',
          'Solid height: 24.0 mm',
        ],
      );
    });

    test('converts with the unit system, unlike a hardcoded share string', () {
      // The bug this replaces: hand-written share lines hardcoded "N/mm" and
      // "mm", so an Imperial user's shared text disagreed with their screen.
      final precs = NumberPrecisionHelper()..set(2);
      final lines =
          resultShareLines(_springSections(), precs, UnitSystem.imperial);
      expect(lines.any((l) => l.contains('N/mm')), isFalse);
      expect(lines.any((l) => l.endsWith('lbf/in')), isTrue);
      expect(lines.any((l) => l.endsWith('in')), isTrue);
    });

    test('separates sections with a blank line', () {
      final lines = resultShareLines(
        const [
          ResultSection(
            title: 'A',
            values: [ResultValue(label: 'x', valueSI: 1)],
          ),
          ResultSection(
            title: 'B',
            values: [ResultValue(label: 'y', valueSI: 2)],
          ),
        ],
        NumberPrecisionHelper()..set(0),
        UnitSystem.si,
      );
      expect(lines, ['A', 'x: 1', '', 'B', 'y: 2']);
    });
  });

  group('ResultValue', () {
    test('formats and labels an SI value for the active system', () {
      const value = ResultValue(
          label: 'Solid height', valueSI: 25.4, category: UnitCategory.length);
      final precs = NumberPrecisionHelper()..set(1);

      expect(value.formattedValue(precs, UnitSystem.si), '25.4');
      expect(value.unit(UnitSystem.si), 'mm');
      expect(value.formattedValue(precs, UnitSystem.imperial), '1.0');
      expect(value.unit(UnitSystem.imperial), 'in');
      expect(value.formatted(precs, UnitSystem.imperial), '1.0 in');
    });

    test('a dimensionless value has no unit', () {
      const value = ResultValue(label: 'C', valueSI: 10);
      final precs = NumberPrecisionHelper()..set(0);
      expect(value.unit(UnitSystem.si), '');
      expect(value.formatted(precs, UnitSystem.si), '10');
    });

    test('a pre-formatted value is returned verbatim', () {
      const value = ResultValue(label: 'k', value: '2.5 N/mm');
      final precs = NumberPrecisionHelper();
      expect(value.formattedValue(precs, UnitSystem.imperial), '2.5 N/mm');
      expect(value.unit(UnitSystem.imperial), '');
    });
  });
}
