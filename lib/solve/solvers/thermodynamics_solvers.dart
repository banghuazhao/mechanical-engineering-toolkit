import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/air_standard_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/rankine_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/air_cycle_page.dart';
import 'package:mechanical_engineering_toolkit/solve/tool_solver.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

AirCycle _cycleOf(Map<String, String> recorded) {
  for (final cycle in AirCycle.values) {
    if (cycle.name == recorded[airCycleKey]) return cycle;
  }
  return AirCycle.otto;
}

/// 902, air-standard Otto, Diesel and Brayton cycles: the compression or
/// pressure ratio for an efficiency is the classic reverse question.
final airCycleSolver = ToolSolver(
  inputs: (recorded) {
    final cycle = _cycleOf(recorded);
    final usesPeak = cycle == AirCycle.brayton ||
        (cycle == AirCycle.otto && recorded['given'] == 'T3');
    return [
      if (cycle == AirCycle.brayton)
        SolveQuantity('rp', (l) => l.Pressure_Ratio_Rp)
      else
        SolveQuantity('r', (l) => l.Compression_Ratio_R),
      if (cycle == AirCycle.diesel)
        SolveQuantity('rc', (l) => l.Cutoff_Ratio_Rc),
      if (cycle == AirCycle.otto && !usesPeak)
        SolveQuantity('qin', (l) => l.Heat_Added_Qin,
            category: UnitCategory.specificEnergy),
      if (usesPeak)
        SolveQuantity(
          'T3',
          (l) => cycle == AirCycle.brayton
              ? l.Turbine_Inlet_T3
              : l.Peak_Temperature_T3,
          category: UnitCategory.temperature,
          positive: false,
        ),
      if (cycle == AirCycle.brayton) ...[
        SolveQuantity('etaC', (l) => l.Compressor_Efficiency),
        SolveQuantity('etaT', (l) => l.Turbine_Efficiency),
      ],
      SolveQuantity('T1', (l) => l.Inlet_Temperature_T1,
          category: UnitCategory.temperature, positive: false),
      SolveQuantity('k', (l) => l.Specific_Heat_Ratio_K),
    ];
  },
  outputs: (recorded) => [
    SolveQuantity('eta', (l) => l.Thermal_Efficiency),
    SolveQuantity('w', (l) => l.Net_Work,
        category: UnitCategory.specificEnergy, positive: false),
    if (_cycleOf(recorded) == AirCycle.brayton)
      SolveQuantity('bwr', (l) => l.Back_Work_Ratio)
    else
      SolveQuantity('mep', (l) => l.Mean_Effective_Pressure,
          category: UnitCategory.pressure),
  ],
  evaluate: (x) {
    final cycle = _cycleOf(x);
    final r = AirCycleCalculator.calculate(AirCycleInput(
      cycle: cycle,
      t1C: requiredInput(x, 'T1'),
      p1: requiredInput(x, 'p1'),
      cp: requiredInput(x, 'cp'),
      k: requiredInput(x, 'k'),
      compressionRatio: double.tryParse(x['r'] ?? ''),
      cutoffRatio: double.tryParse(x['rc'] ?? ''),
      ottoHeatSpec: x['given'] == 'T3'
          ? OttoHeatSpec.peakTemperature
          : OttoHeatSpec.heatAdded,
      heatAdded: double.tryParse(x['qin'] ?? ''),
      peakTemperatureC: double.tryParse(x['T3'] ?? ''),
      pressureRatio: double.tryParse(x['rp'] ?? ''),
      compressorEfficiency: inputValue(x, 'etaC', 100) / 100,
      turbineEfficiency: inputValue(x, 'etaT', 100) / 100,
    ));
    return {
      'eta': r.efficiency * 100,
      'w': r.netWork,
      'bwr': r.backWorkRatio * 100,
      if (r.meanEffectivePressure != null) 'mep': r.meanEffectivePressure!,
    };
  },
);

/// 903, Rankine steam cycle.
final rankineSolver = ToolSolver(
  inputs: (recorded) => [
    SolveQuantity('pb', (l) => l.Boiler_Pressure,
        category: UnitCategory.pressure),
    SolveQuantity('pc', (l) => l.Condenser_Pressure,
        category: UnitCategory.pressure),
    if (recorded.containsKey('T3'))
      SolveQuantity('T3', (l) => l.Turbine_Inlet_Optional,
          category: UnitCategory.temperature),
    SolveQuantity('etaT', (l) => l.Turbine_Efficiency),
    SolveQuantity('etaP', (l) => l.Pump_Efficiency),
    if (recorded.containsKey('m'))
      SolveQuantity('m', (l) => l.Mass_Flow_Optional,
          category: UnitCategory.massFlow),
  ],
  outputs: (recorded) => [
    SolveQuantity('eta', (l) => l.Thermal_Efficiency),
    SolveQuantity('w', (l) => l.Net_Work,
        category: UnitCategory.specificEnergy),
    SolveQuantity('x', (l) => l.Exit_Quality),
    if (recorded.containsKey('m'))
      SolveQuantity('P', (l) => l.Net_Power, category: UnitCategory.power),
  ],
  evaluate: (x) {
    final r = RankineCalculator.calculate(RankineInput(
      boilerPressure: requiredInput(x, 'pb'),
      condenserPressure: requiredInput(x, 'pc'),
      turbineInletC: double.tryParse(x['T3'] ?? ''),
      turbineEfficiency: inputValue(x, 'etaT', 100) / 100,
      pumpEfficiency: inputValue(x, 'etaP', 100) / 100,
      massFlow: double.tryParse(x['m'] ?? ''),
    ));
    return {
      'eta': r.efficiency * 100,
      'w': r.netWork,
      if (r.exitQuality != null) 'x': r.exitQuality!,
      if (r.netPower != null) 'P': r.netPower!,
    };
  },
);
