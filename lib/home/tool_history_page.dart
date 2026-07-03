import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:provider/provider.dart';

class ToolHistoryPage extends StatelessWidget {
  const ToolHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          Consumer<ToolHistory>(
            builder: (context, history, _) => history.entries.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded),
                    tooltip: 'Clear history',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clear History'),
                          content: const Text('Remove all history entries?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                history.clear();
                                Navigator.pop(ctx);
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<ToolHistory>(
        builder: (context, history, _) {
          final entries = history.entries;
          if (entries.isEmpty) {
            return const Center(
              child: Text('No history yet'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final entry = entries[index];
              Tool? tool;
              try {
                tool = ToolLibrary.shared.item(entry.toolId, context);
              } catch (_) {
                return const SizedBox.shrink();
              }
              final timeLabel = _formatTime(entry.timestamp);
              final primary = Theme.of(context).colorScheme.primary;
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: tool.icon != null
                      ? Icon(tool.icon, size: 22, color: primary)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            height: 44,
                            width: 44,
                            image: tool.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                title: Text(tool.title, style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text(
                  timeLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[500], fontSize: 12),
                ),
                onTap: () => tool!.action(context, tool.title),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dt);
  }
}
