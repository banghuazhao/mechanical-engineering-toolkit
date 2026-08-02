// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `More`
  String get More {
    return Intl.message('More', name: 'More', desc: '', args: []);
  }

  /// `My Favourite`
  String get MyFavourite {
    return Intl.message(
      'My Favourite',
      name: 'MyFavourite',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get Feedback {
    return Intl.message('Feedback', name: 'Feedback', desc: '', args: []);
  }

  /// `Rate this App`
  String get RatethisApp {
    return Intl.message(
      'Rate this App',
      name: 'RatethisApp',
      desc: '',
      args: [],
    );
  }

  /// `Share this App`
  String get SharethisApp {
    return Intl.message(
      'Share this App',
      name: 'SharethisApp',
      desc: '',
      args: [],
    );
  }

  /// `More Apps`
  String get MoreApps {
    return Intl.message('More Apps', name: 'MoreApps', desc: '', args: []);
  }

  /// `Countdown Days`
  String get CountdownDays {
    return Intl.message(
      'Countdown Days',
      name: 'CountdownDays',
      desc: '',
      args: [],
    );
  }

  /// `Money Tracker`
  String get MoneyTracker {
    return Intl.message(
      'Money Tracker',
      name: 'MoneyTracker',
      desc: '',
      args: [],
    );
  }

  /// `Novels Hub`
  String get NovelsHub {
    return Intl.message('Novels Hub', name: 'NovelsHub', desc: '', args: []);
  }

  /// `Finance Go`
  String get FinanceGo {
    return Intl.message('Finance Go', name: 'FinanceGo', desc: '', args: []);
  }

  /// `NASA Lover`
  String get NASALover {
    return Intl.message('NASA Lover', name: 'NASALover', desc: '', args: []);
  }

  /// `World Weather Live`
  String get World_Weather_Live {
    return Intl.message(
      'World Weather Live',
      name: 'World_Weather_Live',
      desc: '',
      args: [],
    );
  }

  /// `Image Guru`
  String get Image_Guru {
    return Intl.message('Image Guru', name: 'Image_Guru', desc: '', args: []);
  }

  /// `Mint Translate`
  String get Mint_Translate {
    return Intl.message(
      'Mint Translate',
      name: 'Mint_Translate',
      desc: '',
      args: [],
    );
  }

  /// `Relaxing Up`
  String get Relaxing_Up {
    return Intl.message('Relaxing Up', name: 'Relaxing_Up', desc: '', args: []);
  }

  /// `Yes Habit`
  String get Yes_Habit {
    return Intl.message('Yes Habit', name: 'Yes_Habit', desc: '', args: []);
  }

  /// `Metronome Go`
  String get Metronome_Go {
    return Intl.message(
      'Metronome Go',
      name: 'Metronome_Go',
      desc: '',
      args: [],
    );
  }

  /// `Instant Face`
  String get Instant_Face {
    return Intl.message(
      'Instant Face',
      name: 'Instant_Face',
      desc: '',
      args: [],
    );
  }

  /// `Simple English Dictionary`
  String get Simple_English_Dictionary {
    return Intl.message(
      'Simple English Dictionary',
      name: 'Simple_English_Dictionary',
      desc: '',
      args: [],
    );
  }

  /// `Money Tracker`
  String get Money_Tracker {
    return Intl.message(
      'Money Tracker',
      name: 'Money_Tracker',
      desc: '',
      args: [],
    );
  }

  /// `Sudoku Lover`
  String get Sudoku_Lover {
    return Intl.message(
      'Sudoku Lover',
      name: 'Sudoku_Lover',
      desc: '',
      args: [],
    );
  }

  /// `Onlynote`
  String get Onlynote {
    return Intl.message('Onlynote', name: 'Onlynote', desc: '', args: []);
  }

  /// `Novels Hub`
  String get Novels_Hub {
    return Intl.message('Novels Hub', name: 'Novels_Hub', desc: '', args: []);
  }

  /// `Simple Calculator`
  String get Simple_Calculator {
    return Intl.message(
      'Simple Calculator',
      name: 'Simple_Calculator',
      desc: '',
      args: [],
    );
  }

  /// `Shows`
  String get Shows {
    return Intl.message('Shows', name: 'Shows', desc: '', args: []);
  }

  /// `Water Tracker`
  String get Water_Tracker {
    return Intl.message(
      'Water Tracker',
      name: 'Water_Tracker',
      desc: '',
      args: [],
    );
  }

  /// `Express Scan`
  String get Express_Scan {
    return Intl.message(
      'Express Scan',
      name: 'Express_Scan',
      desc: '',
      args: [],
    );
  }

  /// `SwiftComp:Composites Material`
  String get SwiftComp {
    return Intl.message(
      'SwiftComp:Composites Material',
      name: 'SwiftComp',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get Settings {
    return Intl.message('Settings', name: 'Settings', desc: '', args: []);
  }

  /// `Result`
  String get Result {
    return Intl.message('Result', name: 'Result', desc: '', args: []);
  }

  /// `Result Precision`
  String get Result_Precision {
    return Intl.message(
      'Result Precision',
      name: 'Result_Precision',
      desc: '',
      args: [],
    );
  }

  /// `Result Stress`
  String get Result_Stress {
    return Intl.message(
      'Result Stress',
      name: 'Result_Stress',
      desc: '',
      args: [],
    );
  }

  /// `Result Strain`
  String get Result_Strain {
    return Intl.message(
      'Result Strain',
      name: 'Result_Strain',
      desc: '',
      args: [],
    );
  }

  /// `Calculate`
  String get Calculate {
    return Intl.message('Calculate', name: 'Calculate', desc: '', args: []);
  }

  /// `Stress`
  String get Stress {
    return Intl.message('Stress', name: 'Stress', desc: '', args: []);
  }

  /// `Strain`
  String get Strain {
    return Intl.message('Strain', name: 'Strain', desc: '', args: []);
  }

  /// `Buckling Load`
  String get Buckling_Load {
    return Intl.message(
      'Buckling Load',
      name: 'Buckling_Load',
      desc: '',
      args: [],
    );
  }

  /// `Deflection`
  String get Deflection {
    return Intl.message('Deflection', name: 'Deflection', desc: '', args: []);
  }

  /// `The Maximum Shear Stress`
  String get The_Maximum_Shear_Stress {
    return Intl.message(
      'The Maximum Shear Stress',
      name: 'The_Maximum_Shear_Stress',
      desc: '',
      args: [],
    );
  }

  /// `Displacement`
  String get Displacement {
    return Intl.message(
      'Displacement',
      name: 'Displacement',
      desc: '',
      args: [],
    );
  }

  /// `Moments of Inertia`
  String get Moments_of_Inertia {
    return Intl.message(
      'Moments of Inertia',
      name: 'Moments_of_Inertia',
      desc: '',
      args: [],
    );
  }

  /// `Stiffness Matrix C`
  String get Stiffness_Matrix_C {
    return Intl.message(
      'Stiffness Matrix C',
      name: 'Stiffness_Matrix_C',
      desc: '',
      args: [],
    );
  }

  /// `Stiffness Matrix Q`
  String get Stiffness_Matrix_Q {
    return Intl.message(
      'Stiffness Matrix Q',
      name: 'Stiffness_Matrix_Q',
      desc: '',
      args: [],
    );
  }

  /// `Compliance Matrix S`
  String get Compliance_Matrix_S {
    return Intl.message(
      'Compliance Matrix S',
      name: 'Compliance_Matrix_S',
      desc: '',
      args: [],
    );
  }

  /// `Area`
  String get Area {
    return Intl.message('Area', name: 'Area', desc: '', args: []);
  }

  /// `Inputs`
  String get Inputs {
    return Intl.message('Inputs', name: 'Inputs', desc: '', args: []);
  }

  /// `Engineering Constants`
  String get Engineering_Constants {
    return Intl.message(
      'Engineering Constants',
      name: 'Engineering_Constants',
      desc: '',
      args: [],
    );
  }

  /// `General stress calculation`
  String get General_stress_calculation {
    return Intl.message(
      'General stress calculation',
      name: 'General_stress_calculation',
      desc: '',
      args: [],
    );
  }

  /// `Force-displacement relation of bar`
  String get Force_displacement_relation_of_bar {
    return Intl.message(
      'Force-displacement relation of bar',
      name: 'Force_displacement_relation_of_bar',
      desc: '',
      args: [],
    );
  }

  /// `Moments of inertia of plane areas`
  String get Moments_of_inertia_of_plane_areas {
    return Intl.message(
      'Moments of inertia of plane areas',
      name: 'Moments_of_inertia_of_plane_areas',
      desc: '',
      args: [],
    );
  }

  /// `Torsion formula of bar`
  String get Torsion_formula_of_bar {
    return Intl.message(
      'Torsion formula of bar',
      name: 'Torsion_formula_of_bar',
      desc: '',
      args: [],
    );
  }

  /// `Flexure formula of beam`
  String get Flexure_formula_of_beam {
    return Intl.message(
      'Flexure formula of beam',
      name: 'Flexure_formula_of_beam',
      desc: '',
      args: [],
    );
  }

  /// `Deflections and slopes of cantilever beams`
  String get Deflections_and_slopes_of_cantilever_beams {
    return Intl.message(
      'Deflections and slopes of cantilever beams',
      name: 'Deflections_and_slopes_of_cantilever_beams',
      desc: '',
      args: [],
    );
  }

  /// `Deflections and slopes of simple beams`
  String get Deflections_and_slopes_of_simple_beams {
    return Intl.message(
      'Deflections and slopes of simple beams',
      name: 'Deflections_and_slopes_of_simple_beams',
      desc: '',
      args: [],
    );
  }

  /// `Plane stresses transformation`
  String get Plane_stresses_transformation {
    return Intl.message(
      'Plane stresses transformation',
      name: 'Plane_stresses_transformation',
      desc: '',
      args: [],
    );
  }

  /// `Principal stresses and plane`
  String get Principal_stresses_and_plane {
    return Intl.message(
      'Principal stresses and plane',
      name: 'Principal_stresses_and_plane',
      desc: '',
      args: [],
    );
  }

  /// `Stresses in the wall of a spherical shell`
  String get Stresses_in_the_wall_of_a_spherical_shell {
    return Intl.message(
      'Stresses in the wall of a spherical shell',
      name: 'Stresses_in_the_wall_of_a_spherical_shell',
      desc: '',
      args: [],
    );
  }

  /// `Stresses in a thin-walled cylindrical pressure vessel`
  String get Stresses_in_a_thin_walled_cylindrical_pressure_vessel {
    return Intl.message(
      'Stresses in a thin-walled cylindrical pressure vessel',
      name: 'Stresses_in_a_thin_walled_cylindrical_pressure_vessel',
      desc: '',
      args: [],
    );
  }

  /// `Buckling load of column`
  String get Buckling_load_of_column {
    return Intl.message(
      'Buckling load of column',
      name: 'Buckling_load_of_column',
      desc: '',
      args: [],
    );
  }

  /// `Thermal deformation and stress`
  String get Thermal_deformation_and_stress {
    return Intl.message(
      'Thermal deformation and stress',
      name: 'Thermal_deformation_and_stress',
      desc: '',
      args: [],
    );
  }

  /// `Transverse shear stress in beam`
  String get Transverse_shear_stress_in_beam {
    return Intl.message(
      'Transverse shear stress in beam',
      name: 'Transverse_shear_stress_in_beam',
      desc: '',
      args: [],
    );
  }

  /// `Angle of twist`
  String get Angle_of_twist {
    return Intl.message(
      'Angle of twist',
      name: 'Angle_of_twist',
      desc: '',
      args: [],
    );
  }

  /// `Shaft power and torque`
  String get Shaft_power_and_torque {
    return Intl.message(
      'Shaft power and torque',
      name: 'Shaft_power_and_torque',
      desc: '',
      args: [],
    );
  }

  /// `Failure criteria (Von Mises & Tresca)`
  String get Failure_criteria_von_Mises_Tresca {
    return Intl.message(
      'Failure criteria (Von Mises & Tresca)',
      name: 'Failure_criteria_von_Mises_Tresca',
      desc: '',
      args: [],
    );
  }

  /// `Constitutive relation of linear elastic material`
  String get Constitutive_relation_of_linear_elastic_material {
    return Intl.message(
      'Constitutive relation of linear elastic material',
      name: 'Constitutive_relation_of_linear_elastic_material',
      desc: '',
      args: [],
    );
  }

  /// `Stress/strain of linear elastic material`
  String get Stressstrain_of_linear_elastic_material {
    return Intl.message(
      'Stress/strain of linear elastic material',
      name: 'Stressstrain_of_linear_elastic_material',
      desc: '',
      args: [],
    );
  }

  /// `Lamina stress/strain`
  String get Lamina_stressstrain {
    return Intl.message(
      'Lamina stress/strain',
      name: 'Lamina_stressstrain',
      desc: '',
      args: [],
    );
  }

  /// `Lamina engineering constants`
  String get Lamina_engineering_constants {
    return Intl.message(
      'Lamina engineering constants',
      name: 'Lamina_engineering_constants',
      desc: '',
      args: [],
    );
  }

  /// `Laminate stress/strain`
  String get Laminate_stressstrain {
    return Intl.message(
      'Laminate stress/strain',
      name: 'Laminate_stressstrain',
      desc: '',
      args: [],
    );
  }

  /// `Laminate plane properties`
  String get Laminate_plane_properties {
    return Intl.message(
      'Laminate plane properties',
      name: 'Laminate_plane_properties',
      desc: '',
      args: [],
    );
  }

  /// `Laminate 3D properties`
  String get Laminate_3D_properties {
    return Intl.message(
      'Laminate 3D properties',
      name: 'Laminate_3D_properties',
      desc: '',
      args: [],
    );
  }

  /// `Rule of mixtures`
  String get Rule_of_mixtures {
    return Intl.message(
      'Rule of mixtures',
      name: 'Rule_of_mixtures',
      desc: '',
      args: [],
    );
  }

  /// `Mechanics of Material`
  String get Mechanics_of_Material {
    return Intl.message(
      'Mechanics of Material',
      name: 'Mechanics_of_Material',
      desc: '',
      args: [],
    );
  }

  /// `Theory of Elasticity`
  String get Theory_of_Elasticity {
    return Intl.message(
      'Theory of Elasticity',
      name: 'Theory_of_Elasticity',
      desc: '',
      args: [],
    );
  }

  /// `Composite Material`
  String get Composite_Material {
    return Intl.message(
      'Composite Material',
      name: 'Composite_Material',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get Description {
    return Intl.message('Description', name: 'Description', desc: '', args: []);
  }

  /// `Force`
  String get Force {
    return Intl.message('Force', name: 'Force', desc: '', args: []);
  }

  /// `Angle of Rotation`
  String get Angle_of_Rotation {
    return Intl.message(
      'Angle of Rotation',
      name: 'Angle_of_Rotation',
      desc: '',
      args: [],
    );
  }

  /// `Plane Stresses`
  String get Plane_Stresses {
    return Intl.message(
      'Plane Stresses',
      name: 'Plane_Stresses',
      desc: '',
      args: [],
    );
  }

  /// `Lamina Constants`
  String get Lamina_Constants {
    return Intl.message(
      'Lamina Constants',
      name: 'Lamina_Constants',
      desc: '',
      args: [],
    );
  }

  /// `Layup Sequence`
  String get Layup_Sequence {
    return Intl.message(
      'Layup Sequence',
      name: 'Layup_Sequence',
      desc: '',
      args: [],
    );
  }

  /// `Layer Thickness`
  String get Layer_Thickness {
    return Intl.message(
      'Layer Thickness',
      name: 'Layer_Thickness',
      desc: '',
      args: [],
    );
  }

  /// `ME Toolkit`
  String get ME_Toolkit {
    return Intl.message('ME Toolkit', name: 'ME_Toolkit', desc: '', args: []);
  }

  /// `Favorites`
  String get Favorites {
    return Intl.message('Favorites', name: 'Favorites', desc: '', args: []);
  }

  /// `Slope`
  String get Slope {
    return Intl.message('Slope', name: 'Slope', desc: '', args: []);
  }

  /// `Not a number`
  String get Not_a_number {
    return Intl.message(
      'Not a number',
      name: 'Not_a_number',
      desc: '',
      args: [],
    );
  }

  /// `Layup Angle`
  String get Layup_Angle {
    return Intl.message('Layup Angle', name: 'Layup_Angle', desc: '', args: []);
  }

  /// `Isotropic material`
  String get Isotropic_material {
    return Intl.message(
      'Isotropic material',
      name: 'Isotropic_material',
      desc: '',
      args: [],
    );
  }

  /// `Transversely isotropic material`
  String get Transversely_isotropic_material {
    return Intl.message(
      'Transversely isotropic material',
      name: 'Transversely_isotropic_material',
      desc: '',
      args: [],
    );
  }

  /// `Orthotropic material`
  String get Orthotropic_material {
    return Intl.message(
      'Orthotropic material',
      name: 'Orthotropic_material',
      desc: '',
      args: [],
    );
  }

  /// `Monoclinic material`
  String get Monoclinic_material {
    return Intl.message(
      'Monoclinic material',
      name: 'Monoclinic_material',
      desc: '',
      args: [],
    );
  }

  /// `Anisotropic material`
  String get Anisotropic_material {
    return Intl.message(
      'Anisotropic material',
      name: 'Anisotropic_material',
      desc: '',
      args: [],
    );
  }

  /// `Truss / Statics`
  String get Truss_Statics {
    return Intl.message(
      'Truss / Statics',
      name: 'Truss_Statics',
      desc: '',
      args: [],
    );
  }

  /// `Utilities`
  String get Utilities {
    return Intl.message('Utilities', name: 'Utilities', desc: '', args: []);
  }

  /// `Remove Ads`
  String get Remove_Ads {
    return Intl.message('Remove Ads', name: 'Remove_Ads', desc: '', args: []);
  }

  /// `Remove ads permanently from this app.`
  String get Remove_Ads_Description {
    return Intl.message(
      'Remove ads permanently from this app.',
      name: 'Remove_Ads_Description',
      desc: '',
      args: [],
    );
  }

  /// `Ads removed`
  String get Ads_Removed {
    return Intl.message('Ads removed', name: 'Ads_Removed', desc: '', args: []);
  }

  /// `Thank you for supporting ME Toolkit.`
  String get Ads_Removed_Description {
    return Intl.message(
      'Thank you for supporting ME Toolkit.',
      name: 'Ads_Removed_Description',
      desc: '',
      args: [],
    );
  }

  /// `Restore Purchases`
  String get Restore_Purchases {
    return Intl.message(
      'Restore Purchases',
      name: 'Restore_Purchases',
      desc: '',
      args: [],
    );
  }

  /// `Purchases are currently unavailable.`
  String get Purchase_Unavailable {
    return Intl.message(
      'Purchases are currently unavailable.',
      name: 'Purchase_Unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Remove Ads is not available from the App Store yet.`
  String get Product_Not_Found {
    return Intl.message(
      'Remove Ads is not available from the App Store yet.',
      name: 'Product_Not_Found',
      desc: '',
      args: [],
    );
  }

  /// `The purchase could not be completed. Please try again.`
  String get Purchase_Failed {
    return Intl.message(
      'The purchase could not be completed. Please try again.',
      name: 'Purchase_Failed',
      desc: '',
      args: [],
    );
  }

  /// `Purchase cancelled. No changes were made.`
  String get Purchase_Cancelled {
    return Intl.message(
      'Purchase cancelled. No changes were made.',
      name: 'Purchase_Cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Purchase pending approval.`
  String get Purchase_Pending {
    return Intl.message(
      'Purchase pending approval.',
      name: 'Purchase_Pending',
      desc: '',
      args: [],
    );
  }

  /// `Ads have been removed permanently.`
  String get Purchase_Success {
    return Intl.message(
      'Ads have been removed permanently.',
      name: 'Purchase_Success',
      desc: '',
      args: [],
    );
  }

  /// `Your Remove Ads purchase was restored.`
  String get Restore_Success {
    return Intl.message(
      'Your Remove Ads purchase was restored.',
      name: 'Restore_Success',
      desc: '',
      args: [],
    );
  }

  /// `No previous Remove Ads purchase was found.`
  String get Restore_Not_Found {
    return Intl.message(
      'No previous Remove Ads purchase was found.',
      name: 'Restore_Not_Found',
      desc: '',
      args: [],
    );
  }

  /// `Purchasing…`
  String get Purchasing {
    return Intl.message('Purchasing…', name: 'Purchasing', desc: '', args: []);
  }

  /// `Restoring…`
  String get Restoring {
    return Intl.message('Restoring…', name: 'Restoring', desc: '', args: []);
  }

  /// `Share results`
  String get Share_Results {
    return Intl.message(
      'Share results',
      name: 'Share_Results',
      desc: '',
      args: [],
    );
  }

  /// `Share as image`
  String get Share_as_Image {
    return Intl.message(
      'Share as image',
      name: 'Share_as_Image',
      desc: '',
      args: [],
    );
  }

  /// `Formula`
  String get Formula {
    return Intl.message('Formula', name: 'Formula', desc: '', args: []);
  }

  /// `Machine Design`
  String get Machine_Design {
    return Intl.message(
      'Machine Design',
      name: 'Machine_Design',
      desc: '',
      args: [],
    );
  }

  /// `Mechanical Engineering`
  String get Mechanical_Engineering {
    return Intl.message(
      'Mechanical Engineering',
      name: 'Mechanical_Engineering',
      desc: '',
      args: [],
    );
  }

  /// `Civil / Structural Engineering`
  String get Civil_Structural_Engineering {
    return Intl.message(
      'Civil / Structural Engineering',
      name: 'Civil_Structural_Engineering',
      desc: '',
      args: [],
    );
  }

  /// `Aerospace Engineering`
  String get Aerospace_Engineering {
    return Intl.message(
      'Aerospace Engineering',
      name: 'Aerospace_Engineering',
      desc: '',
      args: [],
    );
  }

  /// `Materials Science Engineering`
  String get Materials_Science_Engineering {
    return Intl.message(
      'Materials Science Engineering',
      name: 'Materials_Science_Engineering',
      desc: '',
      args: [],
    );
  }

  /// `Beam Section Properties`
  String get Beam_Section_Properties {
    return Intl.message(
      'Beam Section Properties',
      name: 'Beam_Section_Properties',
      desc: '',
      args: [],
    );
  }

  /// `Mohr's Circle for Plane Stress`
  String get Mohrs_Circle_for_Plane_Stress {
    return Intl.message(
      'Mohr\'s Circle for Plane Stress',
      name: 'Mohrs_Circle_for_Plane_Stress',
      desc: '',
      args: [],
    );
  }

  /// `Fatigue Safety Factor (Modified Goodman)`
  String get Fatigue_Safety_Factor {
    return Intl.message(
      'Fatigue Safety Factor (Modified Goodman)',
      name: 'Fatigue_Safety_Factor',
      desc: '',
      args: [],
    );
  }

  /// `Bolted / Riveted Joint`
  String get Bolted_Riveted_Joint {
    return Intl.message(
      'Bolted / Riveted Joint',
      name: 'Bolted_Riveted_Joint',
      desc: '',
      args: [],
    );
  }

  /// `Combined Loading at a Point`
  String get Combined_Loading_at_a_Point {
    return Intl.message(
      'Combined Loading at a Point',
      name: 'Combined_Loading_at_a_Point',
      desc: '',
      args: [],
    );
  }

  /// `Composite Failure Criteria (Tsai-Hill / Tsai-Wu)`
  String get Composite_Failure_Criteria {
    return Intl.message(
      'Composite Failure Criteria (Tsai-Hill / Tsai-Wu)',
      name: 'Composite_Failure_Criteria',
      desc: '',
      args: [],
    );
  }

  /// `Resultant of Forces (2D)`
  String get Resultant_of_Forces_2D {
    return Intl.message(
      'Resultant of Forces (2D)',
      name: 'Resultant_of_Forces_2D',
      desc: '',
      args: [],
    );
  }

  /// `Beam Load Analysis`
  String get Beam_Load_Analysis {
    return Intl.message(
      'Beam Load Analysis',
      name: 'Beam_Load_Analysis',
      desc: '',
      args: [],
    );
  }

  /// `Centroid of Composite Area`
  String get Centroid_of_Composite_Area {
    return Intl.message(
      'Centroid of Composite Area',
      name: 'Centroid_of_Composite_Area',
      desc: '',
      args: [],
    );
  }

  /// `Truss Analysis (Method of Joints)`
  String get Truss_Analysis_Method_of_Joints {
    return Intl.message(
      'Truss Analysis (Method of Joints)',
      name: 'Truss_Analysis_Method_of_Joints',
      desc: '',
      args: [],
    );
  }

  /// `Unit Converter`
  String get Unit_Converter {
    return Intl.message(
      'Unit Converter',
      name: 'Unit_Converter',
      desc: '',
      args: [],
    );
  }

  /// `Helical Compression Spring`
  String get Helical_Compression_Spring {
    return Intl.message(
      'Helical Compression Spring',
      name: 'Helical_Compression_Spring',
      desc: '',
      args: [],
    );
  }

  /// `Spur Gear Geometry`
  String get Spur_Gear_Geometry {
    return Intl.message(
      'Spur Gear Geometry',
      name: 'Spur_Gear_Geometry',
      desc: '',
      args: [],
    );
  }

  /// `Shaft Fatigue Design (DE-Goodman)`
  String get Shaft_Fatigue_Design {
    return Intl.message(
      'Shaft Fatigue Design (DE-Goodman)',
      name: 'Shaft_Fatigue_Design',
      desc: '',
      args: [],
    );
  }

  /// `Bearing L10 Life`
  String get Bearing_L10_Life {
    return Intl.message(
      'Bearing L10 Life',
      name: 'Bearing_L10_Life',
      desc: '',
      args: [],
    );
  }

  /// `Belt / Chain Drive`
  String get Belt_Chain_Drive {
    return Intl.message(
      'Belt / Chain Drive',
      name: 'Belt_Chain_Drive',
      desc: '',
      args: [],
    );
  }

  /// `Bolt Preload / Torque-Tension`
  String get Bolt_Preload_Torque_Tension {
    return Intl.message(
      'Bolt Preload / Torque-Tension',
      name: 'Bolt_Preload_Torque_Tension',
      desc: '',
      args: [],
    );
  }

  /// `Fillet Weld Strength`
  String get Fillet_Weld_Strength {
    return Intl.message(
      'Fillet Weld Strength',
      name: 'Fillet_Weld_Strength',
      desc: '',
      args: [],
    );
  }

  /// `Press / Shrink-Fit Interference`
  String get Press_Shrink_Fit_Interference {
    return Intl.message(
      'Press / Shrink-Fit Interference',
      name: 'Press_Shrink_Fit_Interference',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic load rating C must be positive.`
  String get Err_C_Positive {
    return Intl.message(
      'Dynamic load rating C must be positive.',
      name: 'Err_C_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Equivalent load P must be positive.`
  String get Err_P_Positive {
    return Intl.message(
      'Equivalent load P must be positive.',
      name: 'Err_P_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Speed must be positive.`
  String get Err_Speed_Positive {
    return Intl.message(
      'Speed must be positive.',
      name: 'Err_Speed_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Pulley diameters must be positive.`
  String get Err_Pulley_Positive {
    return Intl.message(
      'Pulley diameters must be positive.',
      name: 'Err_Pulley_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Center distance must be positive.`
  String get Err_Center_Distance_Positive {
    return Intl.message(
      'Center distance must be positive.',
      name: 'Err_Center_Distance_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Input speed must be positive.`
  String get Err_Input_Speed_Positive {
    return Intl.message(
      'Input speed must be positive.',
      name: 'Err_Input_Speed_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Interface radius must be positive.`
  String get Err_Interface_Radius_Positive {
    return Intl.message(
      'Interface radius must be positive.',
      name: 'Err_Interface_Radius_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Interference must be positive.`
  String get Err_Interference_Positive {
    return Intl.message(
      'Interference must be positive.',
      name: 'Err_Interference_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Modulus must be positive.`
  String get Err_Modulus_Positive {
    return Intl.message(
      'Modulus must be positive.',
      name: 'Err_Modulus_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Se and Sut must be positive.`
  String get Err_Se_Sut_Positive {
    return Intl.message(
      'Se and Sut must be positive.',
      name: 'Err_Se_Sut_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Target factor of safety must be positive.`
  String get Err_Target_FoS_Positive {
    return Intl.message(
      'Target factor of safety must be positive.',
      name: 'Err_Target_FoS_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Enter at least one moment or torque.`
  String get Err_Enter_Moment_Or_Torque {
    return Intl.message(
      'Enter at least one moment or torque.',
      name: 'Err_Enter_Moment_Or_Torque',
      desc: '',
      args: [],
    );
  }

  /// `Wire and coil diameter must be positive.`
  String get Err_Wire_Coil_Positive {
    return Intl.message(
      'Wire and coil diameter must be positive.',
      name: 'Err_Wire_Coil_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Number of active coils must be positive.`
  String get Err_Active_Coils_Positive {
    return Intl.message(
      'Number of active coils must be positive.',
      name: 'Err_Active_Coils_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Shear modulus must be positive.`
  String get Err_Shear_Modulus_Positive {
    return Intl.message(
      'Shear modulus must be positive.',
      name: 'Err_Shear_Modulus_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Module must be positive.`
  String get Err_Module_Positive {
    return Intl.message(
      'Module must be positive.',
      name: 'Err_Module_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Face width must be positive.`
  String get Err_Face_Width_Positive {
    return Intl.message(
      'Face width must be positive.',
      name: 'Err_Face_Width_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Dimensions must be greater than zero.`
  String get Err_Dimensions_Positive {
    return Intl.message(
      'Dimensions must be greater than zero.',
      name: 'Err_Dimensions_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Span must be greater than zero.`
  String get Err_Span_Positive {
    return Intl.message(
      'Span must be greater than zero.',
      name: 'Err_Span_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Loads cannot be negative.`
  String get Err_Loads_Non_Negative {
    return Intl.message(
      'Loads cannot be negative.',
      name: 'Err_Loads_Non_Negative',
      desc: '',
      args: [],
    );
  }

  /// `Enter at least one load.`
  String get Err_Enter_One_Load {
    return Intl.message(
      'Enter at least one load.',
      name: 'Err_Enter_One_Load',
      desc: '',
      args: [],
    );
  }

  /// `A truss needs at least 2 joints.`
  String get Err_Truss_Two_Joints {
    return Intl.message(
      'A truss needs at least 2 joints.',
      name: 'Err_Truss_Two_Joints',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one member.`
  String get Err_Add_One_Member {
    return Intl.message(
      'Add at least one member.',
      name: 'Err_Add_One_Member',
      desc: '',
      args: [],
    );
  }

  /// `A member references an unknown joint.`
  String get Err_Member_Unknown_Joint {
    return Intl.message(
      'A member references an unknown joint.',
      name: 'Err_Member_Unknown_Joint',
      desc: '',
      args: [],
    );
  }

  /// `Enter C, P, and n.`
  String get Err_Enter_C_P_N {
    return Intl.message(
      'Enter C, P, and n.',
      name: 'Err_Enter_C_P_N',
      desc: '',
      args: [],
    );
  }

  /// `Enter d1, d2, C, and n1.`
  String get Err_Enter_D1_D2_C_N1 {
    return Intl.message(
      'Enter d1, d2, C, and n1.',
      name: 'Err_Enter_D1_D2_C_N1',
      desc: '',
      args: [],
    );
  }

  /// `Enter F and d.`
  String get Err_Enter_F_D {
    return Intl.message(
      'Enter F and d.',
      name: 'Err_Enter_F_D',
      desc: '',
      args: [],
    );
  }

  /// `F and d must be positive.`
  String get Err_F_D_Positive {
    return Intl.message(
      'F and d must be positive.',
      name: 'Err_F_D_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Nut factor K must be positive.`
  String get Err_Nut_Factor_Positive {
    return Intl.message(
      'Nut factor K must be positive.',
      name: 'Err_Nut_Factor_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Enter w, L, and F.`
  String get Err_Enter_W_L_F {
    return Intl.message(
      'Enter w, L, and F.',
      name: 'Err_Enter_W_L_F',
      desc: '',
      args: [],
    );
  }

  /// `w, L, and F must be positive.`
  String get Err_W_L_F_Positive {
    return Intl.message(
      'w, L, and F must be positive.',
      name: 'Err_W_L_F_Positive',
      desc: '',
      args: [],
    );
  }

  /// `Enter r, ro, δ, and E.`
  String get Err_Enter_R_Ro_Delta_E {
    return Intl.message(
      'Enter r, ro, δ, and E.',
      name: 'Err_Enter_R_Ro_Delta_E',
      desc: '',
      args: [],
    );
  }

  /// `Enter Se and Sut.`
  String get Err_Enter_Se_Sut {
    return Intl.message(
      'Enter Se and Sut.',
      name: 'Err_Enter_Se_Sut',
      desc: '',
      args: [],
    );
  }

  /// `Enter d, D, Na, and G.`
  String get Err_Enter_D_BigD_Na_G {
    return Intl.message(
      'Enter d, D, Na, and G.',
      name: 'Err_Enter_D_BigD_Na_G',
      desc: '',
      args: [],
    );
  }

  /// `Enter module, N1, N2, and face width.`
  String get Err_Enter_Module_N1_N2_Face {
    return Intl.message(
      'Enter module, N1, N2, and face width.',
      name: 'Err_Enter_Module_N1_N2_Face',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic load rating, C`
  String get Dynamic_Load_Rating_C {
    return Intl.message(
      'Dynamic load rating, C',
      name: 'Dynamic_Load_Rating_C',
      desc: '',
      args: [],
    );
  }

  /// `Equivalent load, P`
  String get Equivalent_Load_P {
    return Intl.message(
      'Equivalent load, P',
      name: 'Equivalent_Load_P',
      desc: '',
      args: [],
    );
  }

  /// `Speed, n`
  String get Speed_N {
    return Intl.message('Speed, n', name: 'Speed_N', desc: '', args: []);
  }

  /// `L10 (million revolutions)`
  String get L10_Million_Revolutions {
    return Intl.message(
      'L10 (million revolutions)',
      name: 'L10_Million_Revolutions',
      desc: '',
      args: [],
    );
  }

  /// `L10 (hours)`
  String get L10_Hours {
    return Intl.message('L10 (hours)', name: 'L10_Hours', desc: '', args: []);
  }

  /// `Small pulley diameter, d1`
  String get Small_Pulley_Diameter_D1 {
    return Intl.message(
      'Small pulley diameter, d1',
      name: 'Small_Pulley_Diameter_D1',
      desc: '',
      args: [],
    );
  }

  /// `Large pulley diameter, d2`
  String get Large_Pulley_Diameter_D2 {
    return Intl.message(
      'Large pulley diameter, d2',
      name: 'Large_Pulley_Diameter_D2',
      desc: '',
      args: [],
    );
  }

  /// `Center distance, C`
  String get Center_Distance_C {
    return Intl.message(
      'Center distance, C',
      name: 'Center_Distance_C',
      desc: '',
      args: [],
    );
  }

  /// `Input speed, n1`
  String get Input_Speed_N1 {
    return Intl.message(
      'Input speed, n1',
      name: 'Input_Speed_N1',
      desc: '',
      args: [],
    );
  }

  /// `Power (optional)`
  String get Power_Optional {
    return Intl.message(
      'Power (optional)',
      name: 'Power_Optional',
      desc: '',
      args: [],
    );
  }

  /// `Speed ratio`
  String get Speed_Ratio {
    return Intl.message('Speed ratio', name: 'Speed_Ratio', desc: '', args: []);
  }

  /// `Output speed, n2`
  String get Output_Speed_N2 {
    return Intl.message(
      'Output speed, n2',
      name: 'Output_Speed_N2',
      desc: '',
      args: [],
    );
  }

  /// `Belt length, L`
  String get Belt_Length_L {
    return Intl.message(
      'Belt length, L',
      name: 'Belt_Length_L',
      desc: '',
      args: [],
    );
  }

  /// `Wrap angle, small pulley`
  String get Wrap_Angle_Small_Pulley {
    return Intl.message(
      'Wrap angle, small pulley',
      name: 'Wrap_Angle_Small_Pulley',
      desc: '',
      args: [],
    );
  }

  /// `Wrap angle, large pulley`
  String get Wrap_Angle_Large_Pulley {
    return Intl.message(
      'Wrap angle, large pulley',
      name: 'Wrap_Angle_Large_Pulley',
      desc: '',
      args: [],
    );
  }

  /// `Driving torque, T1`
  String get Driving_Torque_T1 {
    return Intl.message(
      'Driving torque, T1',
      name: 'Driving_Torque_T1',
      desc: '',
      args: [],
    );
  }

  /// `Belt pull, Ft`
  String get Belt_Pull_Ft {
    return Intl.message(
      'Belt pull, Ft',
      name: 'Belt_Pull_Ft',
      desc: '',
      args: [],
    );
  }

  /// `Target preload, F`
  String get Target_Preload_F {
    return Intl.message(
      'Target preload, F',
      name: 'Target_Preload_F',
      desc: '',
      args: [],
    );
  }

  /// `Nominal diameter, d`
  String get Nominal_Diameter_D {
    return Intl.message(
      'Nominal diameter, d',
      name: 'Nominal_Diameter_D',
      desc: '',
      args: [],
    );
  }

  /// `Tightening torque, T`
  String get Tightening_Torque_T {
    return Intl.message(
      'Tightening torque, T',
      name: 'Tightening_Torque_T',
      desc: '',
      args: [],
    );
  }

  /// `Diameter, d`
  String get Diameter_D {
    return Intl.message('Diameter, d', name: 'Diameter_D', desc: '', args: []);
  }

  /// `Leg size, w`
  String get Leg_Size_W {
    return Intl.message('Leg size, w', name: 'Leg_Size_W', desc: '', args: []);
  }

  /// `Effective length, L`
  String get Effective_Length_L {
    return Intl.message(
      'Effective length, L',
      name: 'Effective_Length_L',
      desc: '',
      args: [],
    );
  }

  /// `Applied force, F`
  String get Applied_Force_F {
    return Intl.message(
      'Applied force, F',
      name: 'Applied_Force_F',
      desc: '',
      args: [],
    );
  }

  /// `Allowable shear stress (optional)`
  String get Allowable_Shear_Stress_Optional {
    return Intl.message(
      'Allowable shear stress (optional)',
      name: 'Allowable_Shear_Stress_Optional',
      desc: '',
      args: [],
    );
  }

  /// `Factor of safety`
  String get Factor_of_Safety {
    return Intl.message(
      'Factor of safety',
      name: 'Factor_of_Safety',
      desc: '',
      args: [],
    );
  }

  /// `Interface radius, r`
  String get Interface_Radius_R {
    return Intl.message(
      'Interface radius, r',
      name: 'Interface_Radius_R',
      desc: '',
      args: [],
    );
  }

  /// `Hub outer radius, ro`
  String get Hub_Outer_Radius_Ro {
    return Intl.message(
      'Hub outer radius, ro',
      name: 'Hub_Outer_Radius_Ro',
      desc: '',
      args: [],
    );
  }

  /// `Diametral interference, δ`
  String get Diametral_Interference {
    return Intl.message(
      'Diametral interference, δ',
      name: 'Diametral_Interference',
      desc: '',
      args: [],
    );
  }

  /// `Modulus, E`
  String get Modulus_E {
    return Intl.message('Modulus, E', name: 'Modulus_E', desc: '', args: []);
  }

  /// `Contact pressure, p`
  String get Contact_Pressure_P {
    return Intl.message(
      'Contact pressure, p',
      name: 'Contact_Pressure_P',
      desc: '',
      args: [],
    );
  }

  /// `Hub bore hoop stress, σt`
  String get Hub_Hoop_Stress {
    return Intl.message(
      'Hub bore hoop stress, σt',
      name: 'Hub_Hoop_Stress',
      desc: '',
      args: [],
    );
  }

  /// `Shaft surface stress, σs`
  String get Shaft_Surface_Stress {
    return Intl.message(
      'Shaft surface stress, σs',
      name: 'Shaft_Surface_Stress',
      desc: '',
      args: [],
    );
  }

  /// `Alternating moment, Ma`
  String get Alternating_Moment_Ma {
    return Intl.message(
      'Alternating moment, Ma',
      name: 'Alternating_Moment_Ma',
      desc: '',
      args: [],
    );
  }

  /// `Mean moment, Mm`
  String get Mean_Moment_Mm {
    return Intl.message(
      'Mean moment, Mm',
      name: 'Mean_Moment_Mm',
      desc: '',
      args: [],
    );
  }

  /// `Alternating torque, Ta`
  String get Alternating_Torque_Ta {
    return Intl.message(
      'Alternating torque, Ta',
      name: 'Alternating_Torque_Ta',
      desc: '',
      args: [],
    );
  }

  /// `Mean torque, Tm`
  String get Mean_Torque_Tm {
    return Intl.message(
      'Mean torque, Tm',
      name: 'Mean_Torque_Tm',
      desc: '',
      args: [],
    );
  }

  /// `Endurance limit, Se`
  String get Endurance_Limit_Se {
    return Intl.message(
      'Endurance limit, Se',
      name: 'Endurance_Limit_Se',
      desc: '',
      args: [],
    );
  }

  /// `Ultimate strength, Sut`
  String get Ultimate_Strength_Sut {
    return Intl.message(
      'Ultimate strength, Sut',
      name: 'Ultimate_Strength_Sut',
      desc: '',
      args: [],
    );
  }

  /// `Kf (bending)`
  String get Kf_Bending {
    return Intl.message('Kf (bending)', name: 'Kf_Bending', desc: '', args: []);
  }

  /// `Kfs (torsion)`
  String get Kfs_Torsion {
    return Intl.message(
      'Kfs (torsion)',
      name: 'Kfs_Torsion',
      desc: '',
      args: [],
    );
  }

  /// `Target factor of safety, n`
  String get Target_Factor_of_Safety_N {
    return Intl.message(
      'Target factor of safety, n',
      name: 'Target_Factor_of_Safety_N',
      desc: '',
      args: [],
    );
  }

  /// `Required diameter, d`
  String get Required_Diameter_D {
    return Intl.message(
      'Required diameter, d',
      name: 'Required_Diameter_D',
      desc: '',
      args: [],
    );
  }

  /// `Target safety factor, n`
  String get Target_Safety_Factor_N {
    return Intl.message(
      'Target safety factor, n',
      name: 'Target_Safety_Factor_N',
      desc: '',
      args: [],
    );
  }

  /// `Wire diameter, d`
  String get Wire_Diameter_D {
    return Intl.message(
      'Wire diameter, d',
      name: 'Wire_Diameter_D',
      desc: '',
      args: [],
    );
  }

  /// `Mean coil diameter, D`
  String get Mean_Coil_Diameter_D {
    return Intl.message(
      'Mean coil diameter, D',
      name: 'Mean_Coil_Diameter_D',
      desc: '',
      args: [],
    );
  }

  /// `Active coils, Na`
  String get Active_Coils_Na {
    return Intl.message(
      'Active coils, Na',
      name: 'Active_Coils_Na',
      desc: '',
      args: [],
    );
  }

  /// `Shear modulus, G`
  String get Shear_Modulus_G {
    return Intl.message(
      'Shear modulus, G',
      name: 'Shear_Modulus_G',
      desc: '',
      args: [],
    );
  }

  /// `Operating force, F`
  String get Operating_Force_F {
    return Intl.message(
      'Operating force, F',
      name: 'Operating_Force_F',
      desc: '',
      args: [],
    );
  }

  /// `Material density (default steel)`
  String get Material_Density_Default_Steel {
    return Intl.message(
      'Material density (default steel)',
      name: 'Material_Density_Default_Steel',
      desc: '',
      args: [],
    );
  }

  /// `Spring index, C`
  String get Spring_Index_C {
    return Intl.message(
      'Spring index, C',
      name: 'Spring_Index_C',
      desc: '',
      args: [],
    );
  }

  /// `Wahl factor, Kw`
  String get Wahl_Factor_Kw {
    return Intl.message(
      'Wahl factor, Kw',
      name: 'Wahl_Factor_Kw',
      desc: '',
      args: [],
    );
  }

  /// `Rate, k`
  String get Spring_Rate_K {
    return Intl.message('Rate, k', name: 'Spring_Rate_K', desc: '', args: []);
  }

  /// `Solid height`
  String get Solid_Height {
    return Intl.message(
      'Solid height',
      name: 'Solid_Height',
      desc: '',
      args: [],
    );
  }

  /// `Natural frequency (estimate)`
  String get Natural_Frequency_Estimate {
    return Intl.message(
      'Natural frequency (estimate)',
      name: 'Natural_Frequency_Estimate',
      desc: '',
      args: [],
    );
  }

  /// `Deflection, δ`
  String get Deflection_Delta {
    return Intl.message(
      'Deflection, δ',
      name: 'Deflection_Delta',
      desc: '',
      args: [],
    );
  }

  /// `Shear stress, τ`
  String get Shear_Stress_Tau {
    return Intl.message(
      'Shear stress, τ',
      name: 'Shear_Stress_Tau',
      desc: '',
      args: [],
    );
  }

  /// `Module, m`
  String get Module_M {
    return Intl.message('Module, m', name: 'Module_M', desc: '', args: []);
  }

  /// `Pinion teeth, N1`
  String get Pinion_Teeth_N1 {
    return Intl.message(
      'Pinion teeth, N1',
      name: 'Pinion_Teeth_N1',
      desc: '',
      args: [],
    );
  }

  /// `Gear teeth, N2`
  String get Gear_Teeth_N2 {
    return Intl.message(
      'Gear teeth, N2',
      name: 'Gear_Teeth_N2',
      desc: '',
      args: [],
    );
  }

  /// `Face width, F`
  String get Face_Width_F {
    return Intl.message(
      'Face width, F',
      name: 'Face_Width_F',
      desc: '',
      args: [],
    );
  }

  /// `Tangential load, Wt`
  String get Tangential_Load_Wt {
    return Intl.message(
      'Tangential load, Wt',
      name: 'Tangential_Load_Wt',
      desc: '',
      args: [],
    );
  }

  /// `Pinion pitch diameter, d1`
  String get Pinion_Pitch_Diameter_D1 {
    return Intl.message(
      'Pinion pitch diameter, d1',
      name: 'Pinion_Pitch_Diameter_D1',
      desc: '',
      args: [],
    );
  }

  /// `Gear pitch diameter, d2`
  String get Gear_Pitch_Diameter_D2 {
    return Intl.message(
      'Gear pitch diameter, d2',
      name: 'Gear_Pitch_Diameter_D2',
      desc: '',
      args: [],
    );
  }

  /// `Center distance`
  String get Center_Distance {
    return Intl.message(
      'Center distance',
      name: 'Center_Distance',
      desc: '',
      args: [],
    );
  }

  /// `Gear ratio`
  String get Gear_Ratio {
    return Intl.message('Gear ratio', name: 'Gear_Ratio', desc: '', args: []);
  }

  /// `Lewis form factor, Y (pinion)`
  String get Lewis_Form_Factor_Y {
    return Intl.message(
      'Lewis form factor, Y (pinion)',
      name: 'Lewis_Form_Factor_Y',
      desc: '',
      args: [],
    );
  }

  /// `Bending stress, σ (pinion)`
  String get Bending_Stress_Pinion {
    return Intl.message(
      'Bending stress, σ (pinion)',
      name: 'Bending_Stress_Pinion',
      desc: '',
      args: [],
    );
  }

  /// `Contact stress, σc (est.)`
  String get Contact_Stress_Est {
    return Intl.message(
      'Contact stress, σc (est.)',
      name: 'Contact_Stress_Est',
      desc: '',
      args: [],
    );
  }

  /// `Optional — for bending/contact stress`
  String get Optional_For_Bending_Contact {
    return Intl.message(
      'Optional — for bending/contact stress',
      name: 'Optional_For_Bending_Contact',
      desc: '',
      args: [],
    );
  }

  /// `Optional — for operating deflection/stress and frequency`
  String get Optional_For_Deflection_Frequency {
    return Intl.message(
      'Optional — for operating deflection/stress and frequency',
      name: 'Optional_For_Deflection_Frequency',
      desc: '',
      args: [],
    );
  }

  /// `Simply supported beam`
  String get Simply_Supported_Beam {
    return Intl.message(
      'Simply supported beam',
      name: 'Simply_Supported_Beam',
      desc: '',
      args: [],
    );
  }

  /// `Span, L`
  String get Span_L {
    return Intl.message('Span, L', name: 'Span_L', desc: '', args: []);
  }

  /// `Point load, P`
  String get Point_Load_P {
    return Intl.message(
      'Point load, P',
      name: 'Point_Load_P',
      desc: '',
      args: [],
    );
  }

  /// `Point position, a`
  String get Point_Position_A {
    return Intl.message(
      'Point position, a',
      name: 'Point_Position_A',
      desc: '',
      args: [],
    );
  }

  /// `Full-span UDL, w`
  String get Full_Span_UDL_W {
    return Intl.message(
      'Full-span UDL, w',
      name: 'Full_Span_UDL_W',
      desc: '',
      args: [],
    );
  }

  /// `Elastic modulus, E`
  String get Elastic_Modulus_E {
    return Intl.message(
      'Elastic modulus, E',
      name: 'Elastic_Modulus_E',
      desc: '',
      args: [],
    );
  }

  /// `Second moment, I`
  String get Second_Moment_I {
    return Intl.message(
      'Second moment, I',
      name: 'Second_Moment_I',
      desc: '',
      args: [],
    );
  }

  /// `Description and formulas`
  String get Description_and_Formulas {
    return Intl.message(
      'Description and formulas',
      name: 'Description_and_Formulas',
      desc: '',
      args: [],
    );
  }

  /// `Left reaction, RA`
  String get Left_Reaction_RA {
    return Intl.message(
      'Left reaction, RA',
      name: 'Left_Reaction_RA',
      desc: '',
      args: [],
    );
  }

  /// `Right reaction, RB`
  String get Right_Reaction_RB {
    return Intl.message(
      'Right reaction, RB',
      name: 'Right_Reaction_RB',
      desc: '',
      args: [],
    );
  }

  /// `Maximum bending moment`
  String get Maximum_Bending_Moment {
    return Intl.message(
      'Maximum bending moment',
      name: 'Maximum_Bending_Moment',
      desc: '',
      args: [],
    );
  }

  /// `Maximum downward deflection`
  String get Maximum_Downward_Deflection {
    return Intl.message(
      'Maximum downward deflection',
      name: 'Maximum_Downward_Deflection',
      desc: '',
      args: [],
    );
  }

  /// `Shear-force diagram`
  String get Shear_Force_Diagram {
    return Intl.message(
      'Shear-force diagram',
      name: 'Shear_Force_Diagram',
      desc: '',
      args: [],
    );
  }

  /// `Bending-moment diagram`
  String get Bending_Moment_Diagram {
    return Intl.message(
      'Bending-moment diagram',
      name: 'Bending_Moment_Diagram',
      desc: '',
      args: [],
    );
  }

  /// `Elastic deflection`
  String get Elastic_Deflection {
    return Intl.message(
      'Elastic deflection',
      name: 'Elastic_Deflection',
      desc: '',
      args: [],
    );
  }

  /// `Cross-section`
  String get Cross_Section {
    return Intl.message(
      'Cross-section',
      name: 'Cross_Section',
      desc: '',
      args: [],
    );
  }

  /// `Shape`
  String get Shape {
    return Intl.message('Shape', name: 'Shape', desc: '', args: []);
  }

  /// `Overall height`
  String get Overall_Height {
    return Intl.message(
      'Overall height',
      name: 'Overall_Height',
      desc: '',
      args: [],
    );
  }

  /// `Wall thickness`
  String get Wall_Thickness {
    return Intl.message(
      'Wall thickness',
      name: 'Wall_Thickness',
      desc: '',
      args: [],
    );
  }

  /// `Flange thickness`
  String get Flange_Thickness {
    return Intl.message(
      'Flange thickness',
      name: 'Flange_Thickness',
      desc: '',
      args: [],
    );
  }

  /// `Web thickness`
  String get Web_Thickness {
    return Intl.message(
      'Web thickness',
      name: 'Web_Thickness',
      desc: '',
      args: [],
    );
  }

  /// `Area, A`
  String get Area_A {
    return Intl.message('Area, A', name: 'Area_A', desc: '', args: []);
  }

  /// `Second moment, Ix`
  String get Second_Moment_Ix {
    return Intl.message(
      'Second moment, Ix',
      name: 'Second_Moment_Ix',
      desc: '',
      args: [],
    );
  }

  /// `Second moment, Iy`
  String get Second_Moment_Iy {
    return Intl.message(
      'Second moment, Iy',
      name: 'Second_Moment_Iy',
      desc: '',
      args: [],
    );
  }

  /// `Section modulus, Zx`
  String get Section_Modulus_Zx {
    return Intl.message(
      'Section modulus, Zx',
      name: 'Section_Modulus_Zx',
      desc: '',
      args: [],
    );
  }

  /// `Section modulus, Zy`
  String get Section_Modulus_Zy {
    return Intl.message(
      'Section modulus, Zy',
      name: 'Section_Modulus_Zy',
      desc: '',
      args: [],
    );
  }

  /// `Polar area moment, J`
  String get Polar_Area_Moment_J {
    return Intl.message(
      'Polar area moment, J',
      name: 'Polar_Area_Moment_J',
      desc: '',
      args: [],
    );
  }

  /// `Span L`
  String get Span_L_Short {
    return Intl.message('Span L', name: 'Span_L_Short', desc: '', args: []);
  }

  /// `P (load)`
  String get P_Load {
    return Intl.message('P (load)', name: 'P_Load', desc: '', args: []);
  }

  /// `a (from A)`
  String get A_From_A {
    return Intl.message('a (from A)', name: 'A_From_A', desc: '', args: []);
  }

  /// `w (intensity)`
  String get W_Intensity {
    return Intl.message(
      'w (intensity)',
      name: 'W_Intensity',
      desc: '',
      args: [],
    );
  }

  /// `Beam Configuration`
  String get Beam_Configuration {
    return Intl.message(
      'Beam Configuration',
      name: 'Beam_Configuration',
      desc: '',
      args: [],
    );
  }

  /// `Load Type`
  String get Load_Type {
    return Intl.message('Load Type', name: 'Load_Type', desc: '', args: []);
  }

  /// `Point Load`
  String get Point_Load {
    return Intl.message('Point Load', name: 'Point_Load', desc: '', args: []);
  }

  /// `UDL`
  String get UDL {
    return Intl.message('UDL', name: 'UDL', desc: '', args: []);
  }

  /// `Both`
  String get Both {
    return Intl.message('Both', name: 'Both', desc: '', args: []);
  }

  /// `Uniform Distributed Load (full span)`
  String get Uniform_Distributed_Load_Full_Span {
    return Intl.message(
      'Uniform Distributed Load (full span)',
      name: 'Uniform_Distributed_Load_Full_Span',
      desc: '',
      args: [],
    );
  }

  /// `Shape type`
  String get Shape_Type {
    return Intl.message('Shape type', name: 'Shape_Type', desc: '', args: []);
  }

  /// `Height h`
  String get Height_H {
    return Intl.message('Height h', name: 'Height_H', desc: '', args: []);
  }

  /// `Add Shape`
  String get Add_Shape {
    return Intl.message('Add Shape', name: 'Add_Shape', desc: '', args: []);
  }

  /// `Subtract`
  String get Subtract {
    return Intl.message('Subtract', name: 'Subtract', desc: '', args: []);
  }

  /// `Forces`
  String get Forces {
    return Intl.message('Forces', name: 'Forces', desc: '', args: []);
  }

  /// `Add Force`
  String get Add_Force {
    return Intl.message('Add Force', name: 'Add_Force', desc: '', args: []);
  }

  /// `Support`
  String get Support {
    return Intl.message('Support', name: 'Support', desc: '', args: []);
  }

  /// `Load Fx`
  String get Load_Fx {
    return Intl.message('Load Fx', name: 'Load_Fx', desc: '', args: []);
  }

  /// `Load Fy`
  String get Load_Fy {
    return Intl.message('Load Fy', name: 'Load_Fy', desc: '', args: []);
  }

  /// `From`
  String get From {
    return Intl.message('From', name: 'From', desc: '', args: []);
  }

  /// `Joints`
  String get Joints {
    return Intl.message('Joints', name: 'Joints', desc: '', args: []);
  }

  /// `Add Joint`
  String get Add_Joint {
    return Intl.message('Add Joint', name: 'Add_Joint', desc: '', args: []);
  }

  /// `Members`
  String get Members {
    return Intl.message('Members', name: 'Members', desc: '', args: []);
  }

  /// `Add Member`
  String get Add_Member {
    return Intl.message('Add Member', name: 'Add_Member', desc: '', args: []);
  }

  /// `None`
  String get None {
    return Intl.message('None', name: 'None', desc: '', args: []);
  }

  /// `Pin`
  String get Pin {
    return Intl.message('Pin', name: 'Pin', desc: '', args: []);
  }

  /// `Roller (horizontal reaction)`
  String get Roller_Horizontal {
    return Intl.message(
      'Roller (horizontal reaction)',
      name: 'Roller_Horizontal',
      desc: '',
      args: [],
    );
  }

  /// `Roller (vertical reaction)`
  String get Roller_Vertical {
    return Intl.message(
      'Roller (vertical reaction)',
      name: 'Roller_Vertical',
      desc: '',
      args: [],
    );
  }

  /// `Truss Geometry`
  String get Truss_Geometry {
    return Intl.message(
      'Truss Geometry',
      name: 'Truss_Geometry',
      desc: '',
      args: [],
    );
  }

  /// `Support Reactions`
  String get Support_Reactions {
    return Intl.message(
      'Support Reactions',
      name: 'Support_Reactions',
      desc: '',
      args: [],
    );
  }

  /// `Swap`
  String get Swap {
    return Intl.message('Swap', name: 'Swap', desc: '', args: []);
  }

  /// `Copy result`
  String get Copy_Result {
    return Intl.message('Copy result', name: 'Copy_Result', desc: '', args: []);
  }

  /// `Result copied`
  String get Result_Copied {
    return Intl.message(
      'Result copied',
      name: 'Result_Copied',
      desc: '',
      args: [],
    );
  }

  /// `Basic rating life from catalog dynamic load rating C, equivalent applied load P, and speed n: L10 = (C/P)^p.`
  String get Desc_Bearing_Life {
    return Intl.message(
      'Basic rating life from catalog dynamic load rating C, equivalent applied load P, and speed n: L10 = (C/P)^p.',
      name: 'Desc_Bearing_Life',
      desc: '',
      args: [],
    );
  }

  /// `Open-belt (or roller-chain, using pitch diameters) drive geometry: speed ratio, approximate belt length, and pulley wrap angles.`
  String get Desc_Belt_Drive {
    return Intl.message(
      'Open-belt (or roller-chain, using pitch diameters) drive geometry: speed ratio, approximate belt length, and pulley wrap angles.',
      name: 'Desc_Belt_Drive',
      desc: '',
      args: [],
    );
  }

  /// `Estimates the tightening torque needed to reach a target bolt preload, using the short-form torque-tension equation.`
  String get Desc_Bolt_Preload {
    return Intl.message(
      'Estimates the tightening torque needed to reach a target bolt preload, using the short-form torque-tension equation.',
      name: 'Desc_Bolt_Preload',
      desc: '',
      args: [],
    );
  }

  /// `Nut factor, K (default 0.2 — typical for non-lubricated steel; use ~0.15 lubricated/plated, ~0.2-0.3 dry)`
  String get Nut_Factor_K {
    return Intl.message(
      'Nut factor, K (default 0.2 — typical for non-lubricated steel; use ~0.15 lubricated/plated, ~0.2-0.3 dry)',
      name: 'Nut_Factor_K',
      desc: '',
      args: [],
    );
  }

  /// `Shear stress on the weld throat for a fillet weld of leg size w and effective length L, treating the throat as the failure plane (the standard simplified approach).`
  String get Desc_Fillet_Weld {
    return Intl.message(
      'Shear stress on the weld throat for a fillet weld of leg size w and effective length L, treating the throat as the failure plane (the standard simplified approach).',
      name: 'Desc_Fillet_Weld',
      desc: '',
      args: [],
    );
  }

  /// `Contact pressure and hoop stress for a solid shaft pressed into a hub, same material assumed for both parts (a standard simplified case — Poisson\'s ratio cancels out).`
  String get Desc_Press_Fit {
    return Intl.message(
      'Contact pressure and hoop stress for a solid shaft pressed into a hub, same material assumed for both parts (a standard simplified case — Poisson\\\'s ratio cancels out).',
      name: 'Desc_Press_Fit',
      desc: '',
      args: [],
    );
  }

  /// `Minimum shaft diameter for combined fluctuating bending and torsion, using the distortion-energy/modified-Goodman criterion (Shigley). Leave mean moment/torque at 0 for a fully-reversed-bending, steady-torque shaft — the common case.`
  String get Desc_Shaft_Fatigue {
    return Intl.message(
      'Minimum shaft diameter for combined fluctuating bending and torsion, using the distortion-energy/modified-Goodman criterion (Shigley). Leave mean moment/torque at 0 for a fully-reversed-bending, steady-torque shaft — the common case.',
      name: 'Desc_Shaft_Fatigue',
      desc: '',
      args: [],
    );
  }

  /// `Stress-concentration factors (defaults: profiled keyway) and target safety factor`
  String get Stress_Concentration_Defaults {
    return Intl.message(
      'Stress-concentration factors (defaults: profiled keyway) and target safety factor',
      name: 'Stress_Concentration_Defaults',
      desc: '',
      args: [],
    );
  }

  /// `Spring index, Wahl stress-correction factor, rate, and an estimated fundamental natural frequency (both ends fixed) for a round-wire helical compression spring.`
  String get Desc_Spring_Design {
    return Intl.message(
      'Spring index, Wahl stress-correction factor, rate, and an estimated fundamental natural frequency (both ends fixed) for a round-wire helical compression spring.',
      name: 'Desc_Spring_Design',
      desc: '',
      args: [],
    );
  }

  /// `20° full-depth involute spur gear pair: pitch diameters, center distance, and basic (Lewis) bending stress with a simplified contact-stress estimate. Not a full AGMA design check.`
  String get Desc_Spur_Gear {
    return Intl.message(
      '20° full-depth involute spur gear pair: pitch diameters, center distance, and basic (Lewis) bending stress with a simplified contact-stress estimate. Not a full AGMA design check.',
      name: 'Desc_Spur_Gear',
      desc: '',
      args: [],
    );
  }

  /// `Pin support at the left, roller support at the right. Combine one downward point load with a full-span uniformly distributed load.`
  String get Desc_Beam_Supports {
    return Intl.message(
      'Pin support at the left, roller support at the right. Combine one downward point load with a full-span uniformly distributed load.',
      name: 'Desc_Beam_Supports',
      desc: '',
      args: [],
    );
  }

  /// `Uses static equilibrium and Euler–Bernoulli beam theory for a simply supported beam. A downward point load and a full-span uniformly distributed load may be used separately or together.`
  String get Desc_Beam_Analysis {
    return Intl.message(
      'Uses static equilibrium and Euler–Bernoulli beam theory for a simply supported beam. A downward point load and a full-span uniformly distributed load may be used separately or together.',
      name: 'Desc_Beam_Analysis',
      desc: '',
      args: [],
    );
  }

  /// `Calculates centroidal geometric properties used in beam bending and stress calculations. The x-axis is horizontal through the centroid and the y-axis is vertical through the centroid.`
  String get Desc_Section_Properties {
    return Intl.message(
      'Calculates centroidal geometric properties used in beam bending and stress calculations. The x-axis is horizontal through the centroid and the y-axis is vertical through the centroid.',
      name: 'Desc_Section_Properties',
      desc: '',
      args: [],
    );
  }

  /// `J = Ix + Iy is the polar area moment. It is not the Saint-Venant torsion constant for non-circular sections.`
  String get Note_Polar_Moment {
    return Intl.message(
      'J = Ix + Iy is the polar area moment. It is not the Saint-Venant torsion constant for non-circular sections.',
      name: 'Note_Polar_Moment',
      desc: '',
      args: [],
    );
  }

  /// `Simply supported beam — pin at A (left), roller at B (right)`
  String get Simply_Supported_Beam_Note {
    return Intl.message(
      'Simply supported beam — pin at A (left), roller at B (right)',
      name: 'Simply_Supported_Beam_Note',
      desc: '',
      args: [],
    );
  }

  /// `Enter Fx and Fy components for each force (N)`
  String get Enter_Fx_Fy_Components {
    return Intl.message(
      'Enter Fx and Fy components for each force (N)',
      name: 'Enter_Fx_Fy_Components',
      desc: '',
      args: [],
    );
  }

  /// `A statically determinate 2D truss needs members + reactions = 2 × joints. Give at least one pin and one roller support.`
  String get Desc_Truss_Determinacy {
    return Intl.message(
      'A statically determinate 2D truss needs members + reactions = 2 × joints. Give at least one pin and one roller support.',
      name: 'Desc_Truss_Determinacy',
      desc: '',
      args: [],
    );
  }

  /// `Member Forces (+ tension, \u2212 compression)`
  String get Member_Forces {
    return Intl.message(
      'Member Forces (+ tension, \\u2212 compression)',
      name: 'Member_Forces',
      desc: '',
      args: [],
    );
  }

  /// `Elastic coeff., Cp (√MPa)`
  String get Elastic_Coefficient_Cp {
    return Intl.message(
      'Elastic coeff., Cp (√MPa)',
      name: 'Elastic_Coefficient_Cp',
      desc: '',
      args: [],
    );
  }

  /// `Beam Engineering`
  String get Beam_Engineering {
    return Intl.message(
      'Beam Engineering',
      name: 'Beam_Engineering',
      desc: '',
      args: [],
    );
  }

  /// `Recommended by Major`
  String get Recommended_by_Major {
    return Intl.message(
      'Recommended by Major',
      name: 'Recommended_by_Major',
      desc: '',
      args: [],
    );
  }

  /// `Search tools`
  String get Search_Tools {
    return Intl.message(
      'Search tools',
      name: 'Search_Tools',
      desc: '',
      args: [],
    );
  }

  /// `Clear search`
  String get Clear_Search {
    return Intl.message(
      'Clear search',
      name: 'Clear_Search',
      desc: '',
      args: [],
    );
  }

  /// `No tools found`
  String get No_Tools_Found {
    return Intl.message(
      'No tools found',
      name: 'No_Tools_Found',
      desc: '',
      args: [],
    );
  }

  /// `Grid view`
  String get Grid_View {
    return Intl.message('Grid view', name: 'Grid_View', desc: '', args: []);
  }

  /// `List view`
  String get List_View {
    return Intl.message('List view', name: 'List_View', desc: '', args: []);
  }

  /// `Privacy`
  String get Privacy {
    return Intl.message('Privacy', name: 'Privacy', desc: '', args: []);
  }

  /// `UNIT SYSTEM`
  String get Unit_System {
    return Intl.message('UNIT SYSTEM', name: 'Unit_System', desc: '', args: []);
  }

  /// `PRECISION`
  String get Precision {
    return Intl.message('PRECISION', name: 'Precision', desc: '', args: []);
  }

  /// `DISPLAY FORMAT`
  String get Display_Format {
    return Intl.message(
      'DISPLAY FORMAT',
      name: 'Display_Format',
      desc: '',
      args: [],
    );
  }

  /// `Privacy choices`
  String get Privacy_Choices {
    return Intl.message(
      'Privacy choices',
      name: 'Privacy_Choices',
      desc: '',
      args: [],
    );
  }

  /// `Review or change your advertising consent.`
  String get Privacy_Choices_Description {
    return Intl.message(
      'Review or change your advertising consent.',
      name: 'Privacy_Choices_Description',
      desc: '',
      args: [],
    );
  }

  /// `Privacy choices are unavailable. Try again later.`
  String get Privacy_Choices_Unavailable {
    return Intl.message(
      'Privacy choices are unavailable. Try again later.',
      name: 'Privacy_Choices_Unavailable',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get History {
    return Intl.message('History', name: 'History', desc: '', args: []);
  }

  /// `Clear history`
  String get Clear_History {
    return Intl.message(
      'Clear history',
      name: 'Clear_History',
      desc: '',
      args: [],
    );
  }

  /// `No history yet`
  String get No_History_Yet {
    return Intl.message(
      'No history yet',
      name: 'No_History_Yet',
      desc: '',
      args: [],
    );
  }

  /// `Clear history?`
  String get Clear_History_Question {
    return Intl.message(
      'Clear history?',
      name: 'Clear_History_Question',
      desc: '',
      args: [],
    );
  }

  /// `This removes every saved calculation from this device.`
  String get Clear_History_Description {
    return Intl.message(
      'This removes every saved calculation from this device.',
      name: 'Clear_History_Description',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message('Cancel', name: 'Cancel', desc: '', args: []);
  }

  /// `Clear`
  String get Clear {
    return Intl.message('Clear', name: 'Clear', desc: '', args: []);
  }

  /// `No favorites yet`
  String get No_Favorites_Yet {
    return Intl.message(
      'No favorites yet',
      name: 'No_Favorites_Yet',
      desc: '',
      args: [],
    );
  }

  /// `Removed from favorites`
  String get Removed_from_Favorites {
    return Intl.message(
      'Removed from favorites',
      name: 'Removed_from_Favorites',
      desc: '',
      args: [],
    );
  }

  /// `Add custom material`
  String get Add_Custom_Material {
    return Intl.message(
      'Add custom material',
      name: 'Add_Custom_Material',
      desc: '',
      args: [],
    );
  }

  /// `Search materials`
  String get Search_Materials {
    return Intl.message(
      'Search materials',
      name: 'Search_Materials',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get Delete {
    return Intl.message('Delete', name: 'Delete', desc: '', args: []);
  }

  /// `Name`
  String get Name {
    return Intl.message('Name', name: 'Name', desc: '', args: []);
  }

  /// `E (modulus)`
  String get E_Modulus {
    return Intl.message('E (modulus)', name: 'E_Modulus', desc: '', args: []);
  }

  /// `G (shear modulus)`
  String get G_Shear_Modulus {
    return Intl.message(
      'G (shear modulus)',
      name: 'G_Shear_Modulus',
      desc: '',
      args: [],
    );
  }

  /// `Yield strength`
  String get Yield_Strength {
    return Intl.message(
      'Yield strength',
      name: 'Yield_Strength',
      desc: '',
      args: [],
    );
  }

  /// `Ultimate strength`
  String get Ultimate_Strength {
    return Intl.message(
      'Ultimate strength',
      name: 'Ultimate_Strength',
      desc: '',
      args: [],
    );
  }

  /// `Density`
  String get Density {
    return Intl.message('Density', name: 'Density', desc: '', args: []);
  }

  /// `Pick material`
  String get Pick_Material {
    return Intl.message(
      'Pick material',
      name: 'Pick_Material',
      desc: '',
      args: [],
    );
  }

  /// `Material presets`
  String get Material_Presets {
    return Intl.message(
      'Material presets',
      name: 'Material_Presets',
      desc: '',
      args: [],
    );
  }

  /// `No materials found`
  String get No_Materials_Found {
    return Intl.message(
      'No materials found',
      name: 'No_Materials_Found',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get Save {
    return Intl.message('Save', name: 'Save', desc: '', args: []);
  }

  /// `What if: {label}`
  String What_If(Object label) {
    return Intl.message(
      'What if: $label',
      name: 'What_If',
      desc: '',
      args: [label],
    );
  }

  /// `Drag along the line to explore other values of {label}.`
  String Drag_Along_Line(Object label) {
    return Intl.message(
      'Drag along the line to explore other values of $label.',
      name: 'Drag_Along_Line',
      desc: '',
      args: [label],
    );
  }

  /// `Copied {label}`
  String Copied_Value(Object label) {
    return Intl.message(
      'Copied $label',
      name: 'Copied_Value',
      desc: '',
      args: [label],
    );
  }

  /// `Ball bearing (p = 3)`
  String get Ball_Bearing {
    return Intl.message(
      'Ball bearing (p = 3)',
      name: 'Ball_Bearing',
      desc: '',
      args: [],
    );
  }

  /// `Roller bearing (p = 10/3)`
  String get Roller_Bearing {
    return Intl.message(
      'Roller bearing (p = 10/3)',
      name: 'Roller_Bearing',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get Language {
    return Intl.message('Language', name: 'Language', desc: '', args: []);
  }

  /// `System default`
  String get System_Default {
    return Intl.message(
      'System default',
      name: 'System_Default',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get Search {
    return Intl.message('Search', name: 'Search', desc: '', args: []);
  }

  /// `All`
  String get All {
    return Intl.message('All', name: 'All', desc: '', args: []);
  }

  /// `No matches`
  String get No_Matches {
    return Intl.message('No matches', name: 'No_Matches', desc: '', args: []);
  }

  /// `Try a different size or clear the filters.`
  String get No_Matches_Description {
    return Intl.message(
      'Try a different size or clear the filters.',
      name: 'No_Matches_Description',
      desc: '',
      args: [],
    );
  }

  /// `Drill & Tap Chart`
  String get Drill_Tap_Chart {
    return Intl.message(
      'Drill & Tap Chart',
      name: 'Drill_Tap_Chart',
      desc: '',
      args: [],
    );
  }

  /// `Search a thread size`
  String get Search_Thread_Size {
    return Intl.message(
      'Search a thread size',
      name: 'Search_Thread_Size',
      desc: '',
      args: [],
    );
  }

  /// `Thread`
  String get Thread {
    return Intl.message('Thread', name: 'Thread', desc: '', args: []);
  }

  /// `Pitch / TPI`
  String get Pitch_TPI {
    return Intl.message('Pitch / TPI', name: 'Pitch_TPI', desc: '', args: []);
  }

  /// `Metric coarse`
  String get Metric_Coarse {
    return Intl.message(
      'Metric coarse',
      name: 'Metric_Coarse',
      desc: '',
      args: [],
    );
  }

  /// `Metric fine`
  String get Metric_Fine {
    return Intl.message('Metric fine', name: 'Metric_Fine', desc: '', args: []);
  }

  /// `Unified coarse (UNC)`
  String get Unified_Coarse {
    return Intl.message(
      'Unified coarse (UNC)',
      name: 'Unified_Coarse',
      desc: '',
      args: [],
    );
  }

  /// `Unified fine (UNF)`
  String get Unified_Fine {
    return Intl.message(
      'Unified fine (UNF)',
      name: 'Unified_Fine',
      desc: '',
      args: [],
    );
  }

  /// `Tap drill`
  String get Tap_Drill {
    return Intl.message('Tap drill', name: 'Tap_Drill', desc: '', args: []);
  }

  /// `Clearance close`
  String get Clearance_Close {
    return Intl.message(
      'Clearance close',
      name: 'Clearance_Close',
      desc: '',
      args: [],
    );
  }

  /// `Clearance free`
  String get Clearance_Free {
    return Intl.message(
      'Clearance free',
      name: 'Clearance_Free',
      desc: '',
      args: [],
    );
  }

  /// `Diameters are in mm; inch drills show the designation with its millimetre equivalent below. Tap drills give about 75% thread engagement in steel, and metric clearance holes follow ISO 273 (close and free series). Tap a row to copy it.`
  String get Drill_Tap_Footnote {
    return Intl.message(
      'Diameters are in mm; inch drills show the designation with its millimetre equivalent below. Tap drills give about 75% thread engagement in steel, and metric clearance holes follow ISO 273 (close and free series). Tap a row to copy it.',
      name: 'Drill_Tap_Footnote',
      desc: '',
      args: [],
    );
  }

  /// `Fits & Tolerances (ISO 286)`
  String get Fits_Tolerances {
    return Intl.message(
      'Fits & Tolerances (ISO 286)',
      name: 'Fits_Tolerances',
      desc: '',
      args: [],
    );
  }

  /// `Search a diameter or fit`
  String get Search_Size_Or_Fit {
    return Intl.message(
      'Search a diameter or fit',
      name: 'Search_Size_Or_Fit',
      desc: '',
      args: [],
    );
  }

  /// `Size (mm)`
  String get Nominal_Size_mm {
    return Intl.message(
      'Size (mm)',
      name: 'Nominal_Size_mm',
      desc: '',
      args: [],
    );
  }

  /// `Fit`
  String get Fit {
    return Intl.message('Fit', name: 'Fit', desc: '', args: []);
  }

  /// `Hole (µm)`
  String get Hole_um {
    return Intl.message('Hole (µm)', name: 'Hole_um', desc: '', args: []);
  }

  /// `Shaft (µm)`
  String get Shaft_um {
    return Intl.message('Shaft (µm)', name: 'Shaft_um', desc: '', args: []);
  }

  /// `Clearance (µm)`
  String get Clearance_um {
    return Intl.message(
      'Clearance (µm)',
      name: 'Clearance_um',
      desc: '',
      args: [],
    );
  }

  /// `Hole-basis fits for 1–500 mm. Each cell is the upper limit over the lower, in µm from the nominal size; a negative clearance is interference. Bands run over the lower bound up to the upper. The c, s and u shaft fits are not listed because their deviations split into finer size bands.`
  String get Fits_Footnote {
    return Intl.message(
      'Hole-basis fits for 1–500 mm. Each cell is the upper limit over the lower, in µm from the nominal size; a negative clearance is interference. Bands run over the lower bound up to the upper. The c, s and u shaft fits are not listed because their deviations split into finer size bands.',
      name: 'Fits_Footnote',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'HK'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
