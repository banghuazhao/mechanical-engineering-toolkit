import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/major_recommendation.dart';
import 'package:mechanical_engineering_toolkit/home/major_tools_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';

class MajorListPage extends StatelessWidget {
  const MajorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommended by Major')),
      bottomNavigationBar: const AppBannerAd(),
      body: AppContent(
        padding: EdgeInsets.symmetric(vertical: context.tokens.space2),
        child: ListView.separated(
          itemCount: majorRecommendations.length,
          separatorBuilder: (context, index) =>
              SizedBox(height: context.tokens.space2),
          itemBuilder: (context, index) {
            final major = majorRecommendations[index];
            return _MajorCard(major: major);
          },
        ),
      ),
    );
  }
}

class _MajorCard extends StatelessWidget {
  const _MajorCard({required this.major});

  final MajorRecommendation major;

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
          child: Icon(major.icon, color: scheme.onPrimaryContainer),
        ),
        title: Text(major.title),
        subtitle: Text('${major.toolIds.length} tools'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MajorToolsPage(major: major),
          ),
        ),
      ),
    );
  }
}
