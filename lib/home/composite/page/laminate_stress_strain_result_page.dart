import 'dart:math';

import 'package:composite_calculator/composite_calculator.dart';
import 'package:composite_calculator/utils/layup_parser.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/engineering_constants_widget.dart';
import 'package:linalg/matrix.dart';

import '../../tool_setting_page.dart';

class LaminateStressStrainResultPage extends StatefulWidget {
  final LaminarStressStrainOutput output;
  final LaminarStressStrainInput input;
  final TransverselyIsotropicMaterial material;

  const LaminateStressStrainResultPage({
    Key? key,
    required this.output,
    required this.input,
    required this.material,
  }) : super(key: key);

  @override
  _LaminateStressStrainResultPageState createState() =>
      _LaminateStressStrainResultPageState();
}

class _LaminateStressStrainResultPageState
    extends State<LaminateStressStrainResultPage> {
  late List<List<FlSpot>> _chartSpots; // indexed: 0=ε11,1=ε22,2=ε12,3=σ11,4=σ22,5=σ12
  late List<String> _chartTitles;

  @override
  void initState() {
    super.initState();
    _buildCharts();
  }

  void _buildCharts() {
    final input = widget.input;
    final output = widget.output;
    final nPly = LayupParser.parse(input.layupSequence)?.length ?? 0;
    final thickness = input.layerThickness;
    final totalThickness = nPly * thickness;
    final layups = LayupParser.parse(input.layupSequence) ?? [];

    // Compute mid-plane strain/kappa from output
    final eps0 = [output.epsilon11, output.epsilon22, output.epsilon12];
    final kappa = [output.kappa11, output.kappa22, output.kappa12];
    final N = [output.N11, output.N22, output.N12];
    final M = [output.M11, output.M22, output.M12];

    final e1 = input.E1, e2 = input.E2, g12 = input.G12, nu12 = input.nu12;

    // Build Q_bar for each ply
    Matrix _buildQ(double angleDeg) {
      final a = angleDeg * pi / 180;
      final s = sin(a), c = cos(a);
      final S = Matrix([[1/e1, -nu12/e1, 0], [-nu12/e1, 1/e2, 0], [0, 0, 1/g12]]);
      final Q = S.inverse();
      final Ts = Matrix([[c*c, s*s, -2*s*c], [s*s, c*c, 2*s*c], [s*c, -s*c, c*c-s*s]]);
      return Ts.transpose() * Q * Ts;
    }

    // When input is stress: output has strains; when input is strain: output has stresses
    // The through-thickness distributions require mid-plane strains + curvatures
    final isStressInput = input.tensorType == TensorType.stress;

    List<FlSpot> e11spots = [], e22spots = [], e12spots = [];
    List<FlSpot> s11spots = [], s22spots = [], s12spots = [];

    for (int i = 0; i < layups.length; i++) {
      final z_start = thickness * i - totalThickness / 2;
      final z_end = z_start + thickness;
      final Q = _buildQ(layups[i]);

      for (final z in [z_start, z_end]) {
        // ε = ε0 + z·κ
        final ex = eps0[0] + z * kappa[0];
        final ey = eps0[1] + z * kappa[1];
        final exy = eps0[2] + z * kappa[2];
        // σ = Q * ε
        final sx = Q[0][0]*ex + Q[0][1]*ey + Q[0][2]*exy;
        final sy = Q[1][0]*ex + Q[1][1]*ey + Q[1][2]*exy;
        final sxy = Q[2][0]*ex + Q[2][1]*ey + Q[2][2]*exy;
        e11spots.add(FlSpot(z, ex));
        e22spots.add(FlSpot(z, ey));
        e12spots.add(FlSpot(z, exy));
        s11spots.add(FlSpot(z, sx));
        s22spots.add(FlSpot(z, sy));
        s12spots.add(FlSpot(z, sxy));
      }
    }

    _chartSpots = [e11spots, e22spots, e12spots, s11spots, s22spots, s12spots];
    _chartTitles = ['ε₁₁', 'ε₂₂', 'ε₁₂', 'σ₁₁', 'σ₂₂', 'σ₁₂'];
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.output;
    final isStress = o.tensorType == TensorType.stress;

    final resultMap = isStress
        ? {'N₁₁': o.N11, 'N₂₂': o.N22, 'N₁₂': o.N12, 'M₁₁': o.M11, 'M₂₂': o.M22, 'M₁₂': o.M12}
        : {'ε₁₁': o.epsilon11, 'ε₂₂': o.epsilon22, 'ε₁₂': o.epsilon12, 'κ₁₁': o.kappa11, 'κ₂₂': o.kappa22, 'κ₁₂': o.kappa12};

    final items = <Widget>[
      EngineeringConstantsWidget(
        title: isStress ? 'Stress Resultants' : 'Mid-plane Strains & Curvatures',
        constants: resultMap,
      ),
      ..._chartSpots.asMap().entries.map((e) =>
          _ThicknessChart(title: _chartTitles[e.key], spots: e.value)),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolSettingPage())),
          ),
        ],
        title: Text(S.of(context).Result),
      ),
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          crossAxisCount: 8,
          itemCount: items.length,
          staggeredTileBuilder: (_) =>
              StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }
}

class _ThicknessChart extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;

  const _ThicknessChart({required this.title, required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();
    final minX = spots.map((s) => s.x).reduce(min);
    final maxX = spots.map((s) => s.x).reduce(max);
    var minY = spots.map((s) => s.y).reduce(min);
    var maxY = spots.map((s) => s.y).reduce(max);
    if (minY == maxY) { minY -= 1; maxY += 1; }
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      child: Column(
        children: [
          ListTile(title: Text('$title through thickness',
              style: Theme.of(context).textTheme.titleMedium)),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 24, 12),
            child: SizedBox(
              height: 180,
              child: LineChart(LineChartData(
                lineTouchData: const LineTouchData(enabled: false),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: (v, _) => Text(v.toStringAsExponential(1),
                          style: const TextStyle(fontSize: 9)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(3),
                          style: const TextStyle(fontSize: 9)),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: const Border(
                        left: BorderSide(color: Colors.grey),
                        bottom: BorderSide(color: Colors.grey))),
                minX: minX, maxX: maxX, minY: minY, maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
