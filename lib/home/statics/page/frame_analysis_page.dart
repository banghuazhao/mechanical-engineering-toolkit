import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/statics/model/frame_solver.dart';
import 'package:mechanical_engineering_toolkit/home/statics/page/frame_analysis_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// The history key for member [index]'s joint list, stored as zero-based
/// joint indices in order along the member: `0,2,1`.
String frameMemberKey(int index) => 'Member${index + 1}';

/// Matches [frameMemberKey], so a history row can show `J1 → J3 → J2`
/// rather than the stored indices.
final frameMemberKeyPattern = RegExp(r'^Member\d+$');

class _JointEntry {
  double? x;
  double? y;
  FrameSupport support = FrameSupport.none;
  double? fx;
  double? fy;
  double? couple;
}

class _MemberEntry {
  /// Joints in the order they were picked — the order along the member.
  final List<_JointEntry> joints = [];
}

String frameSupportLabel(BuildContext context, FrameSupport support) {
  final l10n = S.of(context);
  return switch (support) {
    FrameSupport.none => l10n.None,
    FrameSupport.pin => l10n.Pin,
    FrameSupport.rollerX => l10n.Roller_Horizontal,
    FrameSupport.rollerY => l10n.Roller_Vertical,
    FrameSupport.fixed => l10n.Support_Fixed,
  };
}

class FrameAnalysisPage extends StatefulWidget {
  const FrameAnalysisPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<FrameAnalysisPage> createState() => _FrameAnalysisPageState();
}

