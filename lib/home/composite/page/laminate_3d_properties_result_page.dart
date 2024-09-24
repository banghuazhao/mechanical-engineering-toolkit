import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/orthotropic_properties_widget.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_6by6_matrix.dart';

import '../../tool_setting_page.dart';

class Laminate3DPropertiesResultPage extends StatefulWidget {
  final Matrix C;
  final OrthotropicMaterial orthotropicMaterial;

  const Laminate3DPropertiesResultPage(
      {Key? key, required this.C, required this.orthotropicMaterial})
      : super(key: key);

  @override
  _Laminate3DPropertiesResultPageState createState() => _Laminate3DPropertiesResultPageState();
}

class _Laminate3DPropertiesResultPageState extends State<Laminate3DPropertiesResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
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
              itemCount: 2,
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                return [
                  Result6By6Matrix(
                    matrix: widget.C,
                    title: "Effective Solid Stiffness Matrix",
                  ),
                  OrthotropicPropertiesWidget(
                    title: S.of(context).Engineering_Constants,
                    orthotropicMaterial: widget.orthotropicMaterial,
                  ),
                ][index];
              }),
        ));
  }
}
