import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _UnitCategory {
  final String name;
  final IconData icon;
  final List<_Unit> units;
  const _UnitCategory({required this.name, required this.icon, required this.units});
}

class _Unit {
  final String label;
  // toBase converts this unit to the SI base unit
  final double Function(double) toBase;
  // fromBase converts the SI base unit to this unit
  final double Function(double) fromBase;
  const _Unit({required this.label, required this.toBase, required this.fromBase});
}

const _categories = <_UnitCategory>[
  _UnitCategory(
    name: 'Length',
    icon: Icons.straighten_rounded,
    units: [
      _Unit(label: 'mm', toBase: _mm2m, fromBase: _m2mm),
      _Unit(label: 'cm', toBase: _cm2m, fromBase: _m2cm),
      _Unit(label: 'm',  toBase: _id,   fromBase: _id),
      _Unit(label: 'km', toBase: _km2m, fromBase: _m2km),
      _Unit(label: 'in', toBase: _in2m, fromBase: _m2in),
      _Unit(label: 'ft', toBase: _ft2m, fromBase: _m2ft),
      _Unit(label: 'yd', toBase: _yd2m, fromBase: _m2yd),
      _Unit(label: 'mi', toBase: _mi2m, fromBase: _m2mi),
    ],
  ),
  _UnitCategory(
    name: 'Force',
    icon: Icons.arrow_downward_rounded,
    units: [
      _Unit(label: 'N',   toBase: _id,     fromBase: _id),
      _Unit(label: 'kN',  toBase: _kN2N,   fromBase: _N2kN),
      _Unit(label: 'MN',  toBase: _MN2N,   fromBase: _N2MN),
      _Unit(label: 'lbf', toBase: _lbf2N,  fromBase: _N2lbf),
      _Unit(label: 'kip', toBase: _kip2N,  fromBase: _N2kip),
    ],
  ),
  _UnitCategory(
    name: 'Stress / Pressure',
    icon: Icons.compress_rounded,
    units: [
      _Unit(label: 'Pa',  toBase: _id,      fromBase: _id),
      _Unit(label: 'kPa', toBase: _kPa2Pa,  fromBase: _Pa2kPa),
      _Unit(label: 'MPa', toBase: _MPa2Pa,  fromBase: _Pa2MPa),
      _Unit(label: 'GPa', toBase: _GPa2Pa,  fromBase: _Pa2GPa),
      _Unit(label: 'psi', toBase: _psi2Pa,  fromBase: _Pa2psi),
      _Unit(label: 'ksi', toBase: _ksi2Pa,  fromBase: _Pa2ksi),
      _Unit(label: 'atm', toBase: _atm2Pa,  fromBase: _Pa2atm),
      _Unit(label: 'bar', toBase: _bar2Pa,  fromBase: _Pa2bar),
    ],
  ),
  _UnitCategory(
    name: 'Mass',
    icon: Icons.scale_rounded,
    units: [
      _Unit(label: 'g',    toBase: _g2kg,    fromBase: _kg2g),
      _Unit(label: 'kg',   toBase: _id,      fromBase: _id),
      _Unit(label: 'tonne',toBase: _t2kg,    fromBase: _kg2t),
      _Unit(label: 'oz',   toBase: _oz2kg,   fromBase: _kg2oz),
      _Unit(label: 'lb',   toBase: _lb2kg,   fromBase: _kg2lb),
      _Unit(label: 'slug', toBase: _slug2kg, fromBase: _kg2slug),
    ],
  ),
  _UnitCategory(
    name: 'Temperature',
    icon: Icons.thermostat_rounded,
    units: [
      _Unit(label: '°C', toBase: _id,   fromBase: _id),
      _Unit(label: '°F', toBase: _F2C,  fromBase: _C2F),
      _Unit(label: 'K',  toBase: _K2C,  fromBase: _C2K),
    ],
  ),
  _UnitCategory(
    name: 'Torque',
    icon: Icons.rotate_right_rounded,
    units: [
      _Unit(label: 'N·m',    toBase: _id,        fromBase: _id),
      _Unit(label: 'kN·m',   toBase: _kNm2Nm,   fromBase: _Nm2kNm),
      _Unit(label: 'lbf·ft', toBase: _lbfft2Nm, fromBase: _Nm2lbfft),
      _Unit(label: 'lbf·in', toBase: _lbfin2Nm, fromBase: _Nm2lbfin),
    ],
  ),
  _UnitCategory(
    name: 'Power',
    icon: Icons.bolt_rounded,
    units: [
      _Unit(label: 'W',  toBase: _id,    fromBase: _id),
      _Unit(label: 'kW', toBase: _kW2W,  fromBase: _W2kW),
      _Unit(label: 'MW', toBase: _MW2W,  fromBase: _W2MW),
      _Unit(label: 'hp', toBase: _hp2W,  fromBase: _W2hp),
    ],
  ),
  _UnitCategory(
    name: 'Angular Velocity',
    icon: Icons.settings_rounded,
    units: [
      _Unit(label: 'rad/s', toBase: _id,       fromBase: _id),
      _Unit(label: 'rpm',   toBase: _rpm2rads, fromBase: _rads2rpm),
      _Unit(label: 'deg/s', toBase: _degs2rads,fromBase: _rads2degs),
    ],
  ),
  _UnitCategory(
    name: 'Angle',
    icon: Icons.architecture_rounded,
    units: [
      _Unit(label: 'rad', toBase: _id,         fromBase: _id),
      _Unit(label: 'deg', toBase: _deg2rad,    fromBase: _rad2deg),
    ],
  ),
];

