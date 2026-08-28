import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/recorded_inputs.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/pdf_export.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:provider/provider.dart';

/// Asks for a project name, pre-filled with [initialName] when renaming.
/// Returns the trimmed name, or null if the user backed out.
Future<String?> promptForProjectName(
  BuildContext context, {
  String? initialName,
  String? title,
}) {
  final controller = TextEditingController(text: initialName ?? '');
  final formKey = GlobalKey<FormState>();

  // Deliberately NOT AlertDialog.adaptive: on iOS that builds a Cupertino
  // dialog, which is not a Material ancestor, and Material's TextFormField
  // asserts without one. The delete confirmation below has no field, so it can
  // stay adaptive.
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title ?? S.of(context).Save_as_Project),
      content: Form(
        key: formKey,
        child: TextFormField(
          key: const Key('projectNameField'),
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: S.of(context).Project_Name,
            hintText: S.of(context).Project_Name_Hint,
          ),
          validator: (value) => (value ?? '').trim().isEmpty
              ? S.of(context).Project_Name_Required
              : null,
          onFieldSubmitted: (_) {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(dialogContext, controller.text.trim());
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(S.of(context).Cancel),
        ),
        FilledButton(
          key: const Key('confirmProjectName'),
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(dialogContext, controller.text.trim());
            }
          },
          child: Text(S.of(context).Save),
        ),
      ],
    ),
  );
}

