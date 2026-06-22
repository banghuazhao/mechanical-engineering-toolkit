import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class ResultListMatrix extends StatelessWidget {
  final String title;
  final List<List<double>> matrix;

  const ResultListMatrix({Key? key, required this.title, required this.matrix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final n = matrix.length;
    final crossAxisCount = n;
    final total = n * n;
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
              ),
            ),
          ),
          const Divider(height: 14),
          StaggeredGridView.countBuilder(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            itemCount: total,
            itemBuilder: (context, index) {
              final r = index ~/ n;
              final c = index % n;
              final value = matrix[r][c];
              return Consumer<NumberPrecisionHelper>(
                builder: (context, precs, _) => Center(
                  child: SizedBox(
                    height: n == 6 ? 28 : 36,
                    child: Center(
                      child: AutoSizeText(
                        precs.formatValue(value),
                        style: TextStyle(fontSize: n == 6 ? 10 : 13),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
            staggeredTileBuilder: (_) => const StaggeredTile.fit(1),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
        ],
      ),
    );
  }
}
