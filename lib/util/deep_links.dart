import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_launcher.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';

/// The scheme registered in both Info.plists.
const String kDeepLinkScheme = 'metoolkit';

/// Routes a `metoolkit://` link from a Home Screen widget tile or a Shortcuts
/// action.
///
/// Mirrors `apple/METoolkitShared/DeepLink.swift`, which is the only thing
/// that builds these URLs. Two forms exist:
///
///   `metoolkit://tool/703`  open that calculator
///   `metoolkit://library`   show the tool library
///
/// Everything goes through [launchTool], so a link cannot become a second
/// door into a tool this build holds behind Premium.
class DeepLinkRouter {
  const DeepLinkRouter(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  Future<void> handle(Uri link) async {
    if (link.scheme != kDeepLinkScheme) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // A tap from outside the app means "start here", so anything the user
    // left open is dismissed first. Without this, opening a tool from a
    // widget would stack it on top of whatever tool was already open, and
    // Back would walk through a history the user never navigated.
    navigator.popUntil((route) => route.isFirst);

    switch (link.host) {
      case 'library':
        return;
      case 'tool':
        await _openTool(link);
      default:
        debugPrint('DeepLinkRouter: unknown destination "$link"');
    }
  }

  Future<void> _openTool(Uri link) async {
    final segments = link.pathSegments;
    if (segments.isEmpty) {
      debugPrint('DeepLinkRouter: "$link" names no tool');
      return;
    }
    final id = int.tryParse(segments.first);
    if (id == null) {
      debugPrint('DeepLinkRouter: "${segments.first}" is not a tool id');
      return;
    }

    // `popUntil` above only schedules the pops, and the context has to be the
    // library's for the pushed route to land on it.
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // A widget placed before a tool was removed can still name it, so the
    // lookup has to tolerate a miss — `ToolLibrary.item` throws on one.
    final tools = ToolLibrary.shared.getTools(context);
    final tool = tools.where((tool) => tool.id == id).firstOrNull;
    if (tool == null) {
      debugPrint('DeepLinkRouter: no tool with id $id');
      return;
    }

    await launchTool(context, tool);
  }
}
