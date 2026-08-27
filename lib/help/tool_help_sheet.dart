import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';

/// Opens the long-form explanation for [toolId].
Future<void> showToolHelp(
  BuildContext context, {
  required int toolId,
  required String toolTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    // Tall by default: this is reading material, and a sheet that opens at a
    // third of the screen would be dismissed before it was read.
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => ToolHelpView(
        toolId: toolId,
        toolTitle: toolTitle,
        scrollController: controller,
      ),
    ),
  );
}

/// Renders a [ToolHelp] as a readable, copyable page.
class ToolHelpView extends StatelessWidget {
  const ToolHelpView({
    super.key,
    required this.toolId,
    required this.toolTitle,
    this.scrollController,
  });

  final int toolId;
  final String toolTitle;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final help = toolHelp[toolId];

    if (help == null) {
      return Padding(
        padding: EdgeInsets.all(tokens.space4),
        child: Text(l10n.Help_Unavailable, style: theme.textTheme.bodyMedium),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              tokens.space4, 0, tokens.space2, tokens.space2),
          child: Row(
            children: [
              Expanded(
                child: Text(toolTitle, style: theme.textTheme.titleLarge),
              ),
              IconButton(
                key: const Key('copyToolHelp'),
                tooltip: l10n.Copy,
                icon: const Icon(Icons.copy_rounded),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(
                      text: toolHelpAsText(help, toolTitle)));
                  if (!context.mounted) return;
                  // maybeOf: the copy itself has already happened, and the
                  // confirmation is not worth asserting over if this sheet is
                  // ever shown somewhere without a Scaffold under it.
                  ScaffoldMessenger.maybeOf(context)
                    ?..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(l10n.Copied)));
                },
              ),
              IconButton(
                key: const Key('shareToolHelp'),
                tooltip: l10n.Share_Results,
                icon: const Icon(Icons.share_rounded),
                onPressed: () => shareResult(
                  toolTitle,
                  toolHelpAsText(help, toolTitle).split('\n'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
                tokens.space4, tokens.space4, tokens.space4, tokens.space4 * 2),
            children: [
              Text(help.summary, style: theme.textTheme.bodyMedium),
              if (help.diagram != null) ...[
                SizedBox(height: tokens.space4),
                // A sign convention is far easier to show than to describe.
                //
                // The assets are opaque line art on a near-white ground, so
                // they are clipped into a rounded figure rather than left to
                // sit on the sheet as a bare white rectangle in dark mode.
                // Capped at 160: the sources are 300 px, and blowing them up
                // further only makes them soft.
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: Image.asset(help.diagram!, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
              if (help.formulas.isNotEmpty) ...[
                _Heading(l10n.Formula),
                for (final formula in help.formulas)
                  _FormulaBlock(formula: formula),
              ],
              if (help.symbols.isNotEmpty) ...[
                _Heading(l10n.Help_Symbols),
                _SymbolTable(symbols: help.symbols),
              ],
              if (help.notes.isNotEmpty) ...[
                _Heading(l10n.Help_Assumptions),
                for (final note in help.notes) _Bullet(text: note),
              ],
              if (help.references.isNotEmpty) ...[
                _Heading(l10n.Help_References),
                for (final reference in help.references)
                  _Bullet(text: reference),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: context.tokens.space4 * 1.5, bottom: context.tokens.space2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _FormulaBlock extends StatelessWidget {
  const _FormulaBlock({required this.formula});

  final HelpFormula formula;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = formula.caption;
    return Padding(
      padding: EdgeInsets.only(bottom: context.tokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (caption != null) ...[
            Text(caption,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            SizedBox(height: context.tokens.space1),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.tokens.space3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            // A long equation is wider than a phone; let it scroll rather than
            // overflow, and fall back to the plain form if the TeX will not
            // parse, so a typo in one entry cannot blank the whole sheet.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                formula.tex,
                mathStyle: MathStyle.display,
                textStyle: theme.textTheme.titleMedium,
                onErrorFallback: (_) => Text(
                  formula.plain,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SymbolTable extends StatelessWidget {
  const _SymbolTable({required this.symbols});

  final List<HelpSymbol> symbols;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final symbol in symbols)
          Padding(
            padding: EdgeInsets.only(bottom: context.tokens.space2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    symbol.symbol,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    symbol.unit == null
                        ? symbol.meaning
                        : '${symbol.meaning}  (${symbol.unit})',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: context.tokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: theme.textTheme.bodyMedium),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// The sheet as plain text, for the copy and share actions.
///
/// Equations go out in their [HelpFormula.plain] form: TeX pasted into an
/// email is unreadable, and the point of sharing is that someone else can read
/// it without this app.
String toolHelpAsText(ToolHelp help, String toolTitle) {
  final buffer = StringBuffer()
    ..writeln(toolTitle)
    ..writeln()
    ..writeln(help.summary);

  if (help.formulas.isNotEmpty) {
    buffer.writeln();
    for (final formula in help.formulas) {
      final caption = formula.caption;
      buffer.writeln(caption == null
          ? '  ${formula.plain}'
          : '  $caption: ${formula.plain}');
    }
  }
  if (help.symbols.isNotEmpty) {
    buffer..writeln()..writeln('Symbols');
    for (final symbol in help.symbols) {
      final unit = symbol.unit;
      buffer.writeln('  ${symbol.symbol} — ${symbol.meaning}'
          '${unit == null ? '' : ' ($unit)'}');
    }
  }
  if (help.notes.isNotEmpty) {
    buffer..writeln()..writeln('Assumptions & limits');
    for (final note in help.notes) {
      buffer.writeln('  - $note');
    }
  }
  if (help.references.isNotEmpty) {
    buffer..writeln()..writeln('References');
    for (final reference in help.references) {
      buffer.writeln('  - $reference');
    }
  }
  return buffer.toString().trimRight();
}
