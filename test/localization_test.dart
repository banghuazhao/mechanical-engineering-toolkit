import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the invariant that keeps the app translatable: every locale carries
/// exactly the same key set, and no key is left without a translation.
void main() {
  final locales = {
    'en': File('lib/l10n/intl_en.arb'),
    'zh': File('lib/l10n/intl_zh.arb'),
    'zh_HK': File('lib/l10n/intl_zh_HK.arb'),
  };

  Map<String, String> load(File f) {
    final raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    return {
      for (final e in raw.entries)
        if (!e.key.startsWith('@')) e.key: e.value as String,
    };
  }

  test('every locale defines the same keys', () {
    final byLocale = {
      for (final e in locales.entries) e.key: load(e.value),
    };
    final reference = byLocale['en']!.keys.toSet();

    for (final entry in byLocale.entries) {
      final keys = entry.value.keys.toSet();
      expect(keys.difference(reference), isEmpty,
          reason: '${entry.key} has keys missing from en');
      expect(reference.difference(keys), isEmpty,
          reason: '${entry.key} is missing keys present in en');
    }
  });

  test('no translation is left empty', () {
    for (final entry in locales.entries) {
      load(entry.value).forEach((key, value) {
        expect(value.trim(), isNotEmpty,
            reason: '${entry.key}: "$key" has no value');
      });
    }
  });

  test('Chinese locales are actually translated', () {
    final en = load(locales['en']!);
    // A handful of keys are proper nouns or symbols that stay identical
    // across locales; everything else must differ from the English text.
    const sharedVerbatim = {'Shows', 'Instant_Face', 'SwiftComp'};

    for (final name in ['zh', 'zh_HK']) {
      final translated = load(locales[name]!);
      final untranslated = <String>[
        for (final key in en.keys)
          if (!sharedVerbatim.contains(key) && translated[key] == en[key]) key,
      ];
      expect(untranslated, isEmpty,
          reason: '$name still shows English for: $untranslated');
    }
  });
}
