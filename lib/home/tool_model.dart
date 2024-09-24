import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bar_force_displacement_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/beam_flexure_formula_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cantilever_beam_deflections_slopes_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/column_buckling_load_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cylindrical_pressure_vessel_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/general_stress_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/plane_stress_transformation_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/spherical_shell_stress_page.dart';
import 'package:mechanical_engineering_toolkit/home/theory_of_elasticity/page/linear_elastic_constitutive_relation.dart';
import 'package:mechanical_engineering_toolkit/home/theory_of_elasticity/page/strees_strain_of_linear_elastic_material.dart';

import 'composite/page/lamina_engineering_constants_page.dart';
import 'composite/page/lamina_stress_strain_page.dart';
import 'composite/page/laminate_3d_properties_page.dart';
import 'composite/page/laminate_plane_properties_page.dart';
import 'composite/page/laminate_stress_strain_page.dart';
import 'composite/page/rules_of_mixture_page.dart';
import 'mechancs_of_material/page/bar_torsion_formula_page.dart';
import 'mechancs_of_material/page/monents_of_inertia_page.dart';
import 'mechancs_of_material/page/principal_stress_page.dart';
import 'mechancs_of_material/page/simple_beam_deflections_slopes_page.dart';

enum ToolType { mechanicsOfMaterial, theoryOfElasticity, composite }

class Tool {
  final int id;
  IconData? icon;
  AssetImage? image;
  final String title;
  final ToolType type;
  final Function(BuildContext, String) action;

  Tool(
      {required this.id,
      this.icon,
      this.image,
      required this.title,
      required this.type,
      required this.action});
}

class ToolLibrary {
  static final ToolLibrary shared = ToolLibrary._internal();

  ToolLibrary._internal();

  List<Tool> getTools(BuildContext context) {
    return <Tool>[
      // Mechanics of Material
      Tool(
          id: 100,
          image: AssetImage("images/icon_bar_force.png"),
          title: S.of(context).General_stress_calculation,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralStressPage(
                        title: title,
                      )))),
      Tool(
          id: 101,
          image: AssetImage("images/icon_bar_force.png"),
          title: S.of(context).Force_displacement_relation_of_bar,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BarForceDisplacementRelationPage(
                        title: title,
                      )))),
      Tool(
          id: 102,
          image: AssetImage("images/cross_section/icon_cs_rectangle.png"),
          title: S.of(context).Moments_of_inertia_of_plane_areas,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MonentsOfInertiaPage(
                        title: title,
                      )))),
      Tool(
          id: 103,
          image: AssetImage("images/icon_bar_torsion.png"),
          title: S.of(context).Torsion_formula_of_bar,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BarTorsionFormulaPage(
                        title: title,
                      )))),
      Tool(
          id: 104,
          image: AssetImage("images/icon_beam_bending.png"),
          title: S.of(context).Flexure_formula_of_beam,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BeamFlexureFormulaPage(
                        title: title,
                      )))),
      Tool(
          id: 105,
          image: AssetImage(
              "images/cantilever_beam/icon_cantilever_beam_point_force_end.png"),
          title: S.of(context).Deflections_and_slopes_of_cantilever_beams,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CantileverBeamDeflectionsSlopesPage(
                        title: title,
                      )))),
      Tool(
          id: 106,
          image: AssetImage(
              "images/simple_beam/icon_simple_beam_distributed_force_evenly.png"),
          title: S.of(context).Deflections_and_slopes_of_simple_beams,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SimpleBeamDeflectionsSlopesPage(
                        title: title,
                      )))),
      Tool(
          id: 107,
          image: AssetImage("images/icon_stress_element_inclined.png"),
          title: S.of(context).Plane_stresses_transformation,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PlaneStressTransformationPage(
                        title: title,
                      )))),
      Tool(
          id: 108,
          image: AssetImage("images/icon_stress_element.png"),
          title: S.of(context).Principal_stresses_and_plane,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PrincipalStressPage(
                        title: title,
                      )))),
      Tool(
          id: 109,
          image: AssetImage("images/icon_spherical_shell_stress.png"),
          title: S.of(context).Stresses_in_the_wall_of_a_spherical_shell,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SphericalShellStressPage(
                        title: title,
                      )))),
      Tool(
          id: 110,
          image: AssetImage("images/icon_cylindrical_pressure_stress.png"),
          title: S
              .of(context)
              .Stresses_in_a_thin_walled_cylindrical_pressure_vessel,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CylindricalPressureVesselPage(
                        title: title,
                      )))),
      Tool(
          id: 111,
          image: AssetImage("images/buckling/icon_buckling_pinned_pinned.png"),
          title: S.of(context).Buckling_load_of_column,
          type: ToolType.mechanicsOfMaterial,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ColumnBucklingLoadPage(
                        title: title,
                      )))),
      // Theory of Elasticity
      Tool(
          id: 200,
          icon: Icons.calculate_rounded,
          title: S.of(context).Constitutive_relation_of_linear_elastic_material,
          type: ToolType.theoryOfElasticity,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LinearElasticConstitutiveRelationPage(
                        title: title,
                      )))),
      Tool(
          id: 201,
          icon: Icons.calculate_rounded,
          title: S.of(context).Stressstrain_of_linear_elastic_material,
          type: ToolType.theoryOfElasticity,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StressStrainLinearElasticPage(
                        title: title,
                      )))),
      // Composite Material
      Tool(
          id: 300,
          image: AssetImage("images/lamina.png"),
          title: S.of(context).Lamina_stressstrain,
          type: ToolType.composite,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminaStressStrainPage(
                        title: title,
                      )))),
      Tool(
          id: 301,
          image: AssetImage("images/lamina.png"),
          title: S.of(context).Lamina_engineering_constants,
          type: ToolType.composite,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminaEngineeringConstantsPage(
                        title: title,
                      )))),
      Tool(
          id: 302,
          image: AssetImage("images/laminate.png"),
          title: S.of(context).Laminate_stressstrain,
          type: ToolType.composite,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminateStressStrainPage(
                        title: title,
                      )))),
      Tool(
          id: 303,
          image: AssetImage("images/laminate.png"),
          title: S.of(context).Laminate_plane_properties,
          type: ToolType.composite,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminatePlanePropertiesPage(
                        title: title,
                      )))),
      Tool(
          id: 304,
          image: AssetImage("images/laminate.png"),
          title: S.of(context).Laminate_3D_properties,
          type: ToolType.composite,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Laminate3DPropertiesPage(
                        title: title,
                      )))),
      Tool(
          id: 305,
          image: AssetImage("images/square_pack.png"),
          title: S.of(context).Rule_of_mixtures,
          type: ToolType.composite,
          action: (context, title) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RulesOfMixturePage(
                        title: title,
                      ))))
    ];
  }

  List<Tool> items(List<int> ids, BuildContext context) {
    List<Tool> temp = [];
    for (int id in ids) {
      Tool tool = getTools(context).firstWhere((element) => element.id == id);
      temp.add(tool);
    }
    return temp;
  }

  Tool item(int id, BuildContext context) {
    return getTools(context).firstWhere((element) => element.id == id);
  }
}
