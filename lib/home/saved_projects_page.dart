import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
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
  const _ProjectCard({
    required this.project,
    required this.store,
    required this.onRename,
    required this.onDelete,
  });

  final SavedProject project;
  final SavedProjects store;
  final Future<void> Function(BuildContext, SavedProjects, SavedProject)
      onRename;
  final Future<void> Function(BuildContext, SavedProjects, SavedProject)
      onDelete;

  @override
  Widget build(BuildContext context) {
    Tool? tool;
    try {
      tool = ToolLibrary.shared.item(project.toolId, context);
    } catch (_) {
      // A project saved against a tool this build no longer ships. Hiding the
      // row keeps the rest of the list usable; the record stays on disk in
      // case the tool comes back.
      return const SizedBox.shrink();
    }
    final resolvedTool = tool;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(project.name, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resolvedTool.title, style: theme.textTheme.bodySmall),
            if (project.inputs.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: context.tokens.space1),
                child: Text(
                  project.inputs.entries
                      .map((item) => '${item.key}: ${item.value}')
                      .join(', '),
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
          onSelected: (value) {
            if (value == 'rename') {
              onRename(context, store, project);
            } else if (value == 'delete') {
              onDelete(context, store, project);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: Text(S.of(context).Rename_Project),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(S.of(context).Delete),
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
}
