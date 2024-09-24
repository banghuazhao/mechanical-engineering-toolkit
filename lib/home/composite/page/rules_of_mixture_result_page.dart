import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/orthotropic_properties_widget.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_6by6_matrix.dart';

import '../../tool_setting_page.dart';

class RulesOfMixtureResultPage extends StatefulWidget {
  final Matrix Cv;
  final Matrix Cr;
  final Matrix Ch;
  final OrthotropicMaterial voigtConstants;
  final OrthotropicMaterial reussConstants;
  final OrthotropicMaterial hybridConstants;

  const RulesOfMixtureResultPage(
      {Key? key,
      required this.Cv,
      required this.Cr,
      required this.Ch,
      required this.voigtConstants,
      required this.reussConstants,
      required this.hybridConstants})
      : super(key: key);

  @override
  _RulesOfMixtureResultPageState createState() => _RulesOfMixtureResultPageState();
}

class _RulesOfMixtureResultPageState extends State<RulesOfMixtureResultPage> {
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
              itemCount: 9,
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                return [
                  Text(
                    "Voigt Rules of Mixture",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Result6By6Matrix(
                    matrix: widget.Cv,
                    title: "Effective Solid Stiffness Matrix",
                  ),
                  OrthotropicPropertiesWidget(
                    title: "Engineering Constants",
                    orthotropicMaterial: widget.voigtConstants,
                  ),
                  Text(
                    "Reuss Rules of Mixture",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Result6By6Matrix(
                    matrix: widget.Cr,
                    title: "Effective Solid Stiffness Matrix",
                  ),
                  OrthotropicPropertiesWidget(
                    title: "Engineering Constants",
                    orthotropicMaterial: widget.reussConstants,
                  ),
                  Text(
                    "Hybrid Rules of Mixture",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Result6By6Matrix(
                    matrix: widget.Ch,
                    title: "Effective Solid Stiffness Matrix",
                  ),
                  OrthotropicPropertiesWidget(
                    title: "Engineering Constants",
                    orthotropicMaterial: widget.hybridConstants,
                  ),
                ][index];
              }),
        ));
  }
}
