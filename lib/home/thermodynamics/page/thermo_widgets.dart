import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// One column of a [StateTableCard]: a symbol, and the unit its values are
/// in. A null [category] is dimensionless.
class StateColumn {
  const StateColumn(this.symbol, this.category);

  final String symbol;
  final UnitCategory? category;
}

/// One row: a state's name and one value per column, in the app's SI display
/// units. A null value prints as a dash — a quality outside the dome, say.
class StateRow {
  const StateRow(this.label, this.values);

  final String label;
  final List<double?> values;
}

/// The states of a cycle as a table, the way a textbook tabulates them.
///
/// Twelve or twenty numbers in a card of label–value rows would be a long
/// scroll with the structure lost; a grid keeps "the enthalpy at state 3"
/// one glance away. The same numbers are exported through
/// [stateTableSections], because a table widget cannot reach the CSV or PDF.
class StateTableCard extends StatelessWidget {
  const StateTableCard({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
  });

  final String title;
  final List<StateColumn> columns;
  final List<StateRow> rows;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final theme = Theme.of(context);
    final headStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final cellStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    String format(double? value, UnitCategory? category) {
      if (value == null) return '—';
      final display = category == null ? value : fromSI(value, category, system);
      // A table mixes liquid and vapour volumes three decades apart; the
      // small-value form keeps 0.00104 from printing as 0.001.
      return precs.formatSmallValue(display);
    }

    return AppSectionCard(
      title: title,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.tokens.space2,
        vertical: context.tokens.space2,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 44,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 44,
          horizontalMargin: context.tokens.space2,
          columnSpacing: context.tokens.space4,
          columns: [
            DataColumn(label: Text('', style: headStyle)),
            for (final column in columns)
              DataColumn(
                numeric: true,
                label: Text(
                  column.category == null
                      ? column.symbol
                      : '${column.symbol} (${unitLabel(column.category!, system)})',
                  style: headStyle,
                ),
              ),
          ],
          rows: [
            for (final row in rows)
              DataRow(cells: [
                DataCell(Text(row.label, style: cellStyle)),
                for (var i = 0; i < columns.length; i++)
                  DataCell(Text(
                    format(row.values[i], columns[i].category),
                    style: cellStyle,
                  )),
              ]),
          ],
        ),
      ),
    );
  }
}

/// The same table as export-only result sections, one per state, so the
/// share text, CSV, PDF and saved projects carry every number the grid
/// shows.
List<ResultSection> stateTableSections(
  List<StateColumn> columns,
  List<StateRow> rows,
) =>
    [
      for (final row in rows)
        ResultSection(
          title: row.label,
          exportOnly: true,
          values: [
            for (var i = 0; i < columns.length; i++)
              if (row.values[i] != null)
                ResultValue(
                  label: columns[i].symbol,
                  valueSI: row.values[i],
                  category: columns[i].category,
                  smallMagnitude: true,
                ),
          ],
        ),
    ];

/// An axis title: the symbol with its unit in the reader's system.
String axisLabel(String symbol, UnitCategory category, UnitSystem system) =>
    '$symbol (${unitLabel(category, system)})';

/// A (x, y) point converted out of SI for plotting in [system].
Offset plotPoint(
  double x,
  UnitCategory xCategory,
  double y,
  UnitCategory yCategory,
  UnitSystem system,
) =>
    Offset(fromSI(x, xCategory, system), fromSI(y, yCategory, system));

/// A small caution card for a result the reader should not take at face
/// value — a wet turbine exhaust, a cycle below its compression temperature.
class ResultWarningCard extends StatelessWidget {
  const ResultWarningCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: EdgeInsets.all(context.tokens.space3),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
            SizedBox(width: context.tokens.space2),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The body-small, muted footnote the result pages end with.
class ResultFootnote extends StatelessWidget {
  const ResultFootnote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