class SavedProjectsPage extends StatelessWidget {
  const SavedProjectsPage({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    SavedProjects store,
    SavedProject project,
  ) async {
    final shouldDelete = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        icon: const Icon(Icons.delete_rounded),
        title: Text(S.of(context).Delete_Project_Question),
        content: Text(S.of(context).Delete_Project_Description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(S.of(context).Cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(S.of(context).Delete),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      // Delete first: the haptic is a side effect, and awaiting it before
      // mutating would make the state change depend on a platform reply.
      store.delete(project.id);
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> _rename(
    BuildContext context,
    SavedProjects store,
    SavedProject project,
  ) async {
    final name = await promptForProjectName(
      context,
      initialName: project.name,
      title: S.of(context).Rename_Project,
    );
    if (name == null || !context.mounted) return;
    store.rename(project.id, name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).Project_Updated(name))),
    );
  }

  /// Renders every calculation in [project] as one document and hands it to
  /// the share sheet.
  ///
  /// [origin] anchors iPadOS's popover — see [shareResultPdf], where passing
  /// nothing leaves the sheet mispositioned over a screen that has stopped
  /// responding.
  static Future<void> exportReport(
    BuildContext context,
    SavedProject project,
    Rect origin,
  ) async {
    final l10n = S.of(context);
    if (project.reportable.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.Project_Report_Empty)));
      return;
    }

    final precs = context.read<NumberPrecisionHelper>();
    final system = context.read<UnitSystemPreference>().system;
    final languageCode = Localizations.localeOf(context).languageCode;
    final items = [
      for (final entry in project.entries)
        ReportItem(
          // The tool's name as it reads *now* where the tool is still
          // installed, so a report follows the reader's language; the
          // snapshot's frozen copy is the fallback.
          title: _toolName(context, entry) ??
              entry.snapshot?.toolName ??
              l10n.Result,
          sections: entry.snapshot?.sections ?? const [],
          formulaSteps: entry.snapshot?.formulaSteps ?? const [],
          // The inputs as a reader should see them, not as they are stored:
          // an entry with no snapshot has nothing but these to show.
          inputs: displayInputs(context, entry.inputs),
          capturedAt: entry.snapshot?.capturedAt ?? entry.addedAt,
        ),
    ];

    final fonts = await PdfReportFonts.load(languageCode: languageCode);
    final complete = canRenderProjectReport(
      fonts: fonts,
      projectName: project.name,
      items: items,
    );
    if (!complete && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).PDF_Missing_Characters)),
      );
    }

    final bytes = await buildProjectReportPdf(
      projectName: project.name,
      items: items,
      precs: precs,
      system: system,
      fonts: fonts,
    );
    await shareResultPdf(project.name, bytes, origin: origin);
  }

  /// The live title of the tool an entry came from, or null if this build no
  /// longer ships it.
  static String? _toolName(BuildContext context, ProjectEntry entry) {
    try {
      return ToolLibrary.shared.item(entry.toolId, context).title;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).Saved_Projects)),
      body: Consumer<SavedProjects>(
        builder: (context, store, _) {
          final projects = store.projects;
          if (projects.isEmpty) {
            return AppEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: S.of(context).No_Saved_Projects_Yet,
              message: S.of(context).No_Saved_Projects_Message,
            );
          }
          return AppContent(
            padding: EdgeInsets.symmetric(vertical: context.tokens.space2),
            child: ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: projects.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: context.tokens.space2),
              itemBuilder: (context, index) =>
                  _ProjectCard(project: projects[index], store: store,
                      onRename: _rename, onDelete: _confirmDelete),
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  _ProjectCard({
    required this.project,
    required this.store,
    required this.onRename,
    required this.onDelete,
  });

  /// Handle on the card's box, for anchoring the iPad share popover.
  final GlobalKey _cardKey = GlobalKey();

  final SavedProject project;
  final SavedProjects store;
  final Future<void> Function(BuildContext, SavedProjects, SavedProject)
      onRename;
  final Future<void> Function(BuildContext, SavedProjects, SavedProject)
      onDelete;

  /// Anchors iPadOS's share popover on the card the user acted on.
  Rect _cardOrigin() {
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return const Rect.fromLTWH(0, 0, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    Tool? tool;
    try {
      tool = ToolLibrary.shared.item(project.toolId, context);
    } catch (_) {
      // A project whose first calculation used a tool this build no longer
      // ships. Hiding the row keeps the rest of the list usable; the record
      // stays on disk in case the tool comes back.
      return const SizedBox.shrink();
    }
    final resolvedTool = tool;
    final theme = Theme.of(context);
    final l10n = S.of(context);
    final entries = project.entries;
    final hasResults = project.reportable.isNotEmpty;

    return Card(
      key: _cardKey,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(project.name, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // One calculation reads as its tool's name; several read as a
            // count and the tools they came from, because the name of the
            // first says nothing useful about the rest.
            Text(
              entries.length == 1
                  ? resolvedTool.title
                  : '${l10n.Project_Calculations('${entries.length}')} · '
                      '${_entrySummary(context, entries)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            if (entries.length == 1 && project.inputs.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: context.tokens.space1),
                child: Text(
                  describeInputs(context, project.inputs),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            Text(
              DateFormat.yMMMd().add_jm().format(project.updatedAt),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          key: const Key('projectMenu'),
          onSelected: (value) {
            switch (value) {
              case 'rename':
                onRename(context, store, project);
              case 'report':
                SavedProjectsPage.exportReport(context, project, _cardOrigin());
              case 'delete':
                onDelete(context, store, project);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: Text(l10n.Rename_Project),
            ),
            PopupMenuItem(
              value: 'report',
              // Offered but disabled with nothing to report: the menu is where
              // a user goes looking for the feature, and an item that is
              // simply absent teaches them nothing about why.
              enabled: hasResults,
              child: Text(l10n.Export_Report),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(l10n.Delete),
            ),
          ],
        ),
        onTap: () => resolvedTool.action(
          context,
          resolvedTool.title,
          project.toolId,
          initialInputs: project.inputs,
        ),
      ),
    );
  }

  /// The distinct tools a multi-calculation project draws on.
  static String _entrySummary(
    BuildContext context,
    List<ProjectEntry> entries,
  ) {
    final names = <String>{};
    for (final entry in entries) {
      final name = SavedProjectsPage._toolName(context, entry) ??
          entry.snapshot?.toolName;
      if (name != null) names.add(name);
    }
    return names.join(', ');
  }
}
