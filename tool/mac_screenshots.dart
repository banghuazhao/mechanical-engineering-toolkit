// Renders the App Store screenshots for the macOS listing.
//
//     flutter run -d macos -t tool/mac_screenshots.dart --release
//
// Writes one directory of PNGs per app language and quits. Re-run it whenever the UI or the copy changes.
//
// Why a harness rather than screen capture: driving the real app through five
// screens needs Accessibility permission to synthesise clicks, and the result
// would still depend on this machine's display size and scale factor. Here the
// screens are constructed directly, laid out at a fixed 1280x800 logical size
// and captured at devicePixelRatio 2, so the output is byte-for-byte the same
// on any Mac. It is still the real app: real widgets, real fonts, real theme,
// real calculations — not mockups.
//
// The scenes deliberately show the *free* state, padlocks and all. A listing
// that hides the paywall until after install is both worse for the reader and
// a rejection risk.
//
// Captures come out at [_logicalSize] and are scaled to the store's size
// afterwards by tool/mac_screenshots_finish.py — see the note on
// [_logicalSize] for why the capture cannot simply be rendered at 2x.
//
// The window has to be at least as large as a scene, because Flutter never
// rasterizes what is off screen — a smaller window yields a capture of the
// right pixel size whose bottom and right are black. The harness refuses to
// run in one; resize the window and run again.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/beam_flexure_formula_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/beam_flexure_formula_result.dart';
import 'package:mechanical_engineering_toolkit/home/reference/fits_tolerances_page.dart';
import 'package:mechanical_engineering_toolkit/home/reference/standard_sections_page.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/theme_preference.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';

/// Logical size of a captured scene, and — because the capture is 1:1 — its
/// pixel size too. `tool/mac_screenshots_finish.py` scales these up to the
/// 1280x800 the Mac App Store wants.
///
/// Two constraints pin these numbers down.
///
/// The 1:1 ratio is forced, not chosen. `RenderRepaintBoundary.toImage` is
/// supposed to rasterize at whatever `pixelRatio` it is given, and here it
/// does not: it allocates the larger canvas and then draws the recorded
/// picture unscaled, leaving everything past the logical size black. Measured
/// directly — one 1024x640 boundary captured at 1.0, 2.0 and 2.5 produced
/// 1024x640, 2048x1280 and 2560x1600 images whose *painted* area was 1024x640
/// every time.
///
/// And the scene cannot be larger than the window, because Flutter never
/// paints what is off screen. The app opens at 1100x800, so 1024x640 fits
/// with room to spare while keeping the 16:10 the store sizes all use.
const Size _logicalSize = Size(1024, 640);
const double _pixelRatio = 1;

/// Every language the app is translated into, rendered in one run.
///
/// The App Store shows storefront-local screenshots when they exist, and a
/// German engineer being shown an English UI is exactly the friction the
/// translations were done to remove. The directory name is what
/// `scripts/appstore_mac_listing.py` maps each storefront onto.
const Map<String, Locale> _languages = {
  'en': Locale('en', ''),
  'de': Locale('de', ''),
  'fr': Locale('fr', ''),
  'ja': Locale('ja', ''),
  'zh': Locale('zh', ''),
  'zh_HK': Locale('zh', 'HK'),
};

/// Where the PNGs land.
///
/// Not a path in the repo: the harness is the real app bundle and runs inside
/// the App Sandbox, which can only write within its own container. `HOME` is
/// rewritten to that container, so this resolves to
/// ~/Library/Containers/<bundle>/Data/Documents/me_toolkit_store. The run
/// prints the absolute path; copy the files out from there.
final String _outputDir =
    '${Platform.environment['HOME']}/Documents/me_toolkit_store';

/// One screenshot: the file stem, and the screen to draw.
class Scene {
  const Scene(this.name, this.builder, {this.dark = false});

  final String name;
  final WidgetBuilder builder;

