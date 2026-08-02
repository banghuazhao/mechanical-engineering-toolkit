import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_page.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_section_properties_page.dart';
import 'package:mechanical_engineering_toolkit/home/statics/page/centroid_page.dart';
import 'package:mechanical_engineering_toolkit/home/statics/page/resultant_force_page.dart';
import 'package:mechanical_engineering_toolkit/home/statics/page/truss_analysis_page.dart';
import 'package:mechanical_engineering_toolkit/home/reference/drill_tap_chart_page.dart';
import 'package:mechanical_engineering_toolkit/home/unit_converter/unit_converter_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bar_force_displacement_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/beam_flexure_formula_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bolted_joint_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/combined_loading_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cantilever_beam_deflections_slopes_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/column_buckling_load_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cylindrical_pressure_vessel_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/fatigue_safety_factor_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/general_stress_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/mohrs_circle_page.dart';
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
import 'composite/page/tsai_failure_page.dart';
import 'machine_design/page/bearing_life_page.dart';
import 'machine_design/page/belt_drive_page.dart';
import 'machine_design/page/bolt_preload_page.dart';
import 'machine_design/page/fillet_weld_page.dart';
import 'machine_design/page/press_fit_page.dart';
import 'machine_design/page/shaft_fatigue_page.dart';
import 'machine_design/page/spring_design_page.dart';
import 'machine_design/page/spur_gear_page.dart';
import 'mechancs_of_material/page/angle_of_twist_page.dart';
import 'mechancs_of_material/page/bar_torsion_formula_page.dart';
import 'mechancs_of_material/page/failure_criteria_page.dart';
import 'mechancs_of_material/page/monents_of_inertia_page.dart';
import 'mechancs_of_material/page/principal_stress_page.dart';
import 'mechancs_of_material/page/shaft_power_torque_page.dart';
import 'mechancs_of_material/page/simple_beam_deflections_slopes_page.dart';
import 'mechancs_of_material/page/thermal_deformation_page.dart';
import 'mechancs_of_material/page/transverse_shear_stress_page.dart';

enum ToolType {
  mechanicsOfMaterial,
  beamEngineering,
  theoryOfElasticity,
  composite,
  statics,
  utilities,
  machineDesign,
}

class Tool {
  final int id;
  IconData? icon;
  AssetImage? image;
  final String title;
  final ToolType type;

  /// Extra search terms (synonyms, related concepts) beyond the title —
  /// e.g. "torque" on both Torsion Formula and Shaft Power/Torque.
  final List<String> keywords;
  final Function(BuildContext context, String title, int toolId,
      {Map<String, String>? initialInputs}) action;

