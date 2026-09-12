import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/iapws_if97.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/steam_tables_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/thermo_widgets.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/line_plot_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

String steamPhaseLabel(BuildContext context, SteamPhase phase) {
  final l10n = S.of(context);
  return switch (phase) {
    SteamPhase.compressedLiquid => l10n.Phase_Compressed_Liquid,
    SteamPhase.wetMixture => l10n.Phase_Wet_Mixture,
    SteamPhase.superheatedVapour => l10n.Phase_Superheated,
    SteamPhase.supercriticalFluid => l10n.Phase_Supercritical,
  };
}

class SteamTablesResultPage extends StatelessWidget {
  const SteamTablesResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.result,
  });

  final int toolId;
  final String title;
  final SteamTableResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);

    String f(double value, UnitCategory? category) =>
        precs.formatSI(value, category, system);
    String tC(double kelvin) => f(kelvin - 273.15, UnitCategory.temperature);
    String kPa(double mpa) => f(mpa * 1000, UnitCategory.pressure);

    final sat = result.saturation;
    final point = result.point;
    final sections = <ResultSection>[];
    final steps = <String>[];
    String? tex;

    if (sat != null && point == null) {
      final liquid = sat.liquid;
      final vapour = sat.vapour;
      sections.addAll([
        ResultSection(title: title, values: [
          ResultValue(
            label: l10n.Saturation_Temperature,
            valueSI: sat.temperature - 273.15,
            category: UnitCategory.temperature,
          ),
          ResultValue(
            label: l10n.Saturation_Pressure,
            valueSI: sat.pressure * 1000,
            category: UnitCategory.pressure,
          ),
        ]),
        _stateSection(l10n.Saturated_Liquid, liquid, l10n),
        ResultSection(title: l10n.Evaporation, values: [
          ResultValue(
            label: l10n.Latent_Heat_Hfg,
            valueSI: sat.hfg,
            category: UnitCategory.specificEnergy,
          ),
          ResultValue(
            label: l10n.Entropy_Of_Vaporization,
            valueSI: sat.sfg,
            category: UnitCategory.specificEntropy,
          ),
        ]),
        _stateSection(l10n.Saturated_Vapour, vapour, l10n),
      ]);
      steps.addAll([
        'Tsat = ${tC(sat.temperature)}, psat = ${kPa(sat.pressure)}',
        'hfg = hg − hf = ${f(vapour.enthalpy, UnitCategory.specificEnergy)}'
            ' − ${f(liquid.enthalpy, UnitCategory.specificEnergy)}'
            ' = ${f(sat.hfg, UnitCategory.specificEnergy)}',
        'sfg = sg − sf = ${f(vapour.entropy, UnitCategory.specificEntropy)}'
            ' − ${f(liquid.entropy, UnitCategory.specificEntropy)}'
            ' = ${f(sat.sfg, UnitCategory.specificEntropy)}',
      ]);
      tex = r'h_{fg} = h_g - h_f, \qquad s_{fg} = \frac{h_{fg}}{T_{sat}}';
    } else if (point != null) {
      final phase = result.phase!;
      final values = <ResultValue>[
        ResultValue(label: l10n.Phase_State, value: steamPhaseLabel(context, phase)),
        ResultValue(
          label: l10n.Temperature_T,
          valueSI: point.temperature - 273.15,
          category: UnitCategory.temperature,
        ),
        ResultValue(
          label: l10n.Pressure_P,
          valueSI: point.pressure * 1000,
          category: UnitCategory.pressure,
        ),
        if (point.quality != null)
          ResultValue(label: l10n.Quality_X, valueSI: point.quality!),
        ResultValue(
          label: l10n.Specific_Volume_V,
          valueSI: point.specificVolume,
          category: UnitCategory.specificVolume,
          smallMagnitude: true,
        ),
        ResultValue(
          label: l10n.Density_Rho,
          valueSI: point.density,
          category: UnitCategory.density,
        ),
        ResultValue(
          label: l10n.Specific_Internal_Energy_U,
          valueSI: point.internalEnergy,
          category: UnitCategory.specificEnergy,
        ),
        ResultValue(
          label: l10n.Specific_Enthalpy_H,
          valueSI: point.enthalpy,
          category: UnitCategory.specificEnergy,
        ),
        ResultValue(
          label: l10n.Specific_Entropy_S,
          valueSI: point.entropy,
          category: UnitCategory.specificEntropy,
        ),
        if (point.single case final single?) ...[
          ResultValue(
            label: l10n.Specific_Heat_Cp,
            valueSI: single.cp,
            category: UnitCategory.specificEntropy,
          ),
          ResultValue(
            label: l10n.Specific_Heat_Cv,
            valueSI: single.cv,
            category: UnitCategory.specificEntropy,
          ),
          if (single.speedOfSound.isFinite)
            ResultValue(
              label: l10n.Speed_Of_Sound,
              valueSI: single.speedOfSound,
              category: UnitCategory.velocity,
            ),
          ResultValue(label: l10n.IF97_Region, value: '${single.region}'),
        ],
      ];
      sections.add(ResultSection(title: l10n.Steam_State, values: values));
      if (point.saturation case final mix?) {
        sections.add(_stateSection(l10n.Saturated_Liquid, mix.liquid, l10n));
        sections.add(_stateSection(l10n.Saturated_Vapour, mix.vapour, l10n));
        final x = point.quality!;
        steps.addAll([
          'Tsat = ${tC(mix.temperature)}, x = ${precs.formatValue(x)}',
          'h = hf + x·hfg = ${f(mix.liquid.enthalpy, UnitCategory.specificEnergy)}'
              ' + ${precs.formatValue(x)} × ${f(mix.hfg, UnitCategory.specificEnergy)}'
              ' = ${f(point.enthalpy, UnitCategory.specificEnergy)}',
          's = sf + x·sfg = ${f(mix.liquid.entropy, UnitCategory.specificEntropy)}'
              ' + ${precs.formatValue(x)} × ${f(mix.sfg, UnitCategory.specificEntropy)}'
              ' = ${f(point.entropy, UnitCategory.specificEntropy)}',
          'v = vf + x·(vg − vf) = ${precs.formatSmallSI(point.specificVolume, UnitCategory.specificVolume, system)}',
        ]);
        tex = r'y = y_f + x\,(y_g - y_f), \qquad x = \frac{h - h_f}{h_{fg}}';
      } else {
        final single = point.single!;
        steps.addAll([
          'IAPWS-IF97 region ${single.region}: '
              '${single.region == 3 ? 'f(ρ, T) = φ(δ, τ)' : 'g(p, T) = γ(π, τ)'}',
          'p = ${kPa(single.pressure)}, T = ${tC(single.temperature)}',
          if (single.pressure < If97.pc)
            'Tsat(p) = ${tC(If97.saturationTemperature(single.pressure))}'
                ' → ${steamPhaseLabel(context, phase)}',
          'h = ${f(single.enthalpy, UnitCategory.specificEnergy)}, '
              's = ${f(single.entropy, UnitCategory.specificEntropy)}, '
              'v = ${precs.formatSmallSI(single.specificVolume, UnitCategory.specificVolume, system)}',
        ]);
        tex = single.region == 3
            ? r'\frac{f(\rho,T)}{RT} = \phi(\delta,\tau), \quad '
                r'h = RT\,(\tau\phi_\tau + \delta\phi_\delta)'
            : r'\frac{g(p,T)}{RT} = \gamma(\pi,\tau), \quad '
                r'h = RT\,\tau\,\gamma_\tau, \quad s = R\,(\tau\gamma_\tau - \gamma)';
      }
    }

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: sections,
      children: [
        FormulaCard(steps: steps, tex: tex),
        _TsCard(result: result, system: system),
        ResultFootnote(l10n.Steam_Tables_Note),
      ],
    );
  }

  ResultSection _stateSection(String title, SteamProperties state, S l10n) =>
      ResultSection(title: title, values: [
        ResultValue(
          label: l10n.Specific_Volume_V,
          valueSI: state.specificVolume,
          category: UnitCategory.specificVolume,
          smallMagnitude: true,
        ),
        ResultValue(
          label: l10n.Specific_Internal_Energy_U,
          valueSI: state.internalEnergy,
          category: UnitCategory.specificEnergy,
        ),
        ResultValue(
          label: l10n.Specific_Enthalpy_H,
          valueSI: state.enthalpy,
          category: UnitCategory.specificEnergy,
        ),
        ResultValue(
          label: l10n.Specific_Entropy_S,
          valueSI: state.entropy,
          category: UnitCategory.specificEntropy,
        ),
        ResultValue(
          label: l10n.Specific_Heat_Cp,
          valueSI: state.cp,
          category: UnitCategory.specificEntropy,
        ),
      ]);
}

