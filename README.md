# Mechanical Engineering Toolkit

[![App Store](https://img.shields.io/badge/App_Store-Download-0D96F6?logo=apple&logoColor=white)](https://apps.apple.com/app/id1601099443)
[![Google Play](https://img.shields.io/badge/Google_Play-Download-414141?logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.appsbay.mechanical_engineering_toolkit)
[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A cross-platform engineering calculator for students, researchers, and practising
engineers. Over 50 tools spanning mechanics of materials, beam analysis, statics,
machine design and vibration, fluids and heat transfer, elasticity, and composites
— each one showing the governing formula, the substituted calculation steps, and a
result you can export or share.

<p align="center">
  <img src="./doc_images/1.webp" alt="Tool library" width="220"/>
  <img src="./doc_images/2.webp" alt="Calculator input" width="220"/>
  <img src="./doc_images/3.webp" alt="Results with calculation steps" width="220"/>
</p>

## Features

- **Transparent calculations.** Every result page shows the governing formula with
  values substituted, not just a number.
- **SI and Imperial throughout.** Switch unit systems at any time; every field
  converts in place.
- **Configurable precision.** Auto, scientific, decimal, or engineering notation,
  with adjustable significant figures.
- **Projects.** Save any calculation's inputs under a name and reopen it later.
- **Export and share.** Any result as text, image, CSV, or PDF report.
- **Material and section libraries.** Isotropic materials, fluid properties,
  thermal materials, and standard steel sections.
- **Discovery.** Full-text search, favourites, history, and recommendations by
  engineering major.
- **Six languages.** English, German, French, Japanese, Simplified Chinese, and
  Traditional Chinese.
- **Light, dark, or system appearance.**

## Tool catalogue

| Category | Tools | Coverage |
|---|---:|---|
| Mechanics of Material | 16 | General stress, bar force–displacement, torsion and angle of twist, plane-stress transformation, principal stresses, Mohr's circle, spherical shell, thin-walled cylindrical pressure vessel, column buckling, thermal deformation, shaft power and torque, Von Mises / Tresca, fatigue safety factor (Modified Goodman), bolted and riveted joints, combined loading |
| Beam Engineering | 7 | Moments of inertia, flexure formula, cantilever and simple-beam deflections and slopes, transverse shear stress, beam section properties, beam load analysis |
| Machine Design | 11 | Helical compression springs, spur gear geometry, shaft fatigue design (DE-Goodman), bearing L10 life, belt and chain drives, bolt preload / torque-tension, fillet weld strength, press / shrink-fit interference, shaft critical speed (Dunkerley), beam natural frequency (first three modes, five end conditions), torsional natural frequency (one or two rotors) |
| Fluids & Thermal | 6 | Reynolds number and flow regime, pipe pressure drop (Darcy–Weisbach with Colebrook), pump and fan power, composite wall conduction, fin efficiency, heat exchanger sizing by LMTD |
| Composite Material | 7 | Lamina and laminate stress/strain, lamina engineering constants, laminate plane and 3D properties, rule of mixtures, Tsai-Hill and Tsai-Wu failure criteria |
| Statics | 3 | Resultant of forces (2D), centroid of composite area, truss analysis by method of joints |
| Theory of Elasticity | 2 | Constitutive relation and stress/strain of linear elastic material |
| Reference & Utilities | 4 | Unit converter, drill and tap chart, ISO 286 fits and tolerances, standard sections (AISC W, IPE, HEB) |

[`lib/home/tool_model.dart`](lib/home/tool_model.dart) is the authoritative registry.

## Requirements

| | |
|---|---|
| Flutter | 3.44 or newer |
| Dart | `>=3.0.0 <4.0.0` |
| iOS | 15.0+ |
| Android | 7.0+ (API 24) |

iOS plugins are managed by **Swift Package Manager**, not CocoaPods — there is no
`Podfile` and no `ios/Pods` directory.

## Getting started

```bash
git clone https://github.com/banghuazhao/mechanical-engineering-toolkit.git
cd mechanical-engineering-toolkit
flutter pub get
flutter run
```

Run the test suite with `flutter test`.

## Building a release

Release builds read AdMob identifiers, signing configuration, and the version
number from files that are deliberately **not** in this repository. Supply your
own before building:

| File | Contents |
|---|---|
| `lib/util/secrets.dart` | AdMob **ad unit** IDs (banner and app-open, per platform). Google **test** unit IDs are substituted automatically in debug builds. |
| `android/local.properties` | `AdMobAppId` (injected into the manifest as `com.google.android.gms.ads.APPLICATION_ID`), plus `flutter.versionName` and `flutter.versionCode`. Falls back to a Google test app ID when absent. |
| `android/key.properties` + keystore | Release signing. |

`ios/SecretsRelease.xcconfig` and `ios/SecretsDebug.xcconfig` are committed: they
carry only the AdMob **app** ID, which is not a secret — it ships inside every
build's `Info.plist`.

```bash
flutter build appbundle --release   # Android App Bundle
flutter build ipa --release         # iOS App Store package
```

## Adding a new calculator

New tools follow the pattern of recent additions — for example
[`bolted_joint_page.dart`](lib/home/mechancs_of_material/page/bolted_joint_page.dart)
with its result page, or [`centroid_page.dart`](lib/home/statics/page/centroid_page.dart)
— rather than the older per-tool `model/` + `widget/…Row.dart` split. Mechanics of
Material and Beam Engineering are fully migrated; the two Theory of Elasticity and
seven Composite Material tools still use the older split, because their
matrix-heavy UIs make that a separate piece of work. Follow the current pattern
for anything new, including in those areas.

### File layout

- Input page: `lib/home/<category>/page/<tool>_page.dart`
- Result page: `lib/home/<category>/page/<tool>_result_page.dart`
- Register a `Tool` entry in [`tool_model.dart`](lib/home/tool_model.dart)
  (`ToolLibrary.getTools`), taking the next free id in the category block:
  `100s` Mechanics of Material and Beam Engineering · `200s` Theory of
  Elasticity · `300s` Composite Material · `400s` Statics · `500s` Reference and
  Utilities · `700s` Machine Design, vibration included · `800s` Fluids &
  Thermal.

### Requirements for every new tool

1. **Respect the unit system.** Every physical input and output uses
   [`UnitField`](lib/util/unit_field.dart) with a `UnitCategory` from
   [`units.dart`](lib/util/units.dart); add a category if none fits, and give it
   a hand-checked row in the `_known` table in
   [`units_test.dart`](test/units_test.dart) — the suite fails until every
   category has one, which is what stops a `kN` label shipping with an `N`
   factor. Never hardcode a unit string; `UnitField` renders the correct suffix
   and converts in place from `UnitSystemPreference`.
2. **Respect precision settings.** Route displayed values through
   `NumberPrecisionHelper.formatValue()`, directly or via the shared
   `AppCopyableValue` / `UnitField` widgets. Never call `toStringAsFixed(n)` on a
   user-facing result.
3. **Typeset the formula, don't spell it out.** Say what the tool computes in
   prose, then set the governing equation with `Math.tex` from
   `flutter_math_fork` — under the description on the input page, and passed as
   `FormulaCard(steps: …, tex: …)` on the result page. Keep the description
   itself formula-free: an ASCII `fn = (bL)^2/(2*pi*L^2)*sqrt(EI/(rho*A))` above
   a typeset copy of the same thing reads as a mistake. The plain-text steps
   stay alongside the equation and carry the substituted numbers — they are also
   the only part that reaches the PDF report, which draws text and not math. See
   [`torsional_frequency_page.dart`](lib/home/vibration/page/torsional_frequency_page.dart)
   and its result page.
4. **Draw the tool a real icon.** Set
   `image: AssetImage('images/icons/icon_<tool>.png')` on the `Tool` entry and
   draw the illustration by adding a function to
   [`tool/make_tool_icons.py`](tool/make_tool_icons.py), then re-running it. The
   house style, sampled from the hand-drawn originals: white ground, black
   outlines, `#E8D8C8` for a solid body, `#D8D8D8` for a secondary one, and
   `#E02020` for whatever the diagram is actually about. Show the mechanism, not
   a symbol — the shaft critical speed icon is a rotor on a bowed shaft with a
   rotation arrow, which is what distinguishes it from the statically deflected
   beam next to it. `icon:` with a Material glyph is reserved for the reference
   tables that have no mechanism to draw, such as the drill and tap chart; a
   generic glyph anywhere else reads as an unfinished placeholder.
5. **Make results shareable.** Offer both `shareResult(toolName, lines)` and
   `shareResultImage(exportKey, toolName)` from
   [`share_helper.dart`](lib/util/share_helper.dart) in `AppBar.actions`. For the
   image export, wrap the page's `AppContent` in a `RepaintBoundary` keyed by a
   non-`const` `final _exportKey = GlobalKey();`.
6. **Wire up the Hero animation.** Make `ToolResultHeader(tool: tool)` the first
   child of both the input and result lists. It already wraps the icon in a
   `Hero(tag: 'tool_icon_${tool.id}')` matching the list tiles, so the icon flies
   from list to input page to result page with no further code. Skip only for
   tools without a single-result moment, such as the unit converter.
7. **Illustrate where it helps.** Add a diagram under `images/` when one clarifies
   the setup. For x-versus-y curves use the shared
   [`XYDiagramCard`](lib/ui/xy_diagram_card.dart) rather than a new
   `CustomPainter`.
8. **Record history.** Call
   `context.read<ToolHistory>().record(widget.toolId, inputs: {…})` on success and
   parse the same keys back out of `widget.initialInputs` in `initState`, so
   History and Favourites re-entry works.
9. **Use the design system.** Build from `AppContent`, `AppSectionCard`,
   `AdaptiveFieldGrid`, `AppCopyableValue`, and `context.tokens` rather than raw
   `Card` / `Padding` with magic numbers. Add the settings action and
   `bottomNavigationBar: const AppBannerAd()` to the result page — the banner
   already no-ops once Remove Ads is purchased.
10. **Validate inputs.** Throw `FormatException` in `_calculate()` and surface it
    as a `SnackBar` rather than failing silently.
11. **Offer presets and sweeps where they fit.** Add a
    [`MaterialPresetButton`](lib/ui/material_preset_picker.dart) for isotropic
    properties (E, G, yield/ultimate strength, density, ν), and a
    [`ParameterSweepCard`](lib/ui/parameter_sweep_card.dart) when the output is a
    single scalar function of the inputs.
12. **Test and register.** Add a unit test under `test/` when the maths is
    non-trivial, list the tool in this README, and add its id to the relevant
    majors in [`major_recommendation.dart`](lib/home/major_recommendation.dart) —
    nothing fails if you forget, but "Recommended by Major" silently misses it.

### Unit conventions: two systems coexist

Most tools work in true SI (E in Pa, L in m) and convert only at the
`UnitField` display boundary — see `simply_supported_beam_calculator.dart`.

Several "quick formula" tools (column buckling, bar force–displacement, angle of
twist, beam flexure) instead work entirely in **mm–N–MPa**: length in mm, force in
N, moment in N·mm, stress in MPa, second moment of area in mm⁴. In that system the
raw values from `UnitCategory.length` / `.force` / `.momentSection` / `.stress` /
`.momentOfInertia` combine with no conversion factors — `σ = M·y/I` yields MPa
directly.

If such a tool takes an elastic or shear modulus, keep the field as
`UnitCategory.modulus` (GPa, which is what `MaterialPresetButton` supplies) but
**multiply by 1000 at the point of use**, since 1 GPa = 1000 MPa. See the
`e * 1000` and `g * 1000` calls in `column_buckling_load_page.dart` and
`angle_of_twist_page.dart`. Getting this wrong silently produces results off by a
factor of 1000, so copy one of those files rather than re-deriving the conversion.

## Contributing

Issues and pull requests are welcome — particularly new calculators, translations,
and corrections to engineering formulas or reference data.

1. Fork the repository and create a feature branch.
2. Follow the conventions in [Adding a new calculator](#adding-a-new-calculator).
3. Run `flutter test` and `flutter analyze` before opening a pull request.
4. Keep commits focused and their messages descriptive.

## Contact

- Issues and feature requests: [GitHub Issues](https://github.com/banghuazhao/mechanical-engineering-toolkit/issues)
- Maintainer: [@banghuazhao](https://github.com/banghuazhao)

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
