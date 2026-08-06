import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';

void main() {
  group('foldForSearch', () {
    test('lowercases', () {
      expect(foldForSearch('Buckling Load'), 'buckling load');
    });

    test('strips French accents', () {
      expect(foldForSearch('Élasticité'), 'elasticite');
      expect(foldForSearch('Cisaillement à l\'âme'), "cisaillement a l'ame");
      expect(foldForSearch('Cœur'), 'coeur');
    });

    test('strips German umlauts and folds sharp s', () {
      expect(foldForSearch('Träger'), 'trager');
      expect(foldForSearch('Knickstäbe'), 'knickstabe');
      expect(foldForSearch('Größe'), 'grosse');
    });

    test('leaves CJK untouched', () {
      expect(foldForSearch('复合材料'), '复合材料');
      expect(foldForSearch('機械設計'), '機械設計');
    });

    test('leaves unaccented text untouched apart from case', () {
      expect(foldForSearch('von Mises'), 'von mises');
    });
  });

  group('searchTerms', () {
    test('splits on whitespace and drops empties', () {
      expect(searchTerms('beam deflection'), ['beam', 'deflection']);
      expect(searchTerms('  beam   deflection  '), ['beam', 'deflection']);
    });

    test('an empty or whitespace-only query yields no terms', () {
      expect(searchTerms(''), isEmpty);
      expect(searchTerms('   '), isEmpty);
    });

    test('folds each term', () {
      expect(searchTerms('Élasticité Linéaire'), ['elasticite', 'lineaire']);
    });

    test('a CJK query comes back as one term', () {
      expect(searchTerms('复合材料'), ['复合材料']);
    });
  });

  // The page's matcher is private, but it is a pure function of the folded
  // haystack and the query terms, so the behaviour it guarantees can be
  // pinned here directly.
  group('term matching semantics', () {
    bool matches(String query, List<String> fields) {
      final terms = searchTerms(query);
      if (terms.isEmpty) return true;
      final haystack = foldForSearch(fields.join(' '));
      return terms.every(haystack.contains);
    }

    test('every term must be present, in any order', () {
      const fields = ['Deflections and Slopes of Simple Beams', 'Beam'];
      expect(matches('beam deflection', fields), isTrue);
      expect(matches('deflection beam', fields), isTrue);
      expect(matches('beam torsion', fields), isFalse);
    });

    test('a term may come from the section title rather than the tool', () {
      // What lets a user pull up a whole category by its localized name.
      expect(
        matches('composite', ['Rule of Mixtures', 'Composite Material']),
        isTrue,
      );
      expect(
        matches('复合', ['混合律', '复合材料']),
        isTrue,
      );
    });

    test('a term may come from the English keywords in any locale', () {
      // Keywords stay English on purpose; an engineer searching "torque"
      // should find the tool whatever the UI language is.
      expect(
        matches('torque', ['扭转公式', '材料力学', 'torque', 'shaft']),
        isTrue,
      );
    });

    test('accented and unaccented queries find the same tool', () {
      const fields = ['Théorie de l\'élasticité', 'Élasticité'];
      expect(matches('elasticite', fields), isTrue);
      expect(matches('élasticité', fields), isTrue);
    });

    test('an empty query matches everything', () {
      expect(matches('', ['anything']), isTrue);
    });
  });
}
