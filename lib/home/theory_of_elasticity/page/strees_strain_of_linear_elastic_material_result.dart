import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_6by6_matrix.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class StressStrainLinearElasticResultPage extends StatefulWidget {
  final MechanicalTensor mechanicalTensor;
  final Matrix C;
  final Matrix S;

  const StressStrainLinearElasticResultPage(
      {Key? key, required this.mechanicalTensor, required this.C, required this.S})
      : super(key: key);

  @override
  _StressStrainLinearElasticResultPageState createState() =>
      _StressStrainLinearElasticResultPageState();
}

class _StressStrainLinearElasticResultPageState extends State<StressStrainLinearElasticResultPage> {
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
                  LinearElasticStressStrainWidget(
                    mechanicalTensor: widget.mechanicalTensor,
                  ),
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
        ));
  }
}

class LinearElasticStressStrainWidget extends StatelessWidget {
  final MechanicalTensor mechanicalTensor;
  const LinearElasticStressStrainWidget({Key? key, required this.mechanicalTensor})
      : super(key: key);

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
    bool isStress = (mechanicalTensor is LinearStress);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              isStress ? S.of(context).Result_Stress : S.of(context).Result_Strain,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 240 + 20,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _propertyRow(
                    context,
                    isStress ? "σ11" : "ε11",
                    isStress
                        ? (mechanicalTensor as LinearStress).s11
                        : (mechanicalTensor as LinearStrain).epsilon11),
                const Divider(height: 1),
                _propertyRow(
                    context,
                    isStress ? "σ22" : "ε22",
                    isStress
                        ? (mechanicalTensor as LinearStress).s22
                        : (mechanicalTensor as LinearStrain).epsilon22),
                const Divider(height: 1),
                _propertyRow(
                    context,
                    isStress ? "σ33" : "ε33",
                    isStress
                        ? (mechanicalTensor as LinearStress).s33
                        : (mechanicalTensor as LinearStrain).epsilon33),
                const Divider(height: 1),
                _propertyRow(
                    context,
                    isStress ? "σ23" : "ε23",
                    isStress
                        ? (mechanicalTensor as LinearStress).s23
                        : (mechanicalTensor as LinearStrain).epsilon23),
                const Divider(height: 1),
                _propertyRow(
                    context,
                    isStress ? "σ13" : "ε13",
                    isStress
                        ? (mechanicalTensor as LinearStress).s13
                        : (mechanicalTensor as LinearStrain).epsilon13),
                const Divider(height: 1),
                _propertyRow(
                    context,
                    isStress ? "σ12" : "ε12",
                    isStress
                        ? (mechanicalTensor as LinearStress).s12
                        : (mechanicalTensor as LinearStrain).epsilon12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
