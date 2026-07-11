import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:provider/provider.dart';

class ToolFavoritesPage extends StatelessWidget {
  const ToolFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).Favorites)),
      bottomNavigationBar: const AppBannerAd(),
      body: Consumer<Favorites>(
        builder: (context, favorites, _) {
          if (favorites.items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.star_outline_rounded,
              title: 'No favorites yet',
              message: 'Save frequently used tools to keep them close at hand.',
            );
          }
          return AppContent(
            padding: EdgeInsets.symmetric(vertical: context.tokens.space2),
            child: ListView.separated(
              itemCount: favorites.items.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: context.tokens.space2),
              itemBuilder: (context, index) {
                final tool = ToolLibrary.shared.item(
                  favorites.items[index],
                  context,
                );
                return _FavoriteToolCard(tool: tool);
              },
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteToolCard extends StatelessWidget {
  const _FavoriteToolCard({required this.tool});

  final Tool tool;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(context.tokens.radiusMedium),
          ),
          child: tool.icon != null
              ? Icon(tool.icon, color: scheme.onPrimaryContainer)
              : ClipRRect(
                  borderRadius:
                      BorderRadius.circular(context.tokens.radiusMedium),
                  child: Image(
                    image: tool.image!,
                    fit: BoxFit.cover,
                    semanticLabel: '${tool.title} icon',
                  ),
                ),
        ),
        title: Text(tool.title),
        trailing: IconButton(
          tooltip: 'Remove ${tool.title} from favorites',
          icon: const Icon(Icons.close_rounded),
          onPressed: () async {
            await HapticFeedback.selectionClick();
            if (!context.mounted) return;
            context.read<Favorites>().remove(tool.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from favorites')),
            );
          },
        ),
        onTap: () => tool.action(context, tool.title, tool.id),
      ),
    );
  }
}