  /// Renders in dark mode. One dark scene shows the app has one, which is a
  /// question a Mac buyer actually asks.
  final bool dark;
}

final List<Scene> _scenes = [
  // The library: sixty tools, the search, and the free-tier count in one
  // frame. This is the shot that has to carry the whole app.
  Scene('01-library', (_) => const ToolPage()),

  // A calculator mid-use, pre-filled. Shows the governing equation and the
  // labelled, unit-aware fields — the actual interaction, not a menu.
  //
  // The inputs are an ordinary steel beam check, in the units the fields use
  // (N·mm, mm⁴, mm): a 42 kN·m moment on a 1.2e8 mm⁴ section, 80 mm from the
  // neutral axis.
  Scene(
    '02-calculator',
    (context) => BeamFlexureFormulaPage(
      title: ToolLibrary.shared.item(_flexureToolId, context).title,
      toolId: _flexureToolId,
      initialInputs: const {
        'M': '42000000',
        'I': '120000000',
        'y': '80',
      },
    ),
  ),

  // ...and its result: the answer, the formula, and the formula again with
  // this calculation's numbers substituted. The single most distinguishing
  // thing about this app versus a calculator.
  Scene(
    '03-result',
    (_) => BeamFlexureFormulaResultPage(
      toolId: _flexureToolId,
      // -M/I, so stress at a given y is coefficient * y: -0.35 MPa/mm here,
      // which puts the fibre at y = 80 mm at -28 MPa.
      coefficient: -42000000 / 120000000,
      y: 80,
      m: 42000000,
      i: 120000000,
    ),
  ),

  // A reference table, which is the half of the app people open daily.
  Scene('04-sections', (_) => const StandardSectionsPage()),

  // A second table, in dark mode — the app follows the system appearance, and
  // that is a question every Mac buyer asks.
  Scene('05-fits', (_) => const FitsTolerancesPage(), dark: true),
];

/// Flexure Formula of Beam — free in the macOS tier, so nothing in the
/// calculator and result shots is behind the paywall they advertise.
const int _flexureToolId = 104;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  // A clean slate every run, so a stray favourite or a previous session's
  // history cannot change what the screenshots show.
  await SharedPreferencesHelper.localStorage.clear();

  runApp(const _ScreenshotHarness());
}

class _ScreenshotHarness extends StatefulWidget {
  const _ScreenshotHarness();

  @override
  State<_ScreenshotHarness> createState() => _ScreenshotHarnessState();
}

class _ScreenshotHarnessState extends State<_ScreenshotHarness> {
  final GlobalKey _boundaryKey = GlobalKey();
  int _index = 0;
  String _language = _languages.keys.first;
  String _status = 'starting';

  /// No store, so nothing here waits on a network round trip. The scenes are
  /// all free-tier screens, so the entitlement never comes into it — but the
  /// tool library still reads the gate to draw its padlocks, which is exactly
  /// the state a prospective buyer should see.
  final RemoveAdsService _purchases = RemoveAdsService(store: AppStore.none);

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    _requireWindowLargeEnough();

    var written = 0;
    for (final language in _languages.keys) {
      final dir = Directory('$_outputDir/$language');
      await dir.create(recursive: true);

      for (var i = 0; i < _scenes.length; i++) {
        setState(() {
          _language = language;
          _index = i;
          _status = 'rendering $language/${_scenes[i].name}';
        });
        // Long enough for the scene to build and lay out, and for the tool
        // grid's staggered entrance to finish — a capture mid-fade would show
        // half-transparent tiles.
        await _settle(const Duration(milliseconds: 900));
        final bytes = await _capture();
        final file = File('${dir.path}/${_scenes[i].name}.png');
        await file.writeAsBytes(bytes);
        written++;
        stdout.writeln('wrote $language/${_scenes[i].name}.png '
            '(${bytes.length ~/ 1024} KB)');
      }
    }