// Length
double _mm2m(double v) => v * 0.001;
double _m2mm(double v) => v * 1000;
double _cm2m(double v) => v * 0.01;
double _m2cm(double v) => v * 100;
double _km2m(double v) => v * 1000;
double _m2km(double v) => v * 0.001;
double _in2m(double v) => v * 0.0254;
double _m2in(double v) => v / 0.0254;
double _ft2m(double v) => v * 0.3048;
double _m2ft(double v) => v / 0.3048;
double _yd2m(double v) => v * 0.9144;
double _m2yd(double v) => v / 0.9144;
double _mi2m(double v) => v * 1609.344;
double _m2mi(double v) => v / 1609.344;
// Force
double _kN2N(double v) => v * 1e3;
double _N2kN(double v) => v * 1e-3;
double _MN2N(double v) => v * 1e6;
double _N2MN(double v) => v * 1e-6;
double _lbf2N(double v) => v * 4.44822;
double _N2lbf(double v) => v / 4.44822;
double _kip2N(double v) => v * 4448.22;
double _N2kip(double v) => v / 4448.22;
// Stress
double _kPa2Pa(double v) => v * 1e3;
double _Pa2kPa(double v) => v * 1e-3;
double _MPa2Pa(double v) => v * 1e6;
double _Pa2MPa(double v) => v * 1e-6;
double _GPa2Pa(double v) => v * 1e9;
double _Pa2GPa(double v) => v * 1e-9;
double _psi2Pa(double v) => v * 6894.76;
double _Pa2psi(double v) => v / 6894.76;
double _ksi2Pa(double v) => v * 6.89476e6;
double _Pa2ksi(double v) => v / 6.89476e6;
double _atm2Pa(double v) => v * 101325;
double _Pa2atm(double v) => v / 101325;
double _bar2Pa(double v) => v * 1e5;
double _Pa2bar(double v) => v * 1e-5;
// Mass
double _g2kg(double v) => v * 0.001;
double _kg2g(double v) => v * 1000;
double _t2kg(double v) => v * 1000;
double _kg2t(double v) => v * 0.001;
double _oz2kg(double v) => v * 0.0283495;
double _kg2oz(double v) => v / 0.0283495;
double _lb2kg(double v) => v * 0.453592;
double _kg2lb(double v) => v / 0.453592;
double _slug2kg(double v) => v * 14.5939;
double _kg2slug(double v) => v / 14.5939;
// Temperature (base = °C)
double _F2C(double v) => (v - 32) * 5 / 9;
double _C2F(double v) => v * 9 / 5 + 32;
double _K2C(double v) => v - 273.15;
double _C2K(double v) => v + 273.15;
// Torque
double _kNm2Nm(double v) => v * 1000;
double _Nm2kNm(double v) => v * 0.001;
double _lbfft2Nm(double v) => v * 1.35582;
double _Nm2lbfft(double v) => v / 1.35582;
double _lbfin2Nm(double v) => v * 0.112985;
double _Nm2lbfin(double v) => v / 0.112985;
// Power
double _kW2W(double v) => v * 1000;
double _W2kW(double v) => v * 0.001;
double _MW2W(double v) => v * 1e6;
double _W2MW(double v) => v * 1e-6;
double _hp2W(double v) => v * 745.7;
double _W2hp(double v) => v / 745.7;
// Angular velocity
double _rpm2rads(double v) => v * pi / 30;
double _rads2rpm(double v) => v * 30 / pi;
double _degs2rads(double v) => v * pi / 180;
double _rads2degs(double v) => v * 180 / pi;
// Angle
double _deg2rad(double v) => v * pi / 180;
double _rad2deg(double v) => v * 180 / pi;
// Identity
double _id(double v) => v;

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({Key? key}) : super(key: key);

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  int _catIndex = 0;
  int _fromIndex = 0;
  int _toIndex = 1;

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  bool _updating = false;

  _UnitCategory get _cat => _categories[_catIndex];

  void _selectCategory(int i) {
    setState(() {
      _catIndex = i;
      _fromIndex = 0;
      _toIndex = _cat.units.length > 1 ? 1 : 0;
      _fromCtrl.clear();
      _toCtrl.clear();
    });
  }

  void _convert({required bool fromChanged}) {
    if (_updating) return;
    _updating = true;
    final units = _cat.units;
    if (fromChanged) {
      final v = double.tryParse(_fromCtrl.text);
      if (v != null) {
        final base = units[_fromIndex].toBase(v);
        final result = units[_toIndex].fromBase(base);
        _toCtrl.text = _fmt(result);
      } else {
        _toCtrl.clear();
      }
    } else {
      final v = double.tryParse(_toCtrl.text);
      if (v != null) {
        final base = units[_toIndex].toBase(v);
        final result = units[_fromIndex].fromBase(base);
        _fromCtrl.text = _fmt(result);
      } else {
        _fromCtrl.clear();
      }
    }
    _updating = false;
  }

  String _fmt(double v) {
    if (v == 0) return '0';
    final abs = v.abs();
    if (abs >= 1e6 || (abs < 0.001 && abs > 0)) {
      return v.toStringAsExponential(6).replaceAll(RegExp(r'0+e'), 'e');
    }
    final s = v.toStringAsFixed(8);
    return s.contains('.') ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : s;
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final units = _cat.units;

    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter')),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _catIndex;
                return ChoiceChip(
                  label: Text(_categories[i].name),
                  avatar: Icon(_categories[i].icon, size: 16),
                  selected: selected,
                  selectedColor: primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontSize: 13,
                  ),
                  onSelected: (_) => _selectCategory(i),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _UnitField(
                    label: 'From',
                    controller: _fromCtrl,
                    unitLabels: units.map((u) => u.label).toList(),
                    selectedUnit: _fromIndex,
                    onUnitChanged: (i) {
                      setState(() => _fromIndex = i);
                      _convert(fromChanged: true);
                    },
                    onChanged: (_) => _convert(fromChanged: true),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.swap_vert_rounded, color: primary, size: 32),
                      tooltip: 'Swap',
                      onPressed: () {
                        setState(() {
                          final tmp = _fromIndex;
                          _fromIndex = _toIndex;
                          _toIndex = tmp;
                          final tmpText = _fromCtrl.text;
                          _fromCtrl.text = _toCtrl.text;
                          _toCtrl.text = tmpText;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _UnitField(
                    label: 'To',
                    controller: _toCtrl,
                    unitLabels: units.map((u) => u.label).toList(),
                    selectedUnit: _toIndex,
                    onUnitChanged: (i) {
                      setState(() => _toIndex = i);
                      _convert(fromChanged: false);
                    },
                    onChanged: (_) => _convert(fromChanged: false),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy result'),
                    onPressed: _toCtrl.text.isNotEmpty
                        ? () {
                            Clipboard.setData(ClipboardData(
                                text: '${_toCtrl.text} ${units[_toIndex].label}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Result copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> unitLabels;
  final int selectedUnit;
  final ValueChanged<int> onUnitChanged;
  final ValueChanged<String> onChanged;

  const _UnitField({
    required this.label,
    required this.controller,
    required this.unitLabels,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(hintText: '0'),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: selectedUnit,
              underline: const SizedBox.shrink(),
              items: unitLabels
                  .asMap()
                  .entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onUnitChanged(v);
              },
            ),
          ],
        ),
      ],
    );
  }
}
