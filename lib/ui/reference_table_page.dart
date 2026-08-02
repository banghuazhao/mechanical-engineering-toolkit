import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';

/// Horizontal breathing room on each side of a header or data row.
const double _rowPadding = 12;

/// One column of a [ReferenceTablePage].
class ReferenceColumn<T> {
  const ReferenceColumn({
    required this.label,
    required this.value,
    this.secondary,
    this.width = 92,
    this.mono = true,
  });

  final String label;

  /// Cell text for [row]. Return an em dash for values a row does not carry.
  final String Function(T row) value;

  /// Optional second line under [value], set smaller and dimmer — a converted
  /// unit or an equivalent designation. Return null to leave the cell single
  /// line; rows in the same column may differ.
  final String? Function(T row)? secondary;

  /// Natural width in logical pixels. Columns keep their relative widths and
  /// are scaled up together when the table is narrower than the screen.
  final double width;

  /// Numeric columns read better in a monospaced face; text columns don't.
  final bool mono;
}

/// A named subset of the rows, offered as a chip above the table.
class ReferenceFilter<T> {
  const ReferenceFilter({required this.label, required this.test});

  final String label;
  final bool Function(T row) test;
}

/// Scrollable, searchable lookup table for reference data that is looked up
/// rather than calculated — drill sizes, tolerance grades, hardness scales.
///
/// Rows are laid out by hand instead of with [DataTable] so the header can stay
/// pinned while the body scrolls lazily; charts run to hundreds of rows.
class ReferenceTablePage<T> extends StatefulWidget {
  const ReferenceTablePage({
    super.key,
    required this.title,
    required this.rows,
    required this.columns,
    required this.searchText,
    this.matcher,
    this.filters = const [],
    this.searchHint,
    this.footnote,
  });

  final String title;
  final List<T> rows;
  final List<ReferenceColumn<T>> columns;

  /// Haystack the search field matches against, e.g. `'M8 1.25 coarse'`.
  final String Function(T row) searchText;

  /// Replaces the default substring match on [searchText] — for tables where a
  /// query means something other than text, such as a diameter that has to
  /// fall inside a row's size range. [query] is trimmed and lowercased.
  final bool Function(T row, String query)? matcher;

  final List<ReferenceFilter<T>> filters;
  final String? searchHint;

  /// Sourcing or usage caveat pinned under the table.
  final String? footnote;

  @override
  State<ReferenceTablePage<T>> createState() => _ReferenceTablePageState<T>();
}

class _ReferenceTablePageState<T> extends State<ReferenceTablePage<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// Index into `widget.filters`, or -1 for "all".
  int _filterIndex = -1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(T row) {
    if (_query.isEmpty) return true;
    final matcher = widget.matcher;
    if (matcher != null) return matcher(row, _query);
    return widget.searchText(row).toLowerCase().contains(_query);
  }

  List<T> get _visibleRows {
    final filter = _filterIndex < 0 ? null : widget.filters[_filterIndex];
    return [
      for (final row in widget.rows)
        if ((filter == null || filter.test(row)) && _matches(row)) row,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      bottomNavigationBar: const AppBannerAd(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: context.tokens.contentMaxWidth),
            child: Column(
              children: [
                _buildSearchField(context),
                if (widget.filters.isNotEmpty) _buildFilterChips(context),
                const Divider(height: 1),
                Expanded(
                  child: rows.isEmpty
                      ? AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: S.of(context).No_Matches,
                          message: S.of(context).No_Matches_Description,
                        )
                      : _buildTable(context, rows),
                ),
                if (widget.footnote != null) _buildFootnote(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        key: const Key('referenceSearchField'),
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) =>
            setState(() => _query = value.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: widget.searchHint ?? S.of(context).Search,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  key: const Key('clearReferenceSearch'),
                  tooltip: S.of(context).Clear_Search,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: widget.filters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label =
              index == 0 ? S.of(context).All : widget.filters[index - 1].label;
          final selected = _filterIndex == index - 1;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _filterIndex = index - 1),
          );
        },
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<T> rows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final natural =
            widget.columns.fold<double>(0, (sum, column) => sum + column.width);
        // Fill the screen when there is room to spare, scroll when there isn't.
        final available = constraints.maxWidth - 2 * _rowPadding;
        final scale = available > natural ? available / natural : 1.0;
        final widths = [
          for (final column in widget.columns) column.width * scale,
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: natural * scale + 2 * _rowPadding,
            child: Column(
              children: [
                _buildHeader(context, widths),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    key: const Key('referenceTable'),
                    itemCount: rows.length,
                    itemBuilder: (context, index) =>
                        _buildRow(context, rows[index], index, widths),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, List<double> widths) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      padding:
          const EdgeInsets.symmetric(horizontal: _rowPadding, vertical: 10),
      child: Row(
        children: [
          for (var i = 0; i < widget.columns.length; i++)
            SizedBox(
              width: widths[i],
              child: Text(
                widget.columns[i].label,
                maxLines: 2,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(
      BuildContext context, T row, int index, List<double> widths) {
    final theme = Theme.of(context);
    final cells = [
      for (final column in widget.columns)
        (
          value: column.value(row),
          secondary: column.secondary?.call(row),
        ),
    ];
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        final text = [
          for (final cell in cells)
            cell.secondary == null
                ? cell.value
                : '${cell.value} (${cell.secondary})',
        ].join('  ');
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).Result_Copied),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        color: index.isOdd ? theme.colorScheme.surfaceContainerLow : null,
        padding:
            const EdgeInsets.symmetric(horizontal: _rowPadding, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < widget.columns.length; i++)
              SizedBox(
                width: widths[i],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cells[i].value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: widget.columns[i].mono ? 'monospace' : null,
                        fontWeight: i == 0 ? FontWeight.w600 : null,
                      ),
                    ),
                    if (cells[i].secondary != null)
                      Text(
                        cells[i].secondary!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily:
                              widget.columns[i].mono ? 'monospace' : null,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFootnote(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Text(
        widget.footnote!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
