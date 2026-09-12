import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_content.dart';
import 'package:mechanical_engineering_toolkit/help/tool_help_sheet.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';

/// The "?" in a tool's app bar, opening its long-form explanation.
///
/// Renders nothing for a tool with no entry yet, so a half-written library
/// shows a button only where there is something behind it.
class ToolHelpButton extends StatelessWidget {
  const ToolHelpButton({
    super.key,
    required this.toolId,
    required this.toolTitle,
  });

  final int toolId;
  final String toolTitle;

  @override
  Widget build(BuildContext context) {
    if (!toolHelp.containsKey(toolId)) return const SizedBox.shrink();
    void open() => showToolHelp(context, toolId: toolId, toolTitle: toolTitle);
    return AppCommandHandler(
      command: AppCommand.help,
      onInvoke: open,
      child: IconButton(
        key: const Key('toolHelp'),
        tooltip: withShortcutHint(S.of(context).About_This_Tool, AppCommand.help),
        icon: const Icon(Icons.help_outline_rounded),
        onPressed: open,
      ),
    );
  }
}
