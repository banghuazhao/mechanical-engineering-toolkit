import 'package:flutter/material.dart';

import '../util/material_library.dart';
import 'preset_library.dart';

/// A small button that opens the isotropic material library — built-in and
/// custom presets (E, G, ν, yield, ultimate strength, density). Selecting one
/// invokes [onSelected]; callers copy over whichever fields they use and call
/// setState.
///
/// Not for composite lamina properties (E1/E2/G12/ν12) — those are a
/// different data shape; see `LaminaPresetButton`.
class MaterialPresetButton extends StatelessWidget {
  const MaterialPresetButton({super.key, required this.onSelected});

  final ValueChanged<MaterialPreset> onSelected;

  @override
  Widget build(BuildContext context) => PresetLibraryButton<MaterialPreset>(
        library: isotropicPresetLibrary,
        onSelected: onSelected,
      );
}
