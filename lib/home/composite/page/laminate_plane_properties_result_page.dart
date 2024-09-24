import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/in_plane_properties_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_3by3_matrix.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class LaminatePlanePropertiesResultPage extends StatefulWidget {
  final Matrix A;
  final Matrix B;
  final Matrix D;
  final InPlanePropertiesModel inPlanePropertiesModel;
  final InPlanePropertiesModel flexuralPropertiesModel;

  const LaminatePlanePropertiesResultPage(
      {Key? key,
      required this.A,
      required this.B,
      required this.D,
      required this.inPlanePropertiesModel,
      required this.flexuralPropertiesModel})
      : super(key: key);

  @override
  _LaminatePlanePropertiesResultPageState createState() =>
      _LaminatePlanePropertiesResultPageState();
}

class _LaminatePlanePropertiesResultPageState extends State<LaminatePlanePropertiesResultPage> {
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
              itemCount: 5,
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                return [
                  Result3By3Matrix(
                    matrix: widget.A,
                    title: "A Matrix",
                  ),
                  Result3By3Matrix(
                    matrix: widget.B,
                    title: "B Matrix",
                  ),
                  Result3By3Matrix(
                    matrix: widget.D,
                    title: "D Matrix",
                  ),
                  InPlanePropertiesWidget(
                    title: "In-Plane Properties",
                    inPlanePropertiesModel: widget.inPlanePropertiesModel,
                  ),
                  InPlanePropertiesWidget(
                    title: "Flexural Properties",
                    inPlanePropertiesModel: widget.flexuralPropertiesModel,
                  )
                ][index];
              }),
        ));
  }
}

class InPlanePropertiesWidget extends StatelessWidget {
  final String title;
  final InPlanePropertiesModel inPlanePropertiesModel;
  const InPlanePropertiesWidget(
      {Key? key, required this.title, required this.inPlanePropertiesModel})
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 240 + 20,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _propertyRow(context, "E1", inPlanePropertiesModel.e1),
                const Divider(height: 1),
                _propertyRow(context, "E2", inPlanePropertiesModel.e2),
                const Divider(height: 1),
                _propertyRow(context, "G12", inPlanePropertiesModel.g12),
                const Divider(height: 1),
                _propertyRow(context, "ν12", inPlanePropertiesModel.nu12),
                const Divider(height: 1),
                _propertyRow(context, "η12,1", inPlanePropertiesModel.eta121),
                const Divider(height: 1),
                _propertyRow(context, "η12,2", inPlanePropertiesModel.eta122),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
