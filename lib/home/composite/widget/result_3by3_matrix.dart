import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class Result3By3Matrix extends StatelessWidget {
  final String title;
  final Matrix matrix;

  const Result3By3Matrix({Key? key, required this.matrix, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          StaggeredGridView.countBuilder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 6,
            itemCount: 9,
            itemBuilder: (BuildContext context, int index) {
              double value = matrix[index ~/ 3][index % 3];
              return Consumer<NumberPrecisionHelper>(builder: (context, precs, child) {
                return Center(
                  child: Container(
                    height: 40,
                    child: Center(
                      child: Text(
                        value == 0 ? "0" : value.toStringAsExponential(precs.precision),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              });
            },
            staggeredTileBuilder: (int index) => const StaggeredTile.fit(2),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        ],
      ),
    );
  }
}
