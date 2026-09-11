import 'package:flutter/widgets.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';

/// Opens [tool], or offers the upgrade if this build does not include it.
///
/// The single door into every calculator. The library, favourites, history,
/// saved projects and the by-major recommendations all reach a tool through
/// here, so a locked tool cannot be opened by finding a different route to it
/// — which is exactly what would happen if each of those screens called
/// [Tool.action] and remembered its own check.
///
/// Nothing is locked on iOS or Android; there this is a direct call through.
Future<void> launchTool(
  BuildContext context,
  Tool tool, {
  Map<String, String>? initialInputs,
}) async {
  if (PremiumGate.read(context).isToolLocked(tool.id)) {
    await showLockedToolUpsell(context, tool);
    return;
  }
  tool.action(context, tool.title, tool.id, initialInputs: initialInputs);
}
