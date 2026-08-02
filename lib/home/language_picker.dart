import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:provider/provider.dart';

String languageLabel(BuildContext context, AppLanguage language) =>
    language == AppLanguage.system
        ? S.of(context).System_Default
        : language.nativeName;

/// Bottom sheet that switches the app language; the choice applies immediately
/// and is remembered across launches.
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Consumer<LanguagePreference>(
        builder: (context, languagePref, _) {
          final primary = Theme.of(context).colorScheme.primary;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    S.of(context).Language,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                ...AppLanguage.values.map((language) {
                  final isSelected = languagePref.language == language;
                  return ListTile(
                    title: Text(
                      languageLabel(context, language),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected ? primary : null,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: primary, size: 20)
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      languagePref.set(language);
                      Navigator.pop(sheetContext);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    ),
  );
}
