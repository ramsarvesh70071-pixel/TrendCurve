import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pdf_analyzer_provider.dart';

class DataTablePreviewWidget extends ConsumerStatefulWidget {
  const DataTablePreviewWidget({super.key});

  @override
  ConsumerState<DataTablePreviewWidget> createState() => _DataTablePreviewWidgetState();
}

class _DataTablePreviewWidgetState extends ConsumerState<DataTablePreviewWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _filterText = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _currentPage = 0;
  static const int _pageSize = 15;
  bool _showSelectedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfAnalyzerProvider);
    final theme = Theme.of(context);
    final table = state.currentTable;

    if (table == null) {
      return const Center(child: Text('No data table extracted.'));
    }

    final displayedColumns = _showSelectedOnly
        ? table.headers.where((h) => state.selectedColumns.contains(h) || h == state.xAxisColumn).toList()
        : table.headers;

    // Filter rows based on search text
    var filteredRows = table.rows.where((row) {
      if (_filterText.isEmpty) return true;
      return row.any((val) => val.toLowerCase().contains(_filterText.toLowerCase()));
    }).toList();

    // Sort rows if column selected
    if (displayedColumns.isNotEmpty && _sortColumnIndex < displayedColumns.length) {
      final sortHeader = displayedColumns[_sortColumnIndex];
      filteredRows.sort((a, b) {
        final valA = table.getCellValue(a, sortHeader);
        final valB = table.getCellValue(b, sortHeader);

        final numA = double.tryParse(valA);
        final numB = double.tryParse(valB);

        int cmp;
        if (numA != null && numB != null) {
          cmp = numA.compareTo(numB);
        } else {
          cmp = valA.compareTo(valB);
        }

        return _sortAscending ? cmp : -cmp;
      });
    }

    // Pagination
    final totalRows = filteredRows.length;
    final totalPages = (totalRows / _pageSize).ceil();
    final pagedRows = filteredRows.skip(_currentPage * _pageSize).take(_pageSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls Toolbar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search across rows...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 16),
                        suffixIcon: _filterText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _filterText = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _filterText = val;
                          _currentPage = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Selected Only', style: TextStyle(fontSize: 12)),
                    selected: _showSelectedOnly,
                    onSelected: (val) => setState(() => _showSelectedOnly = val),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${pagedRows.length} of $totalRows rows',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                      ),
                      Text(
                        '${_currentPage + 1} / ${totalPages == 0 ? 1 : totalPages}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        onPressed: (_currentPage + 1) < totalPages
                            ? () => setState(() => _currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Scrollable Table
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                headingRowColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                columns: displayedColumns.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final header = entry.value;
                  final isSelectedVar = state.selectedColumns.contains(header);

                  return DataColumn(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          header,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelectedVar ? AppColors.primary : null,
                          ),
                        ),
                        if (isSelectedVar) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = idx;
                        _sortAscending = ascending;
                      });
                    },
                  );
                }).toList(),
                rows: pagedRows.map((row) {
                  return DataRow(
                    cells: displayedColumns.map((header) {
                      final val = table.getCellValue(row, header);
                      final isSelectedVar = state.selectedColumns.contains(header);

                      return DataCell(
                        Text(
                          val,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelectedVar ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
