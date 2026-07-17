import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class MomentsOfInertiaResultPage extends StatefulWidget {
  final double Ix;
  final double Iy;
  final double Ixy;
  final double Ip;

  const MomentsOfInertiaResultPage(
      {Key? key, required this.Ix, required this.Iy, required this.Ixy, required this.Ip})
      : super(key: key);

  @override
  _MomentsOfInertiaResultPageState createState() => _MomentsOfInertiaResultPageState();
}

class _MomentsOfInertiaResultPageState extends State<MomentsOfInertiaResultPage> {
  String _fv(BuildContext context, double? valueSI) {
    final precs = Provider.of<NumberPrecisionHelper>(context, listen: false);
    final system =
        Provider.of<UnitSystemPreference>(context, listen: false).system;
    final display = valueSI == null
        ? null
        : fromSI(valueSI, UnitCategory.momentOfInertia, system);
    return '${precs.formatValue(display)} ${unitLabel(UnitCategory.momentOfInertia, system)}';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UnitSystemPreference>();
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                shareResult('Moments of Inertia', [
                  'Ix = ${_fv(context, widget.Ix)}',
                  'Iy = ${_fv(context, widget.Iy)}',
                  'Ixy = ${_fv(context, widget.Ixy)}',
                  'Ip = ${_fv(context, widget.Ip)}',
                ]);
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const ToolSettingPage()));
              },
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(S.of(context).Result),
        ),
        body: SafeArea(
          child: StaggeredGridView.countBuilder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              crossAxisCount: 8,
              itemCount: 1,
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                return [
                  MultipleRowResult(
                      title: S.of(context).Moments_of_Inertia,
                      resultTitles: ["Ix", "Iy", "Ixy", "Ip"],
                      resultValues: [widget.Ix, widget.Iy, widget.Ixy, widget.Ip],
                      resultUnits: const [
                        UnitCategory.momentOfInertia,
                        UnitCategory.momentOfInertia,
                        UnitCategory.momentOfInertia,
                        UnitCategory.momentOfInertia,
                      ])
                ][index];
              }),
        ));
  }
}
