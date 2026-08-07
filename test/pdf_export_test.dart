import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/pdf_export.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sections = [
  ResultSection(
    title: 'Helical Compression Spring',
    values: [
      ResultValue(label: 'Spring index, C', valueSI: 10),
      ResultValue(
        label: 'Solid height',
        valueSI: 24,
        category: UnitCategory.length,
      ),
    ],
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('buildResultPdf', () {
    test('produces a well-formed PDF document', () async {
      final bytes = await buildResultPdf(
        toolName: 'Helical Compression Spring',
        sections: _sections,
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
        generatedAt: DateTime.utc(2026, 8, 7, 14, 22),
      );

      expect(bytes, isNotEmpty);
      // Every PDF starts with the %PDF- header and ends with %%EOF.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(
        String.fromCharCodes(bytes.skip(bytes.length - 6)),
        contains('%%EOF'),
      );
    });

    test('renders without a formula block when none is supplied', () async {
      final bytes = await buildResultPdf(
        toolName: 'Spring',
        sections: _sections,
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
      );
      expect(bytes, isNotEmpty);
    });

    test('renders with a formula block', () async {
      final bytes = await buildResultPdf(
        toolName: 'Spring',
        sections: _sections,
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
        formulaSteps: const ['k = G·d⁴/(8·D³·Na)', 'Solid height = (Na+2)·d'],
      );
      expect(bytes, isNotEmpty);
    });

    test('a longer report still renders', () async {
      // Guards the MultiPage path: many sections must paginate rather than
      // overflow or throw.
      final sections = [
        for (var s = 0; s < 12; s++)
          ResultSection(
            title: 'Section $s',
            values: [
              for (var v = 0; v < 8; v++)
                ResultValue(
                  label: 'Quantity $v',
                  valueSI: v.toDouble(),
                  category: UnitCategory.stress,
                ),
            ],
          ),
      ];
      final bytes = await buildResultPdf(
        toolName: 'Long report',
        sections: sections,
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
      );
      expect(bytes, isNotEmpty);
    });

    test('renders both unit systems', () async {
      for (final system in UnitSystem.values) {
        final bytes = await buildResultPdf(
          toolName: 'Spring',
          sections: _sections,
          precs: NumberPrecisionHelper(),
          system: system,
        );
        expect(bytes, isNotEmpty, reason: 'failed for $system');
      }
    });

    test('handles an empty section list', () async {
      final bytes = await buildResultPdf(
        toolName: 'Nothing',
        sections: const [],
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
      );
      expect(bytes, isNotEmpty);
    });
  });

  group('hasGlyphsFor', () {
    test('accepts Latin text and the usual engineering symbols', () {
      expect(hasGlyphsFor('Helical Compression Spring'), isTrue);
      expect(hasGlyphsFor('Solid height'), isTrue);
      expect(hasGlyphsFor('45°C'), isTrue);
      expect(hasGlyphsFor('Träger — Größe'), isTrue);
      expect(hasGlyphsFor("Théorie de l'élasticité"), isTrue);
    });

    test('rejects CJK, which the standard PDF fonts cannot draw', () {
      // The check that tells the caller an embedded font is required rather
      // than silently emitting a page of empty boxes.
      expect(hasGlyphsFor('莫尔圆'), isFalse);
      expect(hasGlyphsFor('機械設計'), isFalse);
      expect(hasGlyphsFor('Spring 弹簧'), isFalse);
    });

    test('rejects the Greek letters used for stress symbols', () {
      // σ, τ and friends are outside Latin Extended-B, so a report that
      // includes them needs an embedded font too.
      expect(hasGlyphsFor('σ = F/A'), isFalse);
      expect(hasGlyphsFor('τ_max'), isFalse);
    });
  });

  group('pdfFileName', () {
    test('derives an ASCII stem', () {
      expect(pdfFileName('Helical Compression Spring'),
          'Helical_Compression_Spring.pdf');
    });

    test('falls back when the localized name sanitizes to nothing', () {
      expect(pdfFileName('莫尔圆'), 'me_toolkit_result.pdf');
      expect(pdfFileName(''), 'me_toolkit_result.pdf');
    });
  });
}
