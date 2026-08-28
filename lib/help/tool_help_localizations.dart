import 'package:flutter/widgets.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content_de.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content_fr.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content_ja.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content_zh.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content_zh_hk.dart';

/// Localized tool explanations, keyed by locale tag then by tool id.
///
/// Filled in as translations land. Unlike the `.arb` files, which a test holds
/// to exact key parity, this is allowed to be partial: [helpFor] falls back
/// per *tool*, so a half-translated language shows its own text where it has
/// it and English where it does not, rather than all-or-nothing.
///
/// These strings never reach the PDF exporter — the sheet is on-screen, and
/// its share action hands plain text to the system — so they are free of the
/// glyph-coverage limit that constrains the bundled `.arb` wording.
const Map<String, Map<int, ToolHelp>> localizedToolHelp = {
  'de': toolHelpDe,
  'fr': toolHelpFr,
  'ja': toolHelpJa,
  'zh': toolHelpZh,
  'zh_HK': toolHelpZhHk,
};

/// The tag [localizedToolHelp] is keyed by.
///
/// Chinese splits on script rather than language: the app resolves traditional
/// locales to `zh-HK` and simplified ones to `zh`, and the two are not
/// interchangeable to a reader.
String helpLocaleTag(Locale locale) {
  if (locale.languageCode == 'zh') {
    return locale.countryCode == 'HK' ? 'zh_HK' : 'zh';
  }
  return locale.languageCode;
}

/// Tags to try, in order, for [locale].
///
/// Traditional Chinese falls back to Simplified before English. Both are
/// filled in now, so the chain is dormant — it stays because it is the right
/// order should either drift out of step with the other.
List<String> _fallbackChain(Locale locale) {
  final tag = helpLocaleTag(locale);
  return tag == 'zh_HK' ? const ['zh_HK', 'zh'] : [tag];
}

/// The explanation for [toolId] in [locale], falling back through
/// [_fallbackChain] and finally to English. Null only when the tool has no
/// entry in any language.
ToolHelp? helpFor(int toolId, Locale locale) {
  for (final tag in _fallbackChain(locale)) {
    final help = localizedToolHelp[tag]?[toolId];
    if (help != null) return help;
  }
  return toolHelp[toolId];
}
