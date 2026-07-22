import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class MomentsOfInertiaResultPage extends StatefulWidget {
  final int toolId;
  final double Ix;
  final double Iy;
  final double Ixy;
  final double Ip;

  const MomentsOfInertiaResultPage(
      {Key? key,
      required this.toolId,
      required this.Ix,
      required this.Iy,
      required this.Ixy,
      required this.Ip})
      : super(key: key);

  @override
  _MomentsOfInertiaResultPageState createState() =>
      _MomentsOfInertiaResultPageState();
}

class _MomentsOfInertiaResultPageState
    extends State<MomentsOfInertiaResultPage> {
  final _exportKey = GlobalKey();

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
    final tool = ToolLibrary.shared.item(widget.toolId, context);
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
              icon: const Icon(Icons.image_outlined),
              onPressed: () =>
                  shareResultImage(_exportKey, 'Moments of Inertia'),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ToolSettingPage()));
              },
              icon: const Icon(Icons.settings_rounded),
            ),
          ],
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(S.of(context).Result),
        ),
        bottomNavigationBar: const AppBannerAd(),
        body: RepaintBoundary(
          key: _exportKey,
          child: SafeArea(
            child: StaggeredGridView.countBuilder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                crossAxisCount: 8,
                itemCount: 2,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    index == 0
                        ? 8
                        : (MediaQuery.of(context).size.width > 600 ? 4 : 8)),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    ToolResultHeader(tool: tool),
                    MultipleRowResult(
                        title: S.of(context).Moments_of_Inertia,
                        resultTitles: [
                          "Ix",
                          "Iy",
                          "Ixy",
                          "Ip"
                        ],
                        resultValues: [
                          widget.Ix,
                          widget.Iy,
                          widget.Ixy,
                          widget.Ip
                        ],
                        resultUnits: const [
                          UnitCategory.momentOfInertia,
                          UnitCategory.momentOfInertia,
                          UnitCategory.momentOfInertia,
                          UnitCategory.momentOfInertia,
                        ])
                  ][index];
                }),
          ),
        ));
  }
}
