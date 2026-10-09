import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/variable_metadata.dart';
import '../providers/pdf_analyzer_provider.dart';

class VariableSelectorWidget extends ConsumerStatefulWidget {
  const VariableSelectorWidget({super.key});

  @override
  ConsumerState<VariableSelectorWidget> createState() => _VariableSelectorWidgetState();
}

class _VariableSelectorWidgetState extends ConsumerState<VariableSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getTypeColor(ColumnDataType type) {
    switch (type) {
      case ColumnDataType.numeric:
        return AppColors.primary;
      case ColumnDataType.date:
        return AppColors.secondary;
      case ColumnDataType.text:
        return AppColors.warning;
    }
  }

  IconData _getTypeIcon(ColumnDataType type) {
    switch (type) {
      case ColumnDataType.numeric:
        return Icons.pin_rounded;
      case ColumnDataType.date:
        return Icons.calendar_today_rounded;
      case ColumnDataType.text:
        return Icons.text_fields_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfAnalyzerProvider);
    final notifier = ref.read(pdfAnalyzerProvider.notifier);
    final theme = Theme.of(context);
    final table = state.currentTable;

    if (table == null) {
      return const Center(child: Text('No table extracted yet.'));
    }

    final filteredColumns = table.columns.where((col) {
      if (_searchQuery.isEmpty) return true;
      return col.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 2: Variable & Axis Configuration',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Choose numeric series to plot and configure the reference X-Axis.',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // X-Axis Configuration Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Reference X-Axis (Timeline / Base Index)',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: state.xAxisColumn ?? ((table.defaultXAxisColumn != null && table.defaultXAxisColumn!.isNotEmpty) ? table.defaultXAxisColumn : '__row_index__'),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '__row_index__',
                      child: Text('Row / Entry Index (Default 1, 2, 3...)'),
                    ),
                    ...table.columns.map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Row(
                            children: [
                              Icon(_getTypeIcon(c.type), size: 14, color: _getTypeColor(c.type)),
                              const SizedBox(width: 8),
                              Text('${c.name} (${c.type.label})'),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    if (val != null) notifier.setXAxisColumn(val == '__row_index__' ? null : val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Cleaning Strategy
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_fix_high_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Missing Values Handling Strategy',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<CleaningOption>(
                  segments: const [
                    ButtonSegment(
                      value: CleaningOption.ignoreMissing,
                      label: Text('Ignore', style: TextStyle(fontSize: 11)),
                    ),
                    ButtonSegment(
                      value: CleaningOption.treatAsZero,
                      label: Text('Treat as 0', style: TextStyle(fontSize: 11)),
                    ),
                    ButtonSegment(
                      value: CleaningOption.interpolate,
                      label: Text('Interpolate', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                  selected: {state.cleaningOption},
                  onSelectionChanged: (set) => notifier.setCleaningOption(set.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search & Quick Select / Clear Actions
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search variables...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => notifier.selectAllVariables(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('All Numeric', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: () => notifier.clearAllVariables(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Active Selected Variables Chips
          if (state.selectedColumns.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.selectedColumns.map((colName) {
                return Chip(
                  label: Text(colName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                  onDeleted: () => notifier.toggleVariable(colName),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Variables List
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredColumns.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4)),
              itemBuilder: (context, index) {
                final col = filteredColumns[index];
                final isSelected = state.selectedColumns.contains(col.name);
                final canSelect = col.isNumeric;

                return CheckboxListTile(
                  value: isSelected,
                  enabled: canSelect,
                  activeColor: AppColors.primary,
                  onChanged: canSelect ? (_) => notifier.toggleVariable(col.name) : null,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          col.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: canSelect ? null : AppColors.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getTypeColor(col.type).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getTypeIcon(col.type), size: 12, color: _getTypeColor(col.type)),
                            const SizedBox(width: 4),
                            Text(
                              col.type.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getTypeColor(col.type),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${col.validValuesCount} valid • ${col.missingValuesCount} missing',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Next Step CTA Button
          ElevatedButton.icon(
            onPressed: state.selectedColumns.isEmpty
                ? null
                : () => notifier.setStep(2),
            icon: const Icon(Icons.auto_graph_rounded),
            label: Text(
              state.selectedColumns.isEmpty
                  ? 'Select at least 1 numeric variable'
                  : 'Generate Trend Curves (${state.selectedColumns.length} selected)',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
