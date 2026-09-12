import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';

/// Things a keyboard shortcut or a Mac menu item can ask the visible screen
/// to do.
///
/// The menu bar lives above the navigator and knows nothing about which tool
/// is open, so it cannot call a page's `_calculate` directly. Instead the
/// widgets that already own each action — the Calculate button, the share
/// and save buttons on a result page, the "?" — register it here while they
/// are on screen, and the menu asks whoever is frontmost.
enum AppCommand {
  /// Run the open tool's calculation (⌘↩).
  calculate,

  /// Open the share/export picker on the visible result (⌘E).
  share,

  /// Keep the visible result in a project (⌘S).
  saveToProject,

  /// Open the open tool's explanation (⌘?).
  help,

  /// Focus the tool library's search field (⌘F).
  findTool,
}

class _Registration {
  _Registration(this.command, this.state);

  final AppCommand command;
  final _AppCommandHandlerState state;
}

/// The registry behind [AppCommandHandler].
///
/// A [ChangeNotifier] so the Mac menu bar can grey out commands that nothing
/// on screen answers — which changes both when handlers come and go and when
/// a route is pushed over them, hence [routeObserver].
class AppCommands extends ChangeNotifier {
  AppCommands._();

  static final AppCommands instance = AppCommands._();

  final List<_Registration> _registrations = [];
  bool _notifyScheduled = false;

  /// The [RouteSettings.name] of the root navigator's top route, as last
  /// reported to [routeObserver]. Lets the menu bar avoid pushing a second
  /// copy of a page that is already showing.
  String? get topRouteName => _topRouteName;
  String? _topRouteName;

  /// Tells the registry the route stack moved, so enabled states are
  /// re-evaluated. Attach to every navigator whose routes can cover a
  /// registered handler.
  late final NavigatorObserver routeObserver = _RouteChangeObserver(this);

  void _add(_Registration registration) {
    _registrations.add(registration);
    _scheduleNotify();
  }

  void _remove(_AppCommandHandlerState state) {
    _registrations.removeWhere((r) => identical(r.state, state));
    _scheduleNotify();
  }

  /// Registration happens during build, and so does a navigator's history
  /// update; listeners are told a frame later rather than in the middle of
  /// either.
  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// The callback that should answer [command] right now: the newest handler
  /// whose route is the one on top. Null when nothing visible offers it.
  VoidCallback? handlerFor(AppCommand command) {
    for (final registration in _registrations.reversed) {
      if (registration.command != command) continue;
      final state = registration.state;
      if (!state.mounted || !state.widget.enabled) continue;
      if (!(state._route?.isCurrent ?? true)) continue;
      return state.widget.onInvoke;
    }
    return null;
  }

  bool canInvoke(AppCommand command) => handlerFor(command) != null;

  /// Runs [command] if something on screen answers it. Returns whether it
  /// ran.
  bool invoke(AppCommand command) {
    final handler = handlerFor(command);
    handler?.call();
    return handler != null;
  }

  @visibleForTesting
  int get registrationCount => _registrations.length;
}

class _RouteChangeObserver extends NavigatorObserver {
  _RouteChangeObserver(this.commands);

  final AppCommands commands;

  void _changed(Route<dynamic>? top) {
    commands._topRouteName = top?.settings.name;
    commands._scheduleNotify();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _changed(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _changed(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _changed(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _changed(newRoute);
}

/// Offers [onInvoke] as the answer to [command] while [child] is on the
/// frontmost route.
class AppCommandHandler extends StatefulWidget {
  const AppCommandHandler({
    super.key,
    required this.command,
    required this.onInvoke,
    required this.child,
    this.enabled = true,
  });

  final AppCommand command;
  final VoidCallback onInvoke;
  final bool enabled;
  final Widget child;

  @override
  State<AppCommandHandler> createState() => _AppCommandHandlerState();
}

class _AppCommandHandlerState extends State<AppCommandHandler> {
  ModalRoute<Object?>? _route;
  _Registration? _registration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Captured here, during build, rather than looked up when the command
    // fires: the lookup registers a dependency, which is only legitimate
    // while building.
    _route = ModalRoute.of(context);
    if (_registration == null) {
      _registration = _Registration(widget.command, this);
      AppCommands.instance._add(_registration!);
    }
  }

  @override
  void didUpdateWidget(AppCommandHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.command != widget.command ||
        oldWidget.enabled != widget.enabled) {
      AppCommands.instance._remove(this);
      _registration = _Registration(widget.command, this);
      AppCommands.instance._add(_registration!);
    }
  }

  @override
  void dispose() {
    AppCommands.instance._remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The label a shortcut is shown with in a tooltip, on the platforms where
/// the app offers one. Null elsewhere, so a phone's tooltip does not promise
/// a key it has no keyboard for.
String? shortcutHint(AppCommand command) {
  if (!AppPlatform.current.hasMenuBar) return null;
  return switch (command) {
    AppCommand.calculate => '⌘↩',
    AppCommand.share => '⌘E',
    AppCommand.saveToProject => '⌘S',
    AppCommand.help => '⌘?',
    AppCommand.findTool => '⌘F',
  };
}

/// Appends the shortcut for [command] to [label] where there is one.
String withShortcutHint(String label, AppCommand command) {
  final hint = shortcutHint(command);
  return hint == null ? label : '$label ($hint)';
}

/// The Calculate button every tool's input page carries.
///
/// One widget rather than fifty copies of the same `FloatingActionButton` so
/// that ⌘↩ reaches every calculator without each page wiring it up: the
/// button registers itself as the answer to [AppCommand.calculate] for as
/// long as its page is the one in front.
class CalculateButton extends StatelessWidget {
  const CalculateButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = S.of(context).Calculate;
    return AppCommandHandler(
      command: AppCommand.calculate,
      onInvoke: onPressed,
      child: FloatingActionButton.extended(
        key: const Key('calculateButton'),
        onPressed: onPressed,
        tooltip: withShortcutHint(label, AppCommand.calculate),
        icon: const Icon(Icons.analytics_rounded),
        label: Text(label),
      ),
    );
  }
}