class _FrameAnalysisPageState extends State<FrameAnalysisPage> {
  final List<_JointEntry> _joints = [
    _JointEntry(),
    _JointEntry(),
    _JointEntry()
  ];
  final List<_MemberEntry> _members = [_MemberEntry()];

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    final restoredJoints = <_JointEntry>[];
    for (var i = 0; inputs.containsKey('J$i x'); i++) {
      restoredJoints.add(_JointEntry()
        ..x = double.tryParse(inputs['J$i x'] ?? '')
        ..y = double.tryParse(inputs['J$i y'] ?? '')
        ..support = FrameSupport.values.firstWhere(
            (s) => s.name == inputs['J$i support'],
            orElse: () => FrameSupport.none)
        ..fx = double.tryParse(inputs['J$i Fx'] ?? '')
        ..fy = double.tryParse(inputs['J$i Fy'] ?? '')
        ..couple = double.tryParse(inputs['J$i M'] ?? ''));
    }
    if (restoredJoints.isEmpty) return;
    _joints
      ..clear()
      ..addAll(restoredJoints);
    _members.clear();
    for (var i = 0; inputs.containsKey(frameMemberKey(i)); i++) {
      final member = _MemberEntry();
      for (final part in inputs[frameMemberKey(i)]!.split(',')) {
        final index = int.tryParse(part.trim());
        if (index != null && index >= 0 && index < _joints.length) {
          member.joints.add(_joints[index]);
        }
      }
      _members.add(member);
    }
    if (_members.isEmpty) _members.add(_MemberEntry());
  }

  void _removeJoint(int index) {
    final removed = _joints[index];
    for (final member in _members) {
      member.joints.remove(removed);
    }
    setState(() => _joints.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
      ),
      floatingActionButton: CalculateButton(onPressed: _calculate),
      body: AppContent(
        padding: EdgeInsets.zero,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            context.tokens.space4,
            context.tokens.space4,
            context.tokens.space4,
            100,
          ),
          children: [
            ToolResultHeader(tool: tool),
            AppSectionCard(
              title: l10n.Joints,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.Desc_Frame_Joints, style: muted),
                  SizedBox(height: context.tokens.space3),
                  for (var i = 0; i < _joints.length; i++) _buildJoint(i),
                  TextButton.icon(
                    key: const Key('addFrameJoint'),
                    onPressed: () => setState(() => _joints.add(_JointEntry())),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(l10n.Add_Joint),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: l10n.Members,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.Desc_Frame_Members, style: muted),
                  SizedBox(height: context.tokens.space3),
                  for (var i = 0; i < _members.length; i++) _buildMember(i),
                  TextButton.icon(
                    key: const Key('addFrameMember'),
                    onPressed: () =>
                        setState(() => _members.add(_MemberEntry())),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(l10n.Add_Member),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoint(int index) {
    final l10n = S.of(context);
    final joint = _joints[index];
    return Card(
      key: ObjectKey(joint),
      margin: EdgeInsets.only(bottom: context.tokens.space3),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(context.tokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('J${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  tooltip: l10n.Delete,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  onPressed:
                      _joints.length > 2 ? () => _removeJoint(index) : null,
                ),
              ],
            ),
            AdaptiveFieldGrid(children: [
              UnitField(
                label: 'x',
                category: UnitCategory.span,
                initialSI: joint.x,
                onChangedSI: (v) => joint.x = v,
              ),
              UnitField(
                label: 'y',
                category: UnitCategory.span,
                initialSI: joint.y,
                onChangedSI: (v) => joint.y = v,
              ),
              DropdownButtonFormField<FrameSupport>(
                initialValue: joint.support,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.Support),
                items: [
                  for (final support in FrameSupport.values)
                    DropdownMenuItem(
                      value: support,
                      child: Text(frameSupportLabel(context, support)),
                    ),
                ],
                onChanged: (v) => setState(() => joint.support = v!),
              ),
              UnitField(
                label: l10n.Load_Fx,
                category: UnitCategory.force,
                initialSI: joint.fx,
                onChangedSI: (v) => joint.fx = v,
              ),
              UnitField(
                label: l10n.Load_Fy,
                category: UnitCategory.force,
                initialSI: joint.fy,
                onChangedSI: (v) => joint.fy = v,
              ),
              UnitField(
                label: l10n.Applied_Couple_M,
                category: UnitCategory.torque,
                initialSI: joint.couple,
                onChangedSI: (v) => joint.couple = v,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMember(int index) {
    final l10n = S.of(context);
    final member = _members[index];
    final order = [
      for (final joint in member.joints) 'J${_joints.indexOf(joint) + 1}',
    ].join(' → ');
    return Card(
      key: ObjectKey(member),
      margin: EdgeInsets.only(bottom: context.tokens.space3),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(context.tokens.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.Member_N(index + 1),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  tooltip: l10n.Delete,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  onPressed: _members.length > 1
                      ? () => setState(() => _members.removeAt(index))
                      : null,
                ),
              ],
            ),
            Wrap(
              spacing: context.tokens.space2,
              runSpacing: context.tokens.space1,
              children: [
                for (var j = 0; j < _joints.length; j++)
                  FilterChip(
                    key: ValueKey('member$index-joint$j'),
                    label: Text('J${j + 1}'),
                    selected: member.joints.contains(_joints[j]),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        member.joints.add(_joints[j]);
                      } else {
                        member.joints.remove(_joints[j]);
                      }
                    }),
                  ),
              ],
            ),
            if (member.joints.length >= 2) ...[
              SizedBox(height: context.tokens.space2),
              Text(
                l10n.Frame_Member_Path(order),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _calculate() {
    final l10n = S.of(context);
    void fail(String message) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

    for (var i = 0; i < _joints.length; i++) {
      if (_joints[i].x == null || _joints[i].y == null) {
        return fail(l10n.Err_Joint_Coordinates(i + 1));
      }
    }
    for (var i = 0; i < _members.length; i++) {
      if (_members[i].joints.length < 2) {
        return fail(l10n.Err_Member_Needs_Two_Joints(i + 1));
      }
    }

    final joints = [
      for (final j in _joints)
        FrameJoint(
          x: j.x!,
          y: j.y!,
          support: j.support,
          fx: j.fx ?? 0,
          fy: j.fy ?? 0,
          couple: j.couple ?? 0,
        ),
    ];
    final members = [
      for (final m in _members)
        FrameMember([for (final j in m.joints) _joints.indexOf(j)]),
    ];

    try {
      final solution = FrameSolver.solve(joints, members);

      final inputs = <String, String>{};
      for (var i = 0; i < _joints.length; i++) {
        final j = _joints[i];
        inputs['J$i x'] = '${j.x}';
        inputs['J$i y'] = '${j.y}';
        inputs['J$i support'] = j.support.name;
        inputs['J$i Fx'] = '${j.fx ?? ''}';
        inputs['J$i Fy'] = '${j.fy ?? ''}';
        inputs['J$i M'] = '${j.couple ?? ''}';
      }
      for (var i = 0; i < members.length; i++) {
        inputs[frameMemberKey(i)] = members[i].joints.join(',');
      }
      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

      showToolResult(
        context,
        (context) => FrameAnalysisResultPage(
          toolId: widget.toolId,
          title: widget.title,
          joints: joints,
          members: members,
          solution: solution,
        ),
      );
    } on FormatException catch (error) {
      fail(error.message);
    }
  }
}