    stdout.writeln('SCREENSHOTS_DIR=$_outputDir');
    stdout.writeln('done: $written screenshots '
        'across ${_languages.length} languages');
    exit(0);
  }

  /// Refuses to run in a window smaller than a screenshot.
  ///
  /// Flutter only rasterizes what is on screen. A scene pinned to
  /// [_logicalSize] inside a smaller window lays out correctly — the capture
  /// is even the right pixel size — but everything past the window edge was
  /// never painted, so it comes back black. That failure is silent and looks
  /// like a styling bug, so it is worth stopping for.
  ///
  /// The window is sized by its frame autosave; see the header comment.
  void _requireWindowLargeEnough() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logical = view.physicalSize / view.devicePixelRatio;
    if (logical.width + 0.5 < _logicalSize.width ||
        logical.height + 0.5 < _logicalSize.height) {
      stderr.writeln(
        'Window is ${logical.width.toStringAsFixed(0)}x'
        '${logical.height.toStringAsFixed(0)} logical, but a screenshot needs '
        'at least ${_logicalSize.width.toStringAsFixed(0)}x'
        '${_logicalSize.height.toStringAsFixed(0)}. Anything outside the '
        'window is never painted and would be captured black.\n'
        'Enlarge the window (see tool/mac_screenshots.dart) and re-run.',
      );
      exit(2);
    }
  }

  /// Pumps frames until [duration] has passed, so animations reach their end
  /// state. `pumpAndSettle` belongs to the test binding and is not available
  /// in a running app.
  Future<void> _settle(Duration duration) async {
    final deadline = DateTime.now().add(duration);
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 32));
      SchedulerBinding.instance.scheduleFrame();
    }
    await SchedulerBinding.instance.endOfFrame;
  }

  Future<Uint8List> _capture() async {
    final boundary = _boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    // A scene that failed to take the fixed size would otherwise show up only
    // as a small picture in a big black frame, which is easy to miss.
    if (boundary.size != _logicalSize) {
      throw StateError('scene laid out at ${boundary.size}, '
          'expected $_logicalSize');
    }
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    // One MaterialApp, at the root. An earlier version wrapped each scene in
    // its own MaterialApp inside a fixed-size box; that does not work, because
    // WidgetsApp installs a MediaQuery derived from the real window and the
    // app laid itself out to the harness window rather than to the box. Here
    // the app is the root, and the scene below it is the thing pinned to
    // _logicalSize — a Scaffold obeys its constraints.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RemoveAdsService>.value(value: _purchases),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => ToolHistory()),
        ChangeNotifierProvider(create: (_) => SavedProjects()),
        ChangeNotifierProvider(create: (_) => MaterialLibrary()),
        ChangeNotifierProvider(create: (_) => LanguagePreference()),
        ChangeNotifierProvider(create: (_) => ThemePreference()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: AppTheme.light(),
        home: Builder(builder: _stage),
      ),
    );
  }

  /// The fixed-size canvas the current scene is drawn on.
  Widget _stage(BuildContext context) {
    final scene = _scenes[_index];
    return Stack(
      key: ValueKey('$_language/${scene.name}'),
      children: [
        Positioned(
          left: 0,
          top: 0,
          // Lifts the harness window's constraints, so the box below takes its
          // full size even when the window is smaller than a screenshot.
          child: OverflowBox(
            minWidth: 0,
            maxWidth: double.infinity,
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _logicalSize.width,
              height: _logicalSize.height,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: MediaQuery(
                  // Overrides the window-derived data the app installed, so
                  // anything reading MediaQuery.sizeOf agrees with the box.
                  data: const MediaQueryData(
                    size: _logicalSize,
                    devicePixelRatio: _pixelRatio,
                  ),
                  child: Theme(
                    data: scene.dark ? AppTheme.dark() : AppTheme.light(),
                    child: Localizations.override(
                      context: context,
                      locale: _languages[_language],
                      child: Builder(builder: scene.builder),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: IgnorePointer(
            child: Text(
              _status,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ),
        ),
      ],
    );
  }
}
