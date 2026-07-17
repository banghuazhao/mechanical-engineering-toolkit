import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart' as units;

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
      _Unit(label: 'mm', toBase: units.mm2m, fromBase: units.m2mm),
      _Unit(label: 'cm', toBase: units.cm2m, fromBase: units.m2cm),
      _Unit(label: 'm',  toBase: units.id,   fromBase: units.id),
      _Unit(label: 'km', toBase: units.km2m, fromBase: units.m2km),
      _Unit(label: 'in', toBase: units.in2m, fromBase: units.m2in),
      _Unit(label: 'ft', toBase: units.ft2m, fromBase: units.m2ft),
      _Unit(label: 'yd', toBase: units.yd2m, fromBase: units.m2yd),
      _Unit(label: 'mi', toBase: units.mi2m, fromBase: units.m2mi),
    ],
  ),
  _UnitCategory(
    name: 'Force',
    icon: Icons.arrow_downward_rounded,
    units: [
      _Unit(label: 'N',   toBase: units.id,     fromBase: units.id),
      _Unit(label: 'kN',  toBase: units.kN2N,   fromBase: units.N2kN),
      _Unit(label: 'MN',  toBase: units.MN2N,   fromBase: units.N2MN),
      _Unit(label: 'lbf', toBase: units.lbf2N,  fromBase: units.N2lbf),
      _Unit(label: 'kip', toBase: units.kip2N,  fromBase: units.N2kip),
    ],
  ),
  _UnitCategory(
    name: 'Stress / Pressure',
    icon: Icons.compress_rounded,
    units: [
      _Unit(label: 'Pa',  toBase: units.id,      fromBase: units.id),
      _Unit(label: 'kPa', toBase: units.kPa2Pa,  fromBase: units.Pa2kPa),
      _Unit(label: 'MPa', toBase: units.MPa2Pa,  fromBase: units.Pa2MPa),
      _Unit(label: 'GPa', toBase: units.GPa2Pa,  fromBase: units.Pa2GPa),
      _Unit(label: 'psi', toBase: units.psi2Pa,  fromBase: units.Pa2psi),
      _Unit(label: 'ksi', toBase: units.ksi2Pa,  fromBase: units.Pa2ksi),
      _Unit(label: 'atm', toBase: units.atm2Pa,  fromBase: units.Pa2atm),
      _Unit(label: 'bar', toBase: units.bar2Pa,  fromBase: units.Pa2bar),
    ],
  ),
  _UnitCategory(
    name: 'Mass',
    icon: Icons.scale_rounded,
    units: [
      _Unit(label: 'g',    toBase: units.g2kg,    fromBase: units.kg2g),
      _Unit(label: 'kg',   toBase: units.id,      fromBase: units.id),
      _Unit(label: 'tonne',toBase: units.t2kg,    fromBase: units.kg2t),
      _Unit(label: 'oz',   toBase: units.oz2kg,   fromBase: units.kg2oz),
      _Unit(label: 'lb',   toBase: units.lb2kg,   fromBase: units.kg2lb),
      _Unit(label: 'slug', toBase: units.slug2kg, fromBase: units.kg2slug),
    ],
  ),
  _UnitCategory(
    name: 'Temperature',
    icon: Icons.thermostat_rounded,
    units: [
      _Unit(label: '°C', toBase: units.id,   fromBase: units.id),
      _Unit(label: '°F', toBase: units.F2C,  fromBase: units.C2F),
      _Unit(label: 'K',  toBase: units.K2C,  fromBase: units.C2K),
    ],
  ),
  _UnitCategory(
    name: 'Torque',
    icon: Icons.rotate_right_rounded,
    units: [
      _Unit(label: 'N·m',    toBase: units.id,        fromBase: units.id),
      _Unit(label: 'kN·m',   toBase: units.kNm2Nm,   fromBase: units.Nm2kNm),
      _Unit(label: 'lbf·ft', toBase: units.lbfft2Nm, fromBase: units.Nm2lbfft),
      _Unit(label: 'lbf·in', toBase: units.lbfin2Nm, fromBase: units.Nm2lbfin),
    ],
  ),
  _UnitCategory(
    name: 'Power',
    icon: Icons.bolt_rounded,
    units: [
      _Unit(label: 'W',  toBase: units.id,    fromBase: units.id),
      _Unit(label: 'kW', toBase: units.kW2W,  fromBase: units.W2kW),
      _Unit(label: 'MW', toBase: units.MW2W,  fromBase: units.W2MW),
      _Unit(label: 'hp', toBase: units.hp2W,  fromBase: units.W2hp),
    ],
  ),
  _UnitCategory(
    name: 'Angular Velocity',
    icon: Icons.settings_rounded,
    units: [
      _Unit(label: 'rad/s', toBase: units.id,       fromBase: units.id),
      _Unit(label: 'rpm',   toBase: units.rpm2rads, fromBase: units.rads2rpm),
      _Unit(label: 'deg/s', toBase: units.degs2rads,fromBase: units.rads2degs),
    ],
  ),
  _UnitCategory(
    name: 'Angle',
    icon: Icons.architecture_rounded,
    units: [
      _Unit(label: 'rad', toBase: units.id,         fromBase: units.id),
      _Unit(label: 'deg', toBase: units.deg2rad,    fromBase: units.rad2deg),
    ],
  ),
];

class UnitConverterPage extends StatefulWidget {
  final String? title;
  final int? toolId;
  final Map<String, String>? initialInputs;
  const UnitConverterPage({Key? key, this.title, this.toolId, this.initialInputs}) : super(key: key);

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
    // Rebuild so Copy result enables/disables with the current result text.
    setState(() {});
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
