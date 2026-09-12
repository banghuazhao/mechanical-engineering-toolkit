import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/major_list_page.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_favorites.dart';
import 'package:mechanical_engineering_toolkit/home/tool_history_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/more/app_actions.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_page.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';

/// The Mac app's native menu bar.
///
/// Replaces the Flutter template's `MainMenu.xib`, whose Preferences… and
/// Find… items were wired to nothing. Every item here does what it says:
/// app-level items navigate through [navigatorKey]; the ones that act on the
/// open tool — Calculate, Save to Project, Share, the explanation — go
/// through [AppCommands], and are greyed out when nothing on screen answers
/// them.
///
/// Renders [child] alone on every other platform.
class AppMenuBar extends StatelessWidget {
  const AppMenuBar({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatform.current.hasMenuBar) return child;
    return ListenableBuilder(
      listenable: AppCommands.instance,
      builder: (context, _) => PlatformMenuBar(
        menus: _menus(context),
        child: child,
      ),
    );
  }

  List<PlatformMenuItem> _menus(BuildContext context) {
    final l10n = S.of(context);
    final units = context.watch<UnitSystemPreference>();
    final gate = PremiumGate.watch(context);
    final commands = AppCommands.instance;

    VoidCallback? command(AppCommand command) =>
        commands.canInvoke(command) ? () => commands.invoke(command) : null;

    void open(String name, Widget page) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      // Choosing Settings twice should not stack two Settings pages.
      if (commands.topRouteName == name) return;
      navigator.push(MaterialPageRoute(
        settings: RouteSettings(name: name),
        builder: (context) => page,
      ));
    }

    void toLibrary() =>
        navigatorKey.currentState?.popUntil((route) => route.isFirst);

