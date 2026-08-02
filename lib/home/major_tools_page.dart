import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/major_recommendation.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';

class MajorToolsPage extends StatelessWidget {
  const MajorToolsPage({super.key, required this.major});

  final MajorRecommendation major;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(major.title(context))),
      bottomNavigationBar: const AppBannerAd(),
      body: AppContent(
        padding: EdgeInsets.symmetric(vertical: context.tokens.space2),
        child: ListView.separated(
          itemCount: major.toolIds.length,
          separatorBuilder: (context, index) =>
              SizedBox(height: context.tokens.space2),
          itemBuilder: (context, index) {
            final tool = ToolLibrary.shared.item(major.toolIds[index], context);
            return _MajorToolCard(tool: tool);
          },
        ),
      ),
    );
  }
}

class _MajorToolCard extends StatelessWidget {
  const _MajorToolCard({required this.tool});

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
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => tool.action(context, tool.title, tool.id),
      ),
    );
  }
}
