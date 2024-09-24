import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_plane_compliance_matrix.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_plane_stiffness_matrix.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as VMath;

import '../../tool_setting_page.dart';

class LaminaEngineeringConstantsResultPage extends StatefulWidget {
  final TransverselyIsotropicMaterial transverselyIsotropicMaterial;

  const LaminaEngineeringConstantsResultPage(
      {Key? key, required this.transverselyIsotropicMaterial})
      : super(key: key);

  @override
  _LaminaEngineeringConstantsResultPageState createState() =>
      _LaminaEngineeringConstantsResultPageState();
}

class _LaminaEngineeringConstantsResultPageState
    extends State<LaminaEngineeringConstantsResultPage> {
  late VMath.Matrix3 Q_bar;
  late VMath.Matrix3 S_bar;
  double layupAngle = 0.0;

  double E_x = 0.0;
  double nu_xy = 0.0;
  double E_y = 0.0;
  double G_xy = 0.0;
  double eta_x_xy = 0.0;
  double eta_y_xy = 0.0;

  List<FlSpot> E_x_datas = [];
  List<FlSpot> nu_xy_datas = [];
  List<FlSpot> E_y_datas = [];
  List<FlSpot> G_xy_datas = [];
  List<FlSpot> eta_x_xy_datas = [];
  List<FlSpot> eta_y_xy_datas = [];

  calculateNewAngle() {
    double e1 = widget.transverselyIsotropicMaterial.e1!;
    double e2 = widget.transverselyIsotropicMaterial.e2!;
    double g12 = widget.transverselyIsotropicMaterial.g12!;
    double nu12 = widget.transverselyIsotropicMaterial.nu12!;
    double angleRadian = VMath.radians(layupAngle);
    var S = VMath.Matrix3.fromList([1 / e1, -nu12 / e1, 0, -nu12 / e1, 1 / e2, 0, 0, 0, 1 / g12]);
    var Q = VMath.Matrix3.fromList([1 / e1, -nu12 / e1, 0, -nu12 / e1, 1 / e2, 0, 0, 0, 1 / g12]);
    Q.invert();
    double s = sin(angleRadian);
    double c = cos(angleRadian);
    var T_epsilon = VMath.Matrix3.fromList(
        [c * c, s * s, s * c, s * s, c * c, -s * c, -2 * s * c, 2 * s * c, c * c - s * s]);
    var T_sigma = VMath.Matrix3.fromList(
        [c * c, s * s, 2 * s * c, s * s, c * c, -2 * s * c, -s * c, s * c, c * c - s * s]);
    Q_bar = T_epsilon.transposed() * Q * T_epsilon;
    S_bar = T_sigma.transposed() * S * T_sigma;
    E_x = 1 / S_bar[0];
    E_y = 1 / S_bar[4];
    G_xy = 1 / S_bar[8];
    nu_xy = -S_bar[1] * E_x;
    eta_x_xy = S_bar[6] * E_x;
    eta_y_xy = S_bar[7] * E_y;
  }

  initChartData() {
    double e1 = widget.transverselyIsotropicMaterial.e1!;
    double e2 = widget.transverselyIsotropicMaterial.e2!;
    double g12 = widget.transverselyIsotropicMaterial.g12!;
    double nu12 = widget.transverselyIsotropicMaterial.nu12!;
    var S = VMath.Matrix3.fromList([1 / e1, -nu12 / e1, 0, -nu12 / e1, 1 / e2, 0, 0, 0, 1 / g12]);
    var Q = VMath.Matrix3.fromList([1 / e1, -nu12 / e1, 0, -nu12 / e1, 1 / e2, 0, 0, 0, 1 / g12]);
    Q.invert();

    for (var i = -90; i <= 90; i++) {
      print(i);
      double angle = i.toDouble();
      double angleRadian = VMath.radians(angle);
      double s = sin(angleRadian);
      double c = cos(angleRadian);
      var T_sigma = VMath.Matrix3.fromList(
          [c * c, s * s, 2 * s * c, s * s, c * c, -2 * s * c, -s * c, s * c, c * c - s * s]);
      VMath.Matrix3 S_bar_temp = T_sigma.transposed() * S * T_sigma;

      double E_x_temp = 1 / S_bar_temp[0];
      double E_y_temp = 1 / S_bar_temp[4];
      double G_xy_temp = 1 / S_bar_temp[8];
      double nu_xy_temp = -S_bar_temp[1] * E_x_temp;
      double eta_x_xy_temp = S_bar_temp[6] * E_x_temp;
      double eta_y_xy_temp = S_bar_temp[7] * E_y_temp;

      E_x_datas.add(FlSpot(angle, E_x_temp));
      E_y_datas.add(FlSpot(angle, E_y_temp));
      G_xy_datas.add(FlSpot(angle, G_xy_temp));
      nu_xy_datas.add(FlSpot(angle, nu_xy_temp));
      eta_x_xy_datas.add(FlSpot(angle, eta_x_xy_temp));
      eta_y_xy_datas.add(FlSpot(angle, eta_y_xy_temp));
    }
  }

  @override
  void initState() {
    super.initState();
    calculateNewAngle();
    initChartData();
    setState(() {});
  }

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
                itemCount: 4,
                staggeredTileBuilder: (int index) =>
                    StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    layupAngleSlider(),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _engineeringConstantsRow("Ex", E_x, E_x_datas),
                            const Divider(),
                            _engineeringConstantsRow("Ey", E_y, E_y_datas),
                            const Divider(),
                            _engineeringConstantsRow("Gxy", G_xy, G_xy_datas),
                            const Divider(),
                            _engineeringConstantsRow("νxy", nu_xy, nu_xy_datas),
                            const Divider(),
                            _engineeringConstantsRow("ηx,xy", eta_x_xy, eta_x_xy_datas),
                            const Divider(),
                            _engineeringConstantsRow("ηy,xy", eta_y_xy, eta_y_xy_datas)
                          ],
                        ),
                      ),
                    ),
                    ResultPlaneStiffnessMatrix(
                      Q_bar: Q_bar,
                    ),
                    ResultPlaneComplianceMatrix(
                      S_bar: S_bar,
                    )
                  ][index];
                })));
  }

  _engineeringConstantsRow(String constant, double value, List<FlSpot> chartDatas) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              constant,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              height: 8,
            ),
            _getValue(value)
          ],
        ),
        Container(
          width: 180,
          height: 80,
          child: LineChart(LineChartData(
            extraLinesData: ExtraLinesData(verticalLines: [
              VerticalLine(
                  x: layupAngle, color: Theme.of(context).colorScheme.primary, strokeWidth: 1)
            ]),
            lineTouchData: LineTouchData(enabled: false),
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
                show: false,
                rightTitles: SideTitles(showTitles: false),
                topTitles: SideTitles(showTitles: false),
                bottomTitles: SideTitles(showTitles: false)),
            // borderData: borderData,
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                colors: [Theme.of(context).colorScheme.primary],
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                spots: chartDatas,
              ),
            ],
          )),
        )
      ],
    );
  }

  _getValue(double value) {
    return Consumer<NumberPrecisionHelper>(builder: (context, precs, child) {
      return Text(value.toStringAsExponential(precs.precision),
          style: Theme.of(context).textTheme.bodyText1);
    });
  }

  layupAngleSlider() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Layup Angle: ${doubleToString(layupAngle, keepDecimal: 0)}",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Slider(
            value: layupAngle,
            min: -90,
            max: 90,
            divisions: 180,
            onChanged: (double value) {
              layupAngle = value;
              calculateNewAngle();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
