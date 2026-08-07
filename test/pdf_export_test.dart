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

  group('embedded fonts', () {
    setUp(PdfReportFonts.resetCache);

    test('loads Noto Sans from the bundled assets', () async {
      final fonts = await PdfReportFonts.load();
      expect(fonts.regular, isNotNull,
          reason: 'fonts/NotoSans-Regular.ttf must be declared in pubspec');
      expect(fonts.bold, isNotNull,
          reason: 'fonts/NotoSans-Bold.ttf must be declared in pubspec');
    });

    test('caches so every export does not re-parse the TTFs', () async {
      final first = await PdfReportFonts.load();
      final second = await PdfReportFonts.load();
      expect(identical(first, second), isTrue);
    });

    test('renders Greek and superscripts without throwing', () async {
      final bytes = await buildResultPdf(
        toolName: 'Plane stress σ/τ',
        sections: const [
          ResultSection(
            title: 'Stresses',
            values: [
              ResultValue(label: 'Shear stress, τ', valueSI: 1),
              ResultValue(
                label: 'Second moment, I',
                valueSI: 1,
                category: UnitCategory.momentOfInertia,
              ),
            ],
          ),
        ],
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
        formulaSteps: const ['σ = F/A', 'τ = T·r/J', 'I in mm⁴'],
      );
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });

  group('sanitizeForPdf', () {
    test('spells out the math operators Noto Sans lacks', () {
      // Verified against the font's cmap: Noto Sans carries Greek and
      // superscripts but not the Mathematical Operators block.
      expect(sanitizeForPdf('f ≈ (d/2πD²Na)·√(G/2ρ)'),
          'f ~= (d/2πD²Na)·sqrt(G/2ρ)');
      expect(sanitizeForPdf('n ≥ 2'), 'n >= 2');
      expect(sanitizeForPdf('n ≤ 2'), 'n <= 2');
    });

    test('leaves everything the font does carry alone', () {
      expect(sanitizeForPdf('σ = F/A'), 'σ = F/A');
      expect(sanitizeForPdf('mm⁴'), 'mm⁴');
      expect(sanitizeForPdf('45 °C ± 2'), '45 °C ± 2');
      expect(sanitizeForPdf('Träger — Größe'), 'Träger — Größe');
    });
  });

  group('hasGlyphsFor', () {
    test('accepts Latin text and the usual engineering symbols', () {
      expect(hasGlyphsFor('Helical Compression Spring'), isTrue);
      expect(hasGlyphsFor('45°C'), isTrue);
      expect(hasGlyphsFor('Träger — Größe'), isTrue);
      expect(hasGlyphsFor("Théorie de l'élasticité"), isTrue);
    });

    test('accepts Greek and superscripts, which the embedded font carries', () {
      expect(hasGlyphsFor('σ = F/A'), isTrue);
      expect(hasGlyphsFor('τ_max'), isTrue);
      expect(hasGlyphsFor('mm⁴'), isTrue);
      expect(hasGlyphsFor('Δθ'), isTrue);
    });

    test('accepts math operators, because they are substituted first', () {
      expect(hasGlyphsFor('f ≈ √(G/2ρ)'), isTrue);
    });

    test('still rejects CJK', () {
      // The remaining known gap: Noto Sans is Latin/Greek/Cyrillic, so the
      // three CJK locales' tool names cannot be drawn.
      expect(hasGlyphsFor('莫尔圆'), isFalse);
      expect(hasGlyphsFor('機械設計'), isFalse);
      expect(hasGlyphsFor('Spring 弹簧'), isFalse);
    });
  });

  group('canRenderReport', () {
    test('passes for a Latin report with Greek and math symbols', () {
      expect(
        canRenderReport(
          toolName: 'Helical Compression Spring',
          sections: const [
            ResultSection(
              title: 'Stresses',
              values: [ResultValue(label: 'Shear stress, τ', valueSI: 1)],
            ),
          ],
          formulaSteps: const ['f ≈ √(G/2ρ)', 'I in mm⁴'],
        ),
        isTrue,
      );
    });

    test('fails when the tool name is CJK', () {
      expect(
        canRenderReport(
          toolName: '莫尔圆',
          sections: const [
            ResultSection(
              title: 'Stresses',
              values: [ResultValue(label: 'Shear stress', valueSI: 1)],
            ),
          ],
        ),
        isFalse,
      );
    });

    test('fails when only a nested label is CJK', () {
      // The check has to reach section titles, labels and formula steps, not
      // just the tool name.
      expect(
        canRenderReport(
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: 'Stresses',
              values: [ResultValue(label: '剪应力', valueSI: 1)],
            ),
          ],
        ),
        isFalse,
      );
      expect(
        canRenderReport(
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: '应力',
              values: [ResultValue(label: 'Shear', valueSI: 1)],
            ),
          ],
        ),
        isFalse,
      );
      expect(
        canRenderReport(
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: 'Stresses',
              values: [ResultValue(label: 'Shear', valueSI: 1)],
            ),
          ],
          formulaSteps: const ['剪应力 = T·r/J'],
        ),
        isFalse,
      );
    });

    test('checks pre-formatted values too', () {
      expect(
        canRenderReport(
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: 'Notes',
              values: [ResultValue(label: 'Note', value: '約 2.5 N/mm')],
            ),
          ],
        ),
        isFalse,
      );
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
