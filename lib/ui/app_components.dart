import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Fades and slides [child] into place once, with a delay proportional to
/// [index]. Intended for list/grid items so a screen's contents cascade in
/// on first appearance instead of popping in all at once.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance(
      {super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 20 * widget.index.clamp(0, 15));
    _timer = Timer(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class ToolResultHeader extends StatelessWidget {
  const ToolResultHeader({super.key, required this.tool});

  final Tool tool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    if (tool.image == null && tool.icon == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space4),
      child: Center(
        child: Hero(
          tag: 'tool_icon_${tool.id}',
          child: tool.image != null
              ? SizedBox(
                  width: 64,
                  height: 64,
                  child: Image(image: tool.image!, fit: BoxFit.contain),
                )
              : CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  radius: 32,
                  child: Icon(
                    tool.icon,
                    size: 32,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
        ),
      ),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
          child: Padding(
            padding: padding ?? EdgeInsets.all(tokens.space4),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.contentPadding,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space4,
              tokens.space4,
              tokens.space2,
              tokens.space3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: contentPadding ?? EdgeInsets.all(tokens.space4),
            child: child,
          ),
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    return AppContent(
      alignment: Alignment.center,
      child: Semantics(
        container: true,
        label: '$title. $message',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: tokens.space3,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              SizedBox(height: tokens.space1),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class AppCopyableValue extends StatelessWidget {
  const AppCopyableValue({
    super.key,
    required this.label,
    this.value,
    this.valueSI,
    this.category,
  }) : assert(value != null || valueSI != null,
            'Provide either value or valueSI');

  final String label;

  /// A pre-formatted display string. Ignored when [valueSI] is provided.
  final String? value;

  /// A raw value expressed in the app's SI display unit for [category].
  /// When provided, this widget formats it via [NumberPrecisionHelper] and
  /// converts/labels it using the current [UnitSystemPreference].
  final double? valueSI;

  /// Unit category for [valueSI]. Pass null for a dimensionless value.
  final UnitCategory? category;

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    await HapticFeedback.lightImpact();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text(S.of(context).Copied_Value(label))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = _resolveValue(context);
    return InkWell(
      onTap: displayValue.isEmpty ? null : () => _copy(context, displayValue),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.tokens.space2),
        child: Row(
          spacing: context.tokens.space3,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  displayValue.isEmpty ? '—' : displayValue,
                  key: ValueKey(displayValue),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            if (displayValue.isNotEmpty)
              Icon(
                Icons.content_copy_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  String _resolveValue(BuildContext context) {
    final si = valueSI;
    if (si == null) return value ?? '';
    final precs = context.watch<NumberPrecisionHelper>();
    final system = context.watch<UnitSystemPreference>().system;
    final displayNumber = category == null ? si : fromSI(si, category!, system);
    final formatted = precs.formatValue(displayNumber);
    final unit = category == null ? '' : unitLabel(category!, system);
    return unit.isEmpty ? formatted : '$formatted $unit';
  }
}

class AdaptiveFieldGrid extends StatelessWidget {
  const AdaptiveFieldGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gap = context.tokens.space3;
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columns = constraints.maxWidth >= 360 && textScale <= 1.3 ? 2 : 1;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
