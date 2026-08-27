import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_snapshot.dart';
import 'package:provider/provider.dart';

/// The id of the tool whose title is [toolName], or null if none matches.
///
/// Result pages name themselves with the same localized string the tool
/// library registers as the tool's title, so the title is a usable key back to
/// the tool. That saves threading a `toolId` through forty result pages, none
/// of which need one for any other purpose — at the cost of a lookup that can
/// miss, which callers must handle.
int? toolIdForName(BuildContext context, String toolName) {
  for (final tool in ToolLibrary.shared.getTools(context)) {
    if (tool.title == toolName) return tool.id;
  }
  return null;
}

/// Keeps a result in a project, asking which one first.
///
/// The inputs come from the newest history entry for the same tool — the
/// calculation that produced this very result, since a tool records its inputs
/// immediately before showing them. Pairing on the tool id rather than simply
/// taking the newest entry is what keeps that safe when the user has wandered
/// through several tools.
Future<void> keepResultInProject(
  BuildContext context, {
  required String toolName,
  required List<ResultSection> sections,
  required List<String> formulaSteps,
}) async {
  final l10n = S.of(context);
  final projects = context.read<SavedProjects>();
  final history = context.read<ToolHistory>();

  // Two ways to identify the tool, because either alone can miss: the title
  // lookup fails for a result page named something the library does not carry,
  // and the history fallback fails when nothing was recorded.
  final toolId = toolIdForName(context, toolName) ??
      (history.entries.isEmpty ? null : history.entries.first.toolId);
  if (toolId == null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.Err_Result_Not_Savable)));
    return;
  }

  Map<String, String> inputs = const {};
  for (final entry in history.entries) {
    if (entry.toolId != toolId) continue;
    inputs = entry.inputs ?? const {};
    break;
  }

  final snapshot = ResultSnapshot(
    toolName: toolName,
    sections: sections,
    formulaSteps: formulaSteps,
    capturedAt: DateTime.now(),
  );

  final existing = projects.projects;
  final choice = existing.isEmpty
      ? const _NewProject()
      : await showModalBottomSheet<_ProjectChoice>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => _ProjectPicker(projects: existing),
        );
  if (choice == null || !context.mounted) return;

  String name;
  if (choice is _ExistingProject) {
    projects.addEntry(
      choice.project.id,
      toolId: toolId,
      inputs: inputs,
      snapshot: snapshot,
    );
    name = choice.project.name;
  } else {
    final chosen =
        await promptForProjectName(context, initialName: toolName);
    if (chosen == null || !context.mounted) return;
    projects.save(
      name: chosen,
      toolId: toolId,
      inputs: inputs,
      snapshot: snapshot,
    );
    name = chosen;
  }

  await HapticFeedback.lightImpact();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.Added_To_Project(name))));
}

sealed class _ProjectChoice {
  const _ProjectChoice();
}

class _NewProject extends _ProjectChoice {
  const _NewProject();
}

class _ExistingProject extends _ProjectChoice {
  const _ExistingProject(this.project);
  final SavedProject project;
}

/// Which project to keep the result in — an existing one, or a new one.
class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({required this.projects});

  final List<SavedProject> projects;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.tokens.space4,
              vertical: context.tokens.space2,
            ),
            child: Text(l10n.Choose_Project, style: theme.textTheme.titleMedium),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('newProjectChoice'),
            leading: const Icon(Icons.create_new_folder_rounded),
            title: Text(l10n.New_Project),
            onTap: () => Navigator.pop(context, const _NewProject()),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ListTile(
                  leading: const Icon(Icons.bookmark_rounded),
                  title: Text(project.name),
                  subtitle:
                      Text(l10n.Project_Calculations('${project.entries.length}')),
                  onTap: () =>
                      Navigator.pop(context, _ExistingProject(project)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
