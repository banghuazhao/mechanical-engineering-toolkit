import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_plane_compliance_matrix.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_plane_stiffness_matrix.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as VMath;

import '../../tool_setting_page.dart';

class LaminaStressStrainResult extends StatefulWidget {
  final MechanicalTensor resultTensor;
  final VMath.Matrix3 Q_bar;
  final VMath.Matrix3 S_bar;

  const LaminaStressStrainResult(
      {Key? key, required this.resultTensor, required this.Q_bar, required this.S_bar})
      : super(key: key);

  @override
  _LaminaStressStrainResultState createState() => _LaminaStressStrainResultState();
}

class _LaminaStressStrainResultState extends State<LaminaStressStrainResult> {
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
              itemCount: 3,
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                return [
                  ResultPlaneStressStrainRow(
                    mechanicalTensor: widget.resultTensor,
                  ),
                  ResultPlaneStiffnessMatrix(
                    Q_bar: widget.Q_bar,
                  ),
                  ResultPlaneComplianceMatrix(
                    S_bar: widget.S_bar,
                  )
                ][index];
              }),
        ));
  }
}

class ResultPlaneStressStrainRow extends StatelessWidget {
  final MechanicalTensor mechanicalTensor;

  const ResultPlaneStressStrainRow({
    Key? key,
    required this.mechanicalTensor,
  }) : super(key: key);

  _propertyRow(BuildContext context, String title, double? value) {
    return Consumer<NumberPrecisionHelper>(builder: (context, precs, child) {
      return SizedBox(
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            getValue(value, precs.precision),
            style: Theme.of(context).textTheme.bodyText1,
          )
        ]),
      );
    });
  }

  String getValue(double? value, int precision) {
    String valueString = "";
    if (value != null) {
      valueString = value == 0 ? "0" : value.toStringAsExponential(precision).toString();
    }
    return valueString;
  }

  @override
  Widget build(BuildContext context) {
    bool isStress = (mechanicalTensor is PlaneStress);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              S.of(context).Result,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 40 * 3 + 20,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _propertyRow(
                    context,
                    isStress ? "σ11" : "ε11",
                    isStress
                        ? (mechanicalTensor as PlaneStress).sigma11
                        : (mechanicalTensor as PlaneStrain).epsilon11),
                const Divider(height: 1),
                _propertyRow(
                    context,
                    isStress ? "σ22" : "ε22",
                    isStress
                        ? (mechanicalTensor as PlaneStress).sigma22
                        : (mechanicalTensor as PlaneStrain).epsilon22),
                const Divider(height: 1),
                _propertyRow(
                    context,
                    isStress ? "σ12" : "γ12",
                    isStress
                        ? (mechanicalTensor as PlaneStress).sigma12
                        : (mechanicalTensor as PlaneStrain).gamma12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
