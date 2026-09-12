import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

/// Window width from which a tool shows its results beside its inputs
/// instead of on a page of their own.
///
/// Chosen against the Mac window's default 1100 pt, so a first launch opens
/// side by side, and its 800 pt minimum, so a narrow window falls back to the
/// phone layout rather than squeezing two columns into it. A 12.9" iPad in
/// landscape lands on the wide side too.
const double kToolWorkspaceSplitWidth = 1000;

/// The route every tool opens in: a [MaterialPageRoute] whose page is
/// wrapped in a [ToolWorkspace].
class ToolPageRoute<T> extends MaterialPageRoute<T> {
  ToolPageRoute({required WidgetBuilder builder, super.settings})
      : super(builder: (context) => ToolWorkspace(child: builder(context)));
}

/// Shows a tool's result: beside the inputs on a wide window, as a page of
/// its own everywhere else.
///
/// Every calculator's input page calls this where it used to push its result
/// page, which is what makes the side-by-side layout reach all of them. On a
/// phone it is exactly the push it replaces.
Future<void> showToolResult(BuildContext context, WidgetBuilder builder) async {
  final workspace = context.findAncestorStateOfType<_ToolWorkspaceState>();
  if (workspace != null && workspace._isWide) {
    workspace._show(builder);
    return;
  }
  await Navigator.push(context, MaterialPageRoute(builder: builder));
}

/// Lays a tool's input page out alone, or — once there is a result on a wide
/// window — with the result in a pane to its right.
///
/// The pane appears with the first result rather than waiting empty beside
/// the inputs: a reference table that never produces a result then keeps the
/// full width, and a calculator gains its second column exactly when there is
/// something to put in it.
class ToolWorkspace extends StatefulWidget {
  const ToolWorkspace({super.key, required this.child});

  final Widget child;

  @override
  State<ToolWorkspace> createState() => _ToolWorkspaceState();
}

class _ToolWorkspaceState extends State<ToolWorkspace> {
  /// Keeps the input page's state — every value typed so far — when the
  /// layout switches between one column and two, which moves it in the tree.
  final _inputKey = GlobalKey();

  WidgetBuilder? _pane;

  /// Bumped per result, so each calculation gets a fresh result page rather
  /// than one that remembers the last one's sweep position or scroll offset.
  int _generation = 0;

  bool _isWide = false;

  void _show(WidgetBuilder builder) {
    setState(() {
      _pane = builder;
      _generation++;
    });
  }

  void _close() => setState(() => _pane = null);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _isWide = constraints.maxWidth >= kToolWorkspaceSplitWidth;
        final input = KeyedSubtree(key: _inputKey, child: widget.child);
        final pane = _pane;
        if (!_isWide || pane == null) return input;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: input),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 6,
              child: ToolResultPane(
                onClose: _close,
                // The pane's result page carries the same tool icon Hero as
                // the inputs beside it. Two heroes with one tag in one route
                // is an error the moment the route animates, so the pane's
                // copy sits out of hero flights entirely.
                child: HeroMode(
                  enabled: false,
                  // Its own messenger, or a SnackBar raised in either column
                  // would be shown by both columns' Scaffolds at once.
                  child: ScaffoldMessenger(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: KeyedSubtree(
                        key: ValueKey(_generation),
                        child: Builder(builder: pane),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Marks a result page as living in a [ToolWorkspace] pane rather than on a
/// route of its own.
///
/// Result pages look this up to swap the back arrow — which would close the
/// whole tool, inputs included — for a close button that dismisses just the
/// pane, and to drop the tool icon already showing above the inputs.
class ToolResultPane extends InheritedWidget {
  const ToolResultPane({super.key, required this.onClose, required super.child});

  final VoidCallback onClose;

  static ToolResultPane? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ToolResultPane>();

  @override
  bool updateShouldNotify(ToolResultPane oldWidget) =>
      oldWidget.onClose != onClose;
}

/// The close button a result page shows in place of its back arrow when it
/// is in a pane. Null when it is not.
Widget? resultPaneCloseButton(BuildContext context) {
  final pane = ToolResultPane.maybeOf(context);
  if (pane == null) return null;
  return IconButton(
    key: const Key('closeResultPane'),
    tooltip: S.of(context).Close_Results,
    icon: const Icon(Icons.close_rounded),
    onPressed: pane.onClose,
  );
}
