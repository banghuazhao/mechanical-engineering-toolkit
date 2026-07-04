import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:provider/provider.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/column_buckling_load_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/column_buckling_load_row.dart';

import 'column_buckling_load_result.dart';

class ColumnBucklingLoadPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const ColumnBucklingLoadPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  _ColumnBucklingLoadPageState createState() => _ColumnBucklingLoadPageState();
}

class _ColumnBucklingLoadPageState extends State<ColumnBucklingLoadPage> {
  ColumnBucklingLoadModel columnBucklingLoadModel = ColumnBucklingLoadModel();
  String dropValue = "Pinned-pinned column";
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      columnBucklingLoadModel.E = double.tryParse(widget.initialInputs!["E"] ?? "");
      columnBucklingLoadModel.I = double.tryParse(widget.initialInputs!["I"] ?? "");
      columnBucklingLoadModel.L = double.tryParse(widget.initialInputs!["L"] ?? "");
      dropValue = widget.initialInputs!["End Condition"] ?? "Pinned-pinned column";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              validate = true;
            });
            _calculate();
          },
          label: Text(S.of(context).Calculate),
        ),
        body: SafeArea(
            child: StaggeredGridView.countBuilder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                crossAxisCount: 8,
                itemCount: 2,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    ColumnBucklingLoadRow(
                      columnBucklingLoadModel: columnBucklingLoadModel,
                      validate: validate,
                      callback: (String dropValueNew) {
                        setState(() {
                          columnBucklingLoadModel = ColumnBucklingLoadModel();
                          dropValue = dropValueNew;
                        });
                      },
                    ),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""
The Euler buckling load in the fundamental mode of a slender column can be calculated by the formula below:
""", style: Theme.of(context).textTheme.bodyMedium),
                        buildMathFormula(context),
                        SizedBox(
                          height: 8,
                        ),
                        Text("""
Where
Pcr: Euler buckling load
E: Young's modulus
I: Moment of inertia
L: Length of the column
""", style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ))
                  ][index];
                })));
  }

  Center buildMathFormula(BuildContext context) {
    String mathFormula = r'''
        P_{cr} = \frac{\pi^2 EI}{L^2}
        ''';
    if (dropValue == "Pinned-pinned column") {
      mathFormula = r'''
        P_{cr} = \frac{\pi^2 EI}{L^2}
        ''';
    } else if (dropValue == "Fixed-free column") {
      mathFormula = r'''
        P_{cr} = \frac{\pi^2 EI}{4L^2}
        ''';
    } else if (dropValue == "Fixed-fixed column") {
      mathFormula = r'''
        P_{cr} = \frac{4\pi^2 EI}{L^2}
        ''';
    } else if (dropValue == "Fixed-pinned column") {
      mathFormula = r'''
        P_{cr} = \frac{2.046\pi^2 EI}{L^2}
        ''';
    }

    return Center(
      child: Math.tex(
        mathFormula,
        mathStyle: MathStyle.display,
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  void _calculate() {
    if (columnBucklingLoadModel.isValid()) {
      double Pcr = 0;
      double E = columnBucklingLoadModel.E!;
      double I = columnBucklingLoadModel.I!;
      double L = columnBucklingLoadModel.L!;

      double C = 1.0;
      if (dropValue == "Pinned-pinned column") {
        C = 1.0;
        Pcr = pi * pi * E * I / (L * L);
      } else if (dropValue == "Fixed-free column") {
        C = 0.25;
        Pcr = pi * pi * E * I / (4 * L * L);
      } else if (dropValue == "Fixed-fixed column") {
        C = 4.0;
        Pcr = 4 * pi * pi * E * I / (L * L);
      } else if (dropValue == "Fixed-pinned column") {
        C = 2.046;
        Pcr = 2.046 * pi * pi * E * I / (L * L);
      }

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        "E": E.toString(),
        "I": I.toString(),
        "L": L.toString(),
        "End Condition": dropValue,
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ColumnBucklingLoadResultPage(
                    Pcr: Pcr,
                    E: E,
                    I: I,
                    L: L,
                    endCondition: dropValue,
                    C: C,
                  )));
    }
  }
}
