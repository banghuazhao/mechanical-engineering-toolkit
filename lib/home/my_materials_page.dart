import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_library.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Every preset library in one place: the user's own entries to add, edit
/// and delete, the built-ins to browse and copy from, and a way to carry the
/// custom ones to another device.
///
/// The pickers inside the tools can do all of the editing too — this page is
/// for looking after the collection rather than for filling in a field.
class MyMaterialsPage extends StatefulWidget {
  const MyMaterialsPage({super.key});

  @override
  State<MyMaterialsPage> createState() => _MyMaterialsPageState();
}

class _MyMaterialsPageState extends State<MyMaterialsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  final _menuKey = GlobalKey();

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  int _customCount(MaterialLibrary library) =>
      library.isotropic.items.length +
      library.laminae.items.length +
      library.fluids.items.length +
      library.thermal.items.length;

  void _snack(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _copyExport() async {
    final l10n = S.of(context);
    final library = context.read<MaterialLibrary>();
    final count = _customCount(library);
    if (count == 0) return _snack(l10n.Nothing_To_Export);
    await Clipboard.setData(ClipboardData(text: library.exportJson()));
    _snack(l10n.Presets_Export_Copied(count));
  }

  Future<void> _shareExport() async {
    final l10n = S.of(context);
    final library = context.read<MaterialLibrary>();
    if (_customCount(library) == 0) return _snack(l10n.Nothing_To_Export);
    // iPad and the Mac present the share sheet as a popover, which needs an
    // anchor inside the view.
    final box = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile.fromData(
          // Material names are free text and may well be Chinese or Japanese.
          utf8.encode(library.exportJson()),
          mimeType: 'application/json',
          name: 'me_toolkit_materials.json',
        ),
      ],
      sharePositionOrigin: origin,
    ));
  }

  Future<void> _importFromClipboard() async {
    final l10n = S.of(context);
    final library = context.read<MaterialLibrary>();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      return _snack(l10n.Presets_Import_Invalid);
    }
    try {
      final result = library.importJson(text);
      _snack(l10n.Presets_Imported(result.added, result.skipped));
    } on FormatException {
      _snack(l10n.Presets_Import_Invalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final onBar = Theme.of(context).colorScheme.onPrimary;
    final libraries = <PresetLibrary<Object?>>[
      isotropicPresetLibrary(context),
      laminaPresetLibrary(context),
      fluidPresetLibrary(context),
      thermalPresetLibrary(context),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.My_Materials),
        actions: [
          PopupMenuButton<VoidCallback>(
            key: _menuKey,
            tooltip: l10n.More_Actions,
            onSelected: (action) => action(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _copyExport,
                child: ListTile(
                  leading: const Icon(Icons.copy_all_rounded),
                  title: Text(l10n.Copy_Presets_Export),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _shareExport,
                child: ListTile(
                  leading: const Icon(Icons.ios_share_rounded),
                  title: Text(l10n.Share_Presets_Export),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _importFromClipboard,
                child: ListTile(
                  leading: const Icon(Icons.content_paste_rounded),
                  title: Text(l10n.Import_From_Clipboard),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          // On the primary-coloured app bar, not the surface a TabBar
          // assumes: the default primary label would vanish into it.
          labelColor: onBar,
          unselectedLabelColor: onBar.withValues(alpha: 0.7),
          indicatorColor: onBar,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(text: l10n.Tab_Solids),
            Tab(text: l10n.Tab_Laminae),
            Tab(text: l10n.Tab_Fluids),
            Tab(text: l10n.Tab_Thermal),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabs,
        builder: (context, _) {
          final library = libraries[_tabs.index];
          return FloatingActionButton.extended(
            key: const Key('addMyMaterial'),
            onPressed: () => library.addNew(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(library.addLabel),
          );
        },
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _LibraryTab(library: isotropicPresetLibrary),
          _LibraryTab(library: laminaPresetLibrary),
          _LibraryTab(library: fluidPresetLibrary),
          _LibraryTab(library: thermalPresetLibrary),
        ],
      ),
    );
  }
}

class _LibraryTab<T> extends StatelessWidget {
  const _LibraryTab({required this.library});

  final PresetLibrary<T> Function(BuildContext context) library;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final description = library(context);
    final custom = description.custom(context.watch<MaterialLibrary>()).items;

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            text,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        );

    return AppContent(
      padding: EdgeInsets.zero,
      child: ListView(
        // Clear of the extended FAB.
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          header(l10n.My_Presets),
          if (custom.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l10n.No_Custom_Presets_Message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            for (var i = 0; i < custom.length; i++)
              ListTile(
                title: Text(description.nameOf(custom[i])),
                subtitle: Text(description.subtitleOf(context, custom[i])),
                onTap: () => description.edit(context, i),
                trailing: PresetRowMenu(
                  onEdit: () => description.edit(context, i),
                  onDuplicate: () =>
                      description.duplicateInto(context, custom[i]),
                  onDelete: () => description.confirmDelete(context, i),
                ),
              ),
          const Divider(height: 24),
          header(l10n.Built_In_Presets),
          for (final preset in description.builtIn)
            ListTile(
              title: Text(description.nameOf(preset)),
              subtitle: Text(description.subtitleOf(context, preset)),
              trailing: PresetRowMenu(
                onDuplicate: () => description.duplicateInto(context, preset),
              ),
            ),
        ],
      ),
    );
  }
}