  Tool(
      {required this.id,
      this.icon,
      this.image,
      required this.title,
      required this.type,
      this.keywords = const [],
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
          keywords: const ['stress', 'strain', 'axial', 'hooke'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GeneralStressPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 101,
          image: AssetImage("images/icon_bar_force.png"),
          title: S.of(context).Force_displacement_relation_of_bar,
          type: ToolType.mechanicsOfMaterial,
          keywords: const [
            'axial',
            'elongation',
            'stiffness',
            'spring constant'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BarForceDisplacementRelationPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 102,
          image: AssetImage("images/cross_section/icon_cs_rectangle.png"),
          title: S.of(context).Moments_of_inertia_of_plane_areas,
          type: ToolType.beamEngineering,
          keywords: const ['second moment', 'section properties', 'centroid'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MonentsOfInertiaPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 103,
          image: AssetImage("images/icon_bar_torsion.png"),
          title: S.of(context).Torsion_formula_of_bar,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['torque', 'shear stress', 'shaft', 'twist'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BarTorsionFormulaPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 104,
          image: AssetImage("images/icon_beam_bending.png"),
          title: S.of(context).Flexure_formula_of_beam,
          type: ToolType.beamEngineering,
          keywords: const ['bending stress', 'moment', 'section modulus'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BeamFlexureFormulaPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 105,
          image: AssetImage(
              "images/cantilever_beam/icon_cantilever_beam_point_force_end.png"),
          title: S.of(context).Deflections_and_slopes_of_cantilever_beams,
          type: ToolType.beamEngineering,
          keywords: const ['deflection', 'slope', 'cantilever'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CantileverBeamDeflectionsSlopesPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 106,
          image: AssetImage(
              "images/simple_beam/icon_simple_beam_distributed_force_evenly.png"),
          title: S.of(context).Deflections_and_slopes_of_simple_beams,
          type: ToolType.beamEngineering,
          keywords: const ['deflection', 'slope', 'simply supported'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SimpleBeamDeflectionsSlopesPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 107,
          image: AssetImage("images/icon_stress_element_inclined.png"),
          title: S.of(context).Plane_stresses_transformation,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['stress transformation', 'rotated axes'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PlaneStressTransformationPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 108,
          image: AssetImage("images/icon_stress_element.png"),
          title: S.of(context).Principal_stresses_and_plane,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['principal stress', 'max shear', 'mohr'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PrincipalStressPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 109,
          image: AssetImage("images/icon_spherical_shell_stress.png"),
          title: S.of(context).Stresses_in_the_wall_of_a_spherical_shell,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['pressure vessel', 'hoop stress', 'sphere'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SphericalShellStressPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 110,
          image: AssetImage("images/icon_cylindrical_pressure_stress.png"),
          title: S
              .of(context)
              .Stresses_in_a_thin_walled_cylindrical_pressure_vessel,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['hoop stress', 'longitudinal stress', 'thin wall'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CylindricalPressureVesselPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 111,
          image: AssetImage("images/buckling/icon_buckling_pinned_pinned.png"),
          title: S.of(context).Buckling_load_of_column,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['euler buckling', 'critical load', 'slenderness'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ColumnBucklingLoadPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 112,
          image: AssetImage("images/icons/icon_thermal_deformation.png"),
          title: S.of(context).Thermal_deformation_and_stress,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['thermal expansion', 'cte', 'temperature'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ThermalDeformationPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 113,
          image: AssetImage("images/icons/icon_transverse_shear.png"),
          title: S.of(context).Transverse_shear_stress_in_beam,
          type: ToolType.beamEngineering,
          keywords: const ['shear flow', 'shear stress'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransverseShearStressPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 114,
          image: AssetImage("images/icons/icon_angle_of_twist.png"),
          title: S.of(context).Angle_of_twist,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['torsion', 'shaft', 'twist angle'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AngleOfTwistPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 115,
          image: AssetImage("images/icons/icon_shaft_power.png"),
          title: S.of(context).Shaft_power_and_torque,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['rpm', 'horsepower', 'torque', 'power transmission'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShaftPowerTorquePage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 116,
          image: AssetImage("images/icons/icon_failure_criteria.png"),
          title: S.of(context).Failure_criteria_von_Mises_Tresca,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['yield', 'von mises', 'tresca', 'safety factor'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FailureCriteriaPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 117,
          image: AssetImage("images/icons/icon_beam_section.png"),
          title: S.of(context).Beam_Section_Properties,
          type: ToolType.beamEngineering,
          keywords: const [
            'cross section',
            'moment of inertia',
            'section modulus'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BeamSectionPropertiesPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 118,
          image: AssetImage("images/icons/icon_mohr_circle.png"),
          title: S.of(context).Mohrs_Circle_for_Plane_Stress,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['principal stress', 'max shear stress'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MohrsCirclePage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 119,
          image: AssetImage("images/icons/icon_goodman.png"),
          title: S.of(context).Fatigue_Safety_Factor,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['goodman', 's-n', 'endurance limit', 'fatigue'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FatigueSafetyFactorPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 120,
          image: AssetImage("images/icons/icon_bolted_joint.png"),
          title: S.of(context).Bolted_Riveted_Joint,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['bolt', 'rivet', 'shear', 'bearing stress'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BoltedJointPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 121,
          image: AssetImage("images/icons/icon_combined_loading.png"),
          title: S.of(context).Combined_Loading_at_a_Point,
          type: ToolType.mechanicsOfMaterial,
          keywords: const ['von mises', 'combined stress', 'factor of safety'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CombinedLoadingPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      // Theory of Elasticity
      Tool(
          id: 200,
          image: AssetImage("images/icons/icon_constitutive.png"),
          title: S.of(context).Constitutive_relation_of_linear_elastic_material,
          type: ToolType.theoryOfElasticity,
          keywords: const ["hooke's law", 'elastic modulus', 'poisson'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LinearElasticConstitutiveRelationPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 201,
          image: AssetImage("images/icons/icon_stress_strain_bar.png"),
          title: S.of(context).Stressstrain_of_linear_elastic_material,
          type: ToolType.theoryOfElasticity,
          keywords: const ["hooke's law", 'elastic constants'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StressStrainLinearElasticPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      // Composite Material
      Tool(
          id: 300,
          image: AssetImage("images/lamina.png"),
          title: S.of(context).Lamina_stressstrain,
          type: ToolType.composite,
          keywords: const ['ply', 'orthotropic'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminaStressStrainPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 301,
          image: AssetImage("images/lamina.png"),
          title: S.of(context).Lamina_engineering_constants,
          type: ToolType.composite,
          keywords: const ['E1 E2 G12', 'ply'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminaEngineeringConstantsPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 302,
          image: AssetImage("images/laminate.png"),
          title: S.of(context).Laminate_stressstrain,
          type: ToolType.composite,
          keywords: const ['laminate', 'clt'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminateStressStrainPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 303,
          image: AssetImage("images/laminate.png"),
          title: S.of(context).Laminate_plane_properties,
          type: ToolType.composite,
          keywords: const ['abd matrix', 'laminate theory'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LaminatePlanePropertiesPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 304,
          image: AssetImage("images/laminate.png"),
          title: S.of(context).Laminate_3D_properties,
          type: ToolType.composite,
          keywords: const ['3d stiffness', 'laminate'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Laminate3DPropertiesPage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 305,
          image: AssetImage("images/square_pack.png"),
          title: S.of(context).Rule_of_mixtures,
          type: ToolType.composite,
          keywords: const ['volume fraction', 'fiber matrix'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RulesOfMixturePage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      Tool(
          id: 306,
          image: AssetImage("images/icons/icon_composite_lamina.png"),
          title: S.of(context).Composite_Failure_Criteria,
          type: ToolType.composite,
          keywords: const [
            'lamina failure',
            'tsai-hill',
            'tsai-wu',
            'strength ratio'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TsaiFailurePage(
                        title: title,
                        toolId: toolId,
                        initialInputs: initialInputs,
                      )))),
      // Statics
      Tool(
          id: 400,
          image: AssetImage("images/icons/icon_resultant_forces.png"),
          title: S.of(context).Resultant_of_Forces_2D,
          type: ToolType.statics,
          keywords: const ['vector sum', 'force resultant'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ResultantForcePage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 401,
          image: AssetImage("images/icons/icon_beam_load.png"),
          title: S.of(context).Beam_Load_Analysis,
          type: ToolType.beamEngineering,
          keywords: const [
            'shear diagram',
            'moment diagram',
            'reactions',
            'deflection'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BeamCalculatorPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 402,
          image: AssetImage("images/icons/icon_centroid.png"),
          title: S.of(context).Centroid_of_Composite_Area,
          type: ToolType.statics,
          keywords: const ['center of gravity', 'centroid'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CentroidPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 403,
          image: AssetImage("images/icons/icon_truss.png"),
          title: S.of(context).Truss_Analysis_Method_of_Joints,
          type: ToolType.statics,
          keywords: const ['method of joints', 'truss', 'member force'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TrussAnalysisPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      // Utilities
      Tool(
          id: 500,
          image: AssetImage("images/icons/icon_unit_converter.png"),
          title: S.of(context).Unit_Converter,
          type: ToolType.utilities,
          keywords: const ['convert', 'units'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UnitConverterPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 501,
          icon: Icons.hardware_rounded,
          title: S.of(context).Drill_Tap_Chart,
          type: ToolType.utilities,
          keywords: const [
            'drill',
            'tap',
            'thread',
            'clearance hole',
            'metric',
            'unc',
            'unf'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DrillTapChartPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      // Machine Design
      Tool(
          id: 701,
          image: AssetImage("images/icons/icon_spring.png"),
          title: S.of(context).Helical_Compression_Spring,
          type: ToolType.machineDesign,
          keywords: const [
            'spring rate',
            'wahl factor',
            'natural frequency',
            'coil'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SpringDesignPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 702,
          image: AssetImage("images/icons/icon_spur_gear.png"),
          title: S.of(context).Spur_Gear_Geometry,
          type: ToolType.machineDesign,
          keywords: const [
            'module',
            'lewis form factor',
            'pitch diameter',
            'gear ratio'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SpurGearPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 703,
          image: AssetImage("images/icons/icon_shaft_fatigue.png"),
          title: S.of(context).Shaft_Fatigue_Design,
          type: ToolType.machineDesign,
          keywords: const [
            'keyway',
            'stress concentration',
            'goodman',
            'shaft diameter'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShaftFatiguePage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 704,
          image: AssetImage("images/icons/icon_bearing.png"),
          title: S.of(context).Bearing_L10_Life,
          type: ToolType.machineDesign,
          keywords: const [
            'dynamic load rating',
            'rating life',
            'ball bearing',
            'roller bearing'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BearingLifePage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 705,
          image: AssetImage("images/icons/icon_belt_drive.png"),
          title: S.of(context).Belt_Chain_Drive,
          type: ToolType.machineDesign,
          keywords: const ['pulley', 'sprocket', 'wrap angle', 'speed ratio'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BeltDrivePage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 706,
          image: AssetImage("images/icons/icon_bolt_preload.png"),
          title: S.of(context).Bolt_Preload_Torque_Tension,
          type: ToolType.machineDesign,
          keywords: const ['nut factor', 'tightening torque', 'bolted joint'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BoltPreloadPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 707,
          image: AssetImage("images/icons/icon_fillet_weld.png"),
          title: S.of(context).Fillet_Weld_Strength,
          type: ToolType.machineDesign,
          keywords: const ['throat', 'weld shear', 'leg size'],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FilletWeldPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
      Tool(
          id: 708,
          image: AssetImage("images/icons/icon_press_fit.png"),
          title: S.of(context).Press_Shrink_Fit_Interference,
          type: ToolType.machineDesign,
          keywords: const [
            'interference fit',
            'shrink fit',
            'contact pressure',
            'hoop stress'
          ],
          action: (context, title, toolId, {initialInputs}) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PressFitPage(
                      title: title,
                      toolId: toolId,
                      initialInputs: initialInputs)))),
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
