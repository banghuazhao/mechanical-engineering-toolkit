import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/recorded_inputs.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_launcher.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:provider/provider.dart';

/// Promotes a history entry into a permanent, user-named project.
///
/// The name defaults to the tool's own title, so the common case is one tap
/// and Save; anyone tracking several variants of the same part renames it to
/// tell them apart.
Future<void> _saveAsProject(
  BuildContext context, {
  required HistoryEntry entry,
  required String toolTitle,
}) async {
  final store = context.read<SavedProjects>();
  final name = await promptForProjectName(context, initialName: toolTitle);
  if (name == null || !context.mounted) return;
  store.save(
    name: name,
    toolId: entry.toolId,
    inputs: entry.inputs ?? const {},
  );
  await HapticFeedback.lightImpact();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(S.of(context).Project_Saved(name))),
  );
}

class ToolHistoryPage extends StatelessWidget {
  const ToolHistoryPage({super.key});

  Future<void> _confirmClear(
    BuildContext context,
    ToolHistory history,
  ) async {
    final shouldClear = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        icon: const Icon(Icons.delete_sweep_rounded),
        title: Text(S.of(context).Clear_History_Question),
        content: Text(
          S.of(context).Clear_History_Description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(S.of(context).Cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(S.of(context).Clear),
          ),
        ],
      ),
    );
    if (shouldClear == true) {
      // Clear first, then buzz — awaiting the haptic would make the state
      // change wait on a platform reply.
      history.clear();
      await HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).History),
        actions: [
          Consumer<ToolHistory>(
            builder: (context, history, _) => history.entries.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded),
                    tooltip: S.of(context).Clear_History,
                    onPressed: () => _confirmClear(context, history),
                  ),
          ),
        ],
      ),
      body: Consumer<ToolHistory>(
        builder: (context, history, _) {
          final recorded = history.entries;
          if (recorded.isEmpty) {
            return AppEmptyState(
              icon: Icons.history_rounded,
              title: S.of(context).No_History_Yet,
              message:
                  'Completed calculations will appear here for quick access.',
            );
          }
          // A free macOS build shows only the most recent few. The rest stay
          // recorded — the unlock reveals them rather than starting the
          // history over — and `entries` is newest-first, so truncating from
          // the end keeps the visible indices lined up with ToolHistory's
          // delete-by-index, which counts from the same end.
          final limit = PremiumGate.watch(context).historyLimit;
          final entries = limit == null || recorded.length <= limit
              ? recorded
              : recorded.take(limit).toList();
          final hiddenCount = recorded.length - entries.length;
          return AppContent(
            padding: EdgeInsets.symmetric(vertical: context.tokens.space2),
            child: ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: entries.length + (hiddenCount > 0 ? 1 : 0),
              separatorBuilder: (context, index) =>
                  SizedBox(height: context.tokens.space2),
              itemBuilder: (context, index) {
                if (index == entries.length) {
                  return _HistoryLimitCard(shown: entries.length);
                }
                final entry = entries[index];
                Tool? tool;
                try {
                  tool = ToolLibrary.shared.item(entry.toolId, context);
                } catch (_) {
                  return const SizedBox.shrink();
                }
                final resolvedTool = tool;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Dismissible(
                    key: ValueKey('${entry.timestamp}-${entry.toolId}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.tokens.space5,
                      ),
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Icon(
                        Icons.delete_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    onDismissed: (_) {
                      history.deleteAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${resolvedTool.title} removed from history',
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: _ToolIcon(tool: resolvedTool),
                      title: Text(resolvedTool.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entry.inputs case final inputs?
                              when inputs.isNotEmpty)
                            Padding(
                              padding:
                                  EdgeInsets.only(top: context.tokens.space1),
                              child: Text(
                                describeInputs(context, inputs),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                          Text(
                            _formatTime(entry.timestamp),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // History entries are evicted after
                          // ToolHistory.maxEntries; this is how a calculation
                          // graduates into something permanent.
                          IconButton(
                            icon: const Icon(Icons.bookmark_add_outlined),
                            tooltip: S.of(context).Save_as_Project,
                            onPressed: () => _saveAsProject(
                              context,
                              entry: entry,
                              toolTitle: resolvedTool.title,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      onTap: () => launchTool(
                        context,
                        resolvedTool,
                        initialInputs: entry.inputs,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({required this.tool});

  final Tool tool;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(context.tokens.radiusMedium);
    return Semantics(
      image: true,
      label: '${tool.title} icon',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: radius,
        ),
        child: tool.icon != null
            ? Icon(tool.icon, color: scheme.onPrimaryContainer)
            : ClipRRect(
                borderRadius: radius,
                child: Image(
                  image: tool.image!,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
      ),
    );
  }
}

/// Closes a truncated history with what is missing and how to see it.
///
/// Sits at the end of the list rather than replacing it: the point is that
/// the older entries still exist, so the free tier should read as "showing
/// five of forty", not as though the app forgot.
class _HistoryLimitCard extends StatelessWidget {
  const _HistoryLimitCard({required this.shown});

  final int shown;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          Icons.workspace_premium_rounded,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          strings.Premium_History_Limited(shown, ToolHistory.maxEntries),
        ),
        trailing: TextButton(
          onPressed: () => showLockedFeatureUpsell(
            context,
            PremiumFeature.fullHistory,
          ),
          child: Text(strings.See_Premium),
        ),
      ),
    );
  }
}
