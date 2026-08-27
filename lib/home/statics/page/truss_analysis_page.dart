import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/statics/model/truss_solver.dart';
import 'package:mechanical_engineering_toolkit/home/statics/page/truss_analysis_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class _JointEntry {
  double? x;
  double? y;
  TrussSupport support = TrussSupport.none;
  double? loadFx;
  double? loadFy;
}

class _MemberEntry {
  _JointEntry? jointA;
  _JointEntry? jointB;
}

class TrussAnalysisPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const TrussAnalysisPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  State<TrussAnalysisPage> createState() => _TrussAnalysisPageState();
}

class _TrussAnalysisPageState extends State<TrussAnalysisPage> {
  final List<_JointEntry> _joints = [
    _JointEntry(),
    _JointEntry(),
    _JointEntry()
  ];
  final List<_MemberEntry> _members = [];

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;

    var i = 0;
    _joints.clear();
    while (inputs.containsKey('J$i x')) {
      final joint = _JointEntry()
        ..x = double.tryParse(inputs['J$i x'] ?? '')
        ..y = double.tryParse(inputs['J$i y'] ?? '')
        ..support = TrussSupport.values.firstWhere(
            (s) => s.name == inputs['J$i support'],
            orElse: () => TrussSupport.none)
        ..loadFx = double.tryParse(inputs['J$i Fx'] ?? '')
        ..loadFy = double.tryParse(inputs['J$i Fy'] ?? '');
      _joints.add(joint);
      i++;
    }
    if (_joints.isEmpty) {
      _joints.addAll([_JointEntry(), _JointEntry(), _JointEntry()]);
    }

    var mi = 0;
    while (inputs.containsKey('M$mi a')) {
      final a = int.tryParse(inputs['M$mi a'] ?? '');
      final b = int.tryParse(inputs['M$mi b'] ?? '');
      final member = _MemberEntry()
        ..jointA = (a != null && a < _joints.length) ? _joints[a] : null
        ..jointB = (b != null && b < _joints.length) ? _joints[b] : null;
      _members.add(member);
      mi++;
    }
  }

  void _removeJoint(int index) {
    final removed = _joints[index];
    for (final member in _members) {
      if (member.jointA == removed) member.jointA = null;
      if (member.jointB == removed) member.jointB = null;
    }
    setState(() => _joints.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).Joints,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).Desc_Truss_Determinacy,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_joints.length, _buildJointCard),
                  TextButton.icon(
                    onPressed: () => setState(() => _joints.add(_JointEntry())),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(S.of(context).Add_Joint),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).Members,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...List.generate(_members.length, _buildMemberCard),
                  TextButton.icon(
                    onPressed: _joints.length >= 2
                        ? () => setState(() => _members.add(_MemberEntry()))
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(S.of(context).Add_Member),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                Text(S.of(context).Calculate, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _jointLabel(int index) {
    final j = _joints[index];
    final x = j.x?.toStringAsFixed(1) ?? '?';
    final y = j.y?.toStringAsFixed(1) ?? '?';
    return 'J${index + 1} ($x, $y)';
  }

  Widget _buildJointCard(int index) {
    final joint = _joints[index];
    return Card(
      key: ObjectKey(joint),
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('J${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded,
                      color: Colors.red),
                  onPressed:
                      _joints.length > 2 ? () => _removeJoint(index) : null,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: UnitField(
                    label: 'x',
                    category: UnitCategory.span,
                    initialSI: joint.x,
                    onChangedSI: (v) => joint.x = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: UnitField(
                    label: 'y',
                    category: UnitCategory.span,
                    initialSI: joint.y,
                    onChangedSI: (v) => joint.y = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TrussSupport>(
              initialValue: joint.support,
              decoration: InputDecoration(labelText: S.of(context).Support),
              items: [
                DropdownMenuItem(
                    value: TrussSupport.none, child: Text(S.of(context).None)),
                DropdownMenuItem(
                    value: TrussSupport.pin, child: Text(S.of(context).Pin)),
                DropdownMenuItem(
                    value: TrussSupport.rollerX,
                    child: Text(S.of(context).Roller_Horizontal)),
                DropdownMenuItem(
                    value: TrussSupport.rollerY,
                    child: Text(S.of(context).Roller_Vertical)),
              ],
              onChanged: (v) => setState(() => joint.support = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: UnitField(
                    label: S.of(context).Load_Fx,
                    category: UnitCategory.force,
                    initialSI: joint.loadFx,
                    onChangedSI: (v) => joint.loadFx = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: UnitField(
                    label: S.of(context).Load_Fy,
                    category: UnitCategory.force,
                    initialSI: joint.loadFy,
                    onChangedSI: (v) => joint.loadFy = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(int index) {
    final member = _members[index];
    return Padding(
      key: ObjectKey(member),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<_JointEntry>(
              initialValue:
                  _joints.contains(member.jointA) ? member.jointA : null,
              decoration: InputDecoration(labelText: S.of(context).From),
              items: List.generate(
                _joints.length,
                (i) => DropdownMenuItem(
                    value: _joints[i], child: Text(_jointLabel(i))),
              ),
              onChanged: (v) => setState(() => member.jointA = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<_JointEntry>(
              initialValue:
                  _joints.contains(member.jointB) ? member.jointB : null,
              decoration: const InputDecoration(labelText: 'To'),
              items: List.generate(
                _joints.length,
                (i) => DropdownMenuItem(
                    value: _joints[i], child: Text(_jointLabel(i))),
              ),
              onChanged: (v) => setState(() => member.jointB = v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded,
                color: Colors.red),
            onPressed: () => setState(() => _members.removeAt(index)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  void _calculate() {
    for (var i = 0; i < _joints.length; i++) {
      final j = _joints[i];
      if (j.x == null || j.y == null) {
        _showError('Enter x and y for J${i + 1}.');
        return;
      }
    }
    if (_members.isEmpty) {
      _showError('Add at least one member.');
      return;
    }
    for (var i = 0; i < _members.length; i++) {
      final m = _members[i];
      if (m.jointA == null || m.jointB == null) {
        _showError('Member ${i + 1} needs both endpoints set.');
        return;
      }
    }

    final joints = _joints
        .map((j) => TrussJoint(
              x: j.x!,
              y: j.y!,
              support: j.support,
              loadFx: j.loadFx,
              loadFy: j.loadFy,
            ))
        .toList();
    final members = _members
        .map((m) => TrussMember(
              jointA: _joints.indexOf(m.jointA!),
              jointB: _joints.indexOf(m.jointB!),
            ))
        .toList();

    try {
      final solution = TrussSolver.solve(joints, members);

      final inputs = <String, String>{};
      for (var i = 0; i < _joints.length; i++) {
        final j = _joints[i];
        inputs['J$i x'] = '${j.x}';
        inputs['J$i y'] = '${j.y}';
        inputs['J$i support'] = j.support.name;
        inputs['J$i Fx'] = '${j.loadFx ?? ''}';
        inputs['J$i Fy'] = '${j.loadFy ?? ''}';
      }
      for (var i = 0; i < _members.length; i++) {
        inputs['M$i a'] = '${_joints.indexOf(_members[i].jointA!)}';
        inputs['M$i b'] = '${_joints.indexOf(_members[i].jointB!)}';
      }
      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrussAnalysisResultPage(
            toolId: widget.toolId,
            title: widget.title,
            joints: joints,
            members: members,
            solution: solution,
          ),
        ),
      );
    } on FormatException catch (error) {
      _showError(error.message);
    }
  }
}