    void findTool() {
      toLibrary();
      // The library's search field registers once it is the frontmost
      // route again, which is a frame after the pop.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => commands.invoke(AppCommand.findTool),
      );
    }

    // The standard items macOS fills in itself. Asked for by platform,
    // because one that has no Services submenu throws rather than skipping
    // it — and a group with nothing left in it is an error of its own.
    List<PlatformMenuItem> group(List<PlatformProvidedMenuItemType> types) {
      final members = [
        for (final type in types)
          if (PlatformProvidedMenuItem.hasMenu(type))
            PlatformProvidedMenuItem(type: type),
      ];
      return members.isEmpty ? const [] : [PlatformMenuItemGroup(members: members)];
    }

    // Edit commands act on whatever text field has focus, through the same
    // intents the keyboard shortcuts use. With no field focused they do
    // nothing, as a Mac Edit menu does.
    VoidCallback edit(Intent intent) => () {
          final focused = FocusManager.instance.primaryFocus?.context;
          if (focused != null) Actions.maybeInvoke(focused, intent);
        };

    return [
      PlatformMenu(
        // macOS shows the app's own name here whatever the label says.
        label: l10n.ME_Toolkit,
        menus: [
          ...group([PlatformProvidedMenuItemType.about]),
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Settings,
              shortcut: const SingleActivator(LogicalKeyboardKey.comma, meta: true),
              onSelected: () => open('settings', const ToolSettingPage()),
            ),
            if (gate.gatesFeatures)
              PlatformMenuItem(
                label: gate.isEntitled ? l10n.Premium : l10n.Unlock_Premium,
                onSelected: () => open('premium', const RemoveAdsPage()),
              ),
          ]),
          ...group([PlatformProvidedMenuItemType.servicesSubmenu]),
          ...group([
            PlatformProvidedMenuItemType.hide,
            PlatformProvidedMenuItemType.hideOtherApplications,
            PlatformProvidedMenuItemType.showAllApplications,
          ]),
          ...group([PlatformProvidedMenuItemType.quit]),
        ],
      ),
      PlatformMenu(
        label: l10n.Menu_File,
        menus: [
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Calculate,
              shortcut: const SingleActivator(LogicalKeyboardKey.enter, meta: true),
              onSelected: command(AppCommand.calculate),
            ),
          ]),
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Save_To_Project,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
              onSelected: command(AppCommand.saveToProject),
            ),
            PlatformMenuItem(
              label: l10n.Menu_Export,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyE, meta: true),
              onSelected: command(AppCommand.share),
            ),
          ]),
        ],
      ),
      PlatformMenu(
        label: l10n.Menu_Edit,
        menus: [
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Undo,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
              onSelected: edit(const UndoTextIntent(SelectionChangedCause.keyboard)),
            ),
            PlatformMenuItem(
              label: l10n.Menu_Redo,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyZ,
                  meta: true, shift: true),
              onSelected: edit(const RedoTextIntent(SelectionChangedCause.keyboard)),
            ),
          ]),
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Cut,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyX, meta: true),
              onSelected: edit(
                  const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard)),
            ),
            PlatformMenuItem(
              label: l10n.Copy,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyC, meta: true),
              onSelected: edit(CopySelectionTextIntent.copy),
            ),
            PlatformMenuItem(
              label: l10n.Menu_Paste,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyV, meta: true),
              onSelected: edit(const PasteTextIntent(SelectionChangedCause.keyboard)),
            ),
            PlatformMenuItem(
              label: l10n.Menu_Select_All,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyA, meta: true),
              onSelected:
                  edit(const SelectAllTextIntent(SelectionChangedCause.keyboard)),
            ),
          ]),
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Find_Tool,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyF, meta: true),
              onSelected: findTool,
            ),
          ]),
        ],
      ),
      PlatformMenu(
        label: l10n.Menu_View,
        menus: [
          // Two items rather than one toggle: a platform menu item has no
          // check mark, so the current system is shown by being the one
          // that is greyed out.
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Use_SI,
              shortcut: const SingleActivator(LogicalKeyboardKey.digit1,
                  meta: true, shift: true),
              onSelected: units.system == UnitSystem.si
                  ? null
                  : () => units.set(UnitSystem.si),
            ),
            PlatformMenuItem(
              label: l10n.Menu_Use_Imperial,
              shortcut: const SingleActivator(LogicalKeyboardKey.digit2,
                  meta: true, shift: true),
              onSelected: units.system == UnitSystem.imperial
                  ? null
                  : () => units.set(UnitSystem.imperial),
            ),
          ]),
          ...group([PlatformProvidedMenuItemType.toggleFullScreen]),
        ],
      ),
      PlatformMenu(
        label: l10n.Menu_Go,
        menus: [
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Back,
              shortcut: const SingleActivator(LogicalKeyboardKey.bracketLeft,
                  meta: true),
              onSelected: () => navigatorKey.currentState?.maybePop(),
            ),
            PlatformMenuItem(
              label: l10n.Menu_Tool_Library,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyL,
                  meta: true, shift: true),
              onSelected: toLibrary,
            ),
          ]),
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Favorites,
              onSelected: () => open('favorites', const ToolFavoritesPage()),
            ),
            PlatformMenuItem(
              label: l10n.History,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyY, meta: true),
              onSelected: () => open('history', const ToolHistoryPage()),
            ),
            PlatformMenuItem(
              label: l10n.Saved_Projects,
              shortcut: const SingleActivator(LogicalKeyboardKey.keyP,
                  meta: true, shift: true),
              onSelected: () => open('projects', const SavedProjectsPage()),
            ),
            PlatformMenuItem(
              label: l10n.Recommended_by_Major,
              onSelected: () => open('majors', const MajorListPage()),
            ),
          ]),
        ],
      ),
      PlatformMenu(
        label: l10n.Menu_Window,
        menus: [
          ...group([
            PlatformProvidedMenuItemType.minimizeWindow,
            PlatformProvidedMenuItemType.zoomWindow,
          ]),
          ...group([PlatformProvidedMenuItemType.arrangeWindowsInFront]),
        ],
      ),
      PlatformMenu(
        label: l10n.Menu_Help,
        menus: [
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.About_This_Tool,
              shortcut: const CharacterActivator('?', meta: true),
              onSelected: command(AppCommand.help),
            ),
          ]),
          PlatformMenuItemGroup(members: [
            PlatformMenuItem(
              label: l10n.Menu_Send_Feedback,
              onSelected: sendFeedbackEmail,
            ),
            PlatformMenuItem(
              label: l10n.RatethisApp,
              onSelected: openStoreListing,
            ),
          ]),
        ],
      ),
    ];
  }
}
