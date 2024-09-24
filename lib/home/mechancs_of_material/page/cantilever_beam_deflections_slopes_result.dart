import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_fomula_row_result.dart';

class CantileverBeamDeflectionsSlopesResultPage extends StatefulWidget {
  final List<String> deflectionTitles;
  final List<String> deflectionValues;
  final List<String> slopesTitles;
  final List<String> slopesValues;

  const CantileverBeamDeflectionsSlopesResultPage(
      {Key? key,
      required this.deflectionTitles,
      required this.deflectionValues,
      required this.slopesTitles,
      required this.slopesValues})
      : super(key: key);

  @override
  _CantileverBeamDeflectionsSlopesResultPageState createState() =>
      _CantileverBeamDeflectionsSlopesResultPageState();
}

class _CantileverBeamDeflectionsSlopesResultPageState
    extends State<CantileverBeamDeflectionsSlopesResultPage> {
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
              itemCount: 2,
              staggeredTileBuilder: (int index) => StaggeredTile.fit(
                  MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                return [
                  MultipleFormulaRowResult(
                      title: S.of(context).Deflection,
                      resultTitles: widget.deflectionTitles,
                      resultValues: widget.deflectionValues),
                  MultipleFormulaRowResult(
                      title: S.of(context).Slope,
                      resultTitles: widget.slopesTitles,
                      resultValues: widget.slopesValues)
                ][index];
              }),
        ));
  }
}