/// The saturation dome with this lookup's state — or, for a saturation row,
/// the two ends of the tie line across it.
class _TsCard extends StatelessWidget {
  const _TsCard({required this.result, required this.system});

  final SteamTableResult result;
  final UnitSystem system;

  Offset _p(double s, double tK) => plotPoint(s, UnitCategory.specificEntropy,
      tK - 273.15, UnitCategory.temperature, system);

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final precs = context.watch<NumberPrecisionHelper>();
    final dome = [
      for (final point in SteamTablesCalculator.saturationDome)
        _p(point.s, point.t),
    ];
    final markers = <PlotMarker>[];
    final lines = <PlotSeries>[];
    final sat = result.saturation;
    final point = result.point;
    if (sat != null && point == null) {
      final f = _p(sat.liquid.entropy, sat.temperature);
      final g = _p(sat.vapour.entropy, sat.temperature);
      lines.add(PlotSeries(points: [f, g], width: 2.5));
      markers
        ..add(PlotMarker(f, 'f'))
        ..add(PlotMarker(g, 'g'));
    } else if (point != null) {
      if (point.saturation case final mix?) {
        lines.add(PlotSeries(
          points: [
            _p(mix.liquid.entropy, mix.temperature),
            _p(mix.vapour.entropy, mix.temperature),
          ],
          dashed: true,
          width: 1.5,
        ));
      }
      final temperature = fromSI(
          point.temperature - 273.15, UnitCategory.temperature, system);
      markers.add(PlotMarker(
        _p(point.entropy, point.temperature),
        precs.formatValue(temperature) +
            unitLabel(UnitCategory.temperature, system),
      ));
    }
    return LinePlotCard(
      title: l10n.Ts_Diagram,
      xAxisLabel: axisLabel('s', UnitCategory.specificEntropy, system),
      yAxisLabel: axisLabel('T', UnitCategory.temperature, system),
      series: [
        PlotSeries(
          points: dome,
          tone: PlotTone.muted,
          width: 1.5,
          label: l10n.Saturation_Dome,
        ),
        ...lines,
      ],
      markers: markers,
    );
  }
}
