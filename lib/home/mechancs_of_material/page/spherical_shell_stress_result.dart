import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_fomula_row_result.dart';

class SphericalShellStressResultPage extends StatefulWidget {
  final List<String> titles;
  final List<String> values;
  final String rowTitle;

  const SphericalShellStressResultPage(
      {Key? key,
      required this.titles,
      required this.values,
      this.rowTitle = "Result Stress"})
      : super(key: key);

  @override
  _SphericalShellStressResultPageState createState() =>
      _SphericalShellStressResultPageState();
}

class _SphericalShellStressResultPageState
    extends State<SphericalShellStressResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(S.of(context).Result),
        ),
        body: SafeArea(
          child: StaggeredGridView.countBuilder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              crossAxisCount: 8,
              itemCount: 1,
              staggeredTileBuilder: (int index) => StaggeredTile.fit(
                  MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                return [
                  MultipleFormulaRowResult(
                      title: widget.rowTitle,
                      resultTitles: widget.titles,
                      resultValues: widget.values),
                ][index];
              }),
        ));
  }
}
