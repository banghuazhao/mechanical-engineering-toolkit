import 'dart:convert';
import 'dart:io';

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

    test('loads Noto Sans and both CJK fallbacks from the bundled assets',
        () async {
      final fonts = await PdfReportFonts.load();
      expect(fonts.regular, isNotNull,
          reason: 'fonts/NotoSans-Regular.ttf must be declared in pubspec');
      expect(fonts.bold, isNotNull,
          reason: 'fonts/NotoSans-Bold.ttf must be declared in pubspec');
      expect(fonts.fallback, hasLength(2),
          reason: 'both CJK subsets must be declared in pubspec');
    });

    test('caches so every export does not re-parse the TTFs', () async {
      final first = await PdfReportFonts.load();
      final second = await PdfReportFonts.load();
      expect(identical(first, second), isTrue);
    });

    test('puts the Japanese face first for ja, the Chinese one otherwise',
        () async {
      // The two subsets overlap on most Han characters, so whichever leads
      // decides the glyph forms a reader sees.
      final ja = await PdfReportFonts.load(languageCode: 'ja');
      final zh = await PdfReportFonts.load(languageCode: 'zh');
      expect(ja.fallback.first.fontName, contains('JP'));
      expect(zh.fallback.first.fontName, contains('SC'));
      expect(identical(ja, zh), isFalse);
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

    test('renders a CJK report without throwing', () async {
      final bytes = await buildResultPdf(
        toolName: '莫尔圆',
        sections: const [
          ResultSection(
            title: '应力',
            values: [ResultValue(label: '剪应力', valueSI: 1)],
          ),
        ],
        precs: NumberPrecisionHelper(),
        system: UnitSystem.si,
        languageCode: 'zh',
        formulaSteps: const ['剪应力 = T·r/J'],
      );
      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });

  group('hasGlyphsFor', () {
    late PdfReportFonts fonts;

    setUp(() async {
      PdfReportFonts.resetCache();
      fonts = await PdfReportFonts.load();
    });

    test('accepts Latin text and the usual engineering symbols', () {
      expect(fonts.hasGlyphsFor('Helical Compression Spring'), isTrue);
      expect(fonts.hasGlyphsFor('45°C'), isTrue);
      expect(fonts.hasGlyphsFor('Träger — Größe'), isTrue);
      expect(fonts.hasGlyphsFor("Théorie de l'élasticité"), isTrue);
    });

    test('accepts Greek and superscripts, which the base face carries', () {
      expect(fonts.hasGlyphsFor('σ = F/A'), isTrue);
      expect(fonts.hasGlyphsFor('τ_max'), isTrue);
      expect(fonts.hasGlyphsFor('mm⁴'), isTrue);
      expect(fonts.hasGlyphsFor('Δθ'), isTrue);
    });

    test('accepts the math operators the CJK fallbacks supply', () {
      // Noto Sans has no Mathematical Operators block; the subsets do, which
      // is why these are drawn as written rather than spelled out in ASCII.
      expect(fonts.hasGlyphsFor('f ≈ √(G/2ρ)'), isTrue);
      expect(fonts.hasGlyphsFor('n ≥ 2'), isTrue);
      expect(fonts.hasGlyphsFor('n ≤ 2'), isTrue);
      expect(fonts.hasGlyphsFor('Σ ≠ ∑'), isTrue);
    });

    test('accepts CJK, which the fallbacks cover', () {
      expect(fonts.hasGlyphsFor('莫尔圆'), isTrue);
      expect(fonts.hasGlyphsFor('機械設計'), isTrue);
      expect(fonts.hasGlyphsFor('Spring 弹簧'), isTrue);
      expect(fonts.hasGlyphsFor('約 2.5 N/mm'), isTrue);
    });

    test('covers every translated string in every locale', () async {
      // The subsets are cut from the .arb files, so a string added without
      // rerunning tool/subset_pdf_fonts.py would silently lose its glyphs.
      for (final locale in const ['en', 'de', 'fr', 'ja', 'zh', 'zh_HK']) {
        final arb = await File('lib/l10n/intl_$locale.arb').readAsString();
        final strings = (jsonDecode(arb) as Map<String, dynamic>).entries.where(
            (e) => e.value is String && !e.key.startsWith('@'));
        final localeFonts =
            await PdfReportFonts.load(languageCode: locale.split('_').first);
        for (final entry in strings) {
          expect(
            localeFonts.hasGlyphsFor(entry.value as String),
            isTrue,
            reason: '$locale/${entry.key} has characters no bundled face '
                'carries — rerun tool/subset_pdf_fonts.py',
          );
        }
      }
    });

    test('still rejects a script no bundled face carries', () {
      // Korean is not a locale here, so its glyphs are genuinely absent — the
      // warning path stays live rather than becoming dead code.
      expect(fonts.hasGlyphsFor('기계 설계'), isFalse);
    });
  });

  group('canRenderReport', () {
    late PdfReportFonts fonts;

    setUp(() async {
      PdfReportFonts.resetCache();
      fonts = await PdfReportFonts.load();
    });

    test('passes for a Latin report with Greek and math symbols', () {
      expect(
        canRenderReport(
          fonts: fonts,
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

    test('passes for a fully CJK report', () {
      expect(
        canRenderReport(
          fonts: fonts,
          toolName: '莫尔圆',
          sections: const [
            ResultSection(
              title: '应力',
              values: [ResultValue(label: '剪应力', value: '約 2.5 N/mm')],
            ),
          ],
          formulaSteps: const ['剪应力 = T·r/J'],
        ),
        isTrue,
      );
    });

    test('reaches section titles, labels, values and formula steps', () {
      // The check has to walk the whole report, not just the tool name.
      const undrawable = '기계';
      expect(
        canRenderReport(
          fonts: fonts,
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: 'Stresses',
              values: [ResultValue(label: undrawable, valueSI: 1)],
            ),
          ],
        ),
        isFalse,
      );
      expect(
        canRenderReport(
          fonts: fonts,
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: undrawable,
              values: [ResultValue(label: 'Shear', valueSI: 1)],
            ),
          ],
        ),
        isFalse,
      );
      expect(
        canRenderReport(
          fonts: fonts,
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: 'Notes',
              values: [ResultValue(label: 'Note', value: undrawable)],
            ),
          ],
        ),
        isFalse,
      );
      expect(
        canRenderReport(
          fonts: fonts,
          toolName: 'Spring',
          sections: const [
            ResultSection(
              title: 'Stresses',
              values: [ResultValue(label: 'Shear', valueSI: 1)],
            ),
          ],
          formulaSteps: const ['$undrawable = T·r/J'],
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
