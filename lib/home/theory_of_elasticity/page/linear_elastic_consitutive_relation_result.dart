import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_6by6_matrix.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';

import '../../tool_setting_page.dart';

class LinearElasticConstitutiveResultPage extends StatefulWidget {
  final int toolId;
  final Matrix C;
  final Matrix S;

  const LinearElasticConstitutiveResultPage(
      {Key? key, required this.toolId, required this.C, required this.S})
      : super(key: key);

  @override
  _LinearElasticConstitutiveResultPageState createState() =>
      _LinearElasticConstitutiveResultPageState();
}

class _LinearElasticConstitutiveResultPageState
    extends State<LinearElasticConstitutiveResultPage> {
  final _exportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: () =>
                  shareResultImage(_exportKey, 'Constitutive Relation'),
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
                itemCount: 3,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    index == 0
                        ? 8
                        : (MediaQuery.of(context).size.width > 600 ? 4 : 8)),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    ToolResultHeader(tool: tool),
                    Result6By6Matrix(
                      matrix: widget.C,
                      title: S.of(context).Stiffness_Matrix_C,
                    ),
                    Result6By6Matrix(
                      matrix: widget.S,
                      title: S.of(context).Compliance_Matrix_S,
                    ),
                  ][index];
                }),
          ),
        ));
  }
}
