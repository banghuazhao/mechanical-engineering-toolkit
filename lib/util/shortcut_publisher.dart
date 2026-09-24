import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/util/shortcut_bridge.dart';
import 'package:provider/provider.dart';

/// How many recent tools the "Recent Tools" widget is given.
///
/// The large widget draws eight; the few spare let it stay full after the
/// duplicates are collapsed on the native side.
const int _kRecentToolLimit = 12;

/// Keeps the Home Screen widgets, the Shortcuts "Open Tool" picker and the
/// Android launcher shortcuts in step with the app.
///
/// Sits in the widget tree rather than beside it because everything it
/// publishes needs a `BuildContext`: the tool titles and category names come
/// from `S.of(context)`, so switching the app's language rewrites the
/// widget's contents, and whether a tool counts as locked comes from
/// [PremiumGate], so buying Premium clears the padlocks.
///
/// Publishing is driven by rebuilds: the providers watched in [build] are
/// exactly the things that can change what the widget should say, and each
/// rebuild schedules a publish that no-ops unless something actually moved.
class ShortcutPublisher extends StatefulWidget {
  const ShortcutPublisher({super.key, required this.child});

  final Widget child;

  /// How long the first publish waits after the first frame.
  ///
  /// Not a performance tweak. On macOS the first access to the App Group
  /// container can raise the system's "would like to access data from other
  /// apps" prompt, and while that sits unanswered the app's preferences
  /// daemon is stalled — which blocks the next `NSUserDefaults` read on the
  /// main thread, AppKit's own included, and the window stays blank. Letting
  /// the app draw first means the user meets that prompt over a working
  /// window rather than a black rectangle. See the README section on the App
  /// Group.
  static const firstPublishDelay = Duration(milliseconds: 1500);

  @override
  State<ShortcutPublisher> createState() => _ShortcutPublisherState();
}

class _ShortcutPublisherState extends State<ShortcutPublisher> {
  /// What was last handed to the native side, so an unrelated rebuild does
  /// not re-encode sixty-six tools and wake the widgets for nothing.
  List<ShortcutToolSummary>? _publishedTools;
  List<int>? _publishedFavorites;
  List<int>? _publishedRecents;

  bool _publishScheduled = false;
  bool _publishedOnce = false;

  @override
  Widget build(BuildContext context) {
    if (ShortcutBridge.isSupported) {
      // Watched for their side effect: a change in any of them changes what
      // the widget should show, and rebuilding is what schedules the publish.
      context.watch<Favorites>();
      context.watch<ToolHistory>();
      PremiumGate.watch(context);
      _schedulePublish();
    }
    return widget.child;
  }

  /// Defers the publish to after this frame.
  ///
  /// Reading the tool library builds all sixty-six `Tool` records, and
  /// [PremiumGate] is read again inside the loop; doing that inside [build]
  /// would put a channel call on the frame that is currently laying out.
  void _schedulePublish() {
    if (_publishScheduled) return;
    _publishScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_publishedOnce) {
        await Future<void>.delayed(ShortcutPublisher.firstPublishDelay);
      }
      _publishScheduled = false;
      if (!mounted) return;
      _publishedOnce = true;
      await _publish();
    });
  }

  Future<void> _publish() async {
    final gate = PremiumGate.read(context);
    final tools = [
      for (final tool in ToolLibrary.shared.getTools(context))
        ShortcutToolSummary(
          id: tool.id,
          title: tool.title,
          categoryId: tool.type.name,
          category: toolCategoryTitle(context, tool.type),
          locked: gate.isToolLocked(tool.id),
        ),
    ];

    final favorites = context.read<Favorites>().items;

    // Newest first, and only the tool ids — the widget lists tools, not
    // calculations, and the inputs of a history entry are none of its
    // business.
    final recents = <int>[];
    for (final entry in context.read<ToolHistory>().entries) {
      if (recents.length >= _kRecentToolLimit) break;
      if (!recents.contains(entry.toolId)) recents.add(entry.toolId);
    }

    if (listEquals(_publishedTools, tools) &&
        listEquals(_publishedFavorites, favorites) &&
        listEquals(_publishedRecents, recents)) {
      return;
    }

    final published = await ShortcutBridge.publishSnapshot(
      tools: tools,
      favoriteIds: favorites,
      recentIds: recents,
    );
    if (!published) {
      // No App Group to write to. Leaving the cached copies null means the
      // next change tries again rather than concluding it already published.
      return;
    }
    _publishedTools = tools;
    _publishedFavorites = favorites;
    _publishedRecents = recents;
  }
}
