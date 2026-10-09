import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pdf_analyzer_provider.dart';

class ExportExcelButton extends ConsumerWidget {
  const ExportExcelButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfAnalyzerProvider);
    final notifier = ref.read(pdfAnalyzerProvider.notifier);
    final theme = Theme.of(context);

    final canExport = state.currentTable != null &&
        state.selectedColumns.isNotEmpty &&
        !state.isExporting;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_chart_rounded, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Sheet Excel Workbook (.xlsx)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Exports 4 dedicated sheets: Original Data, Selected Variables, Trend Curve Data, and Statistical Summary.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: canExport
                ? () async {
                    final path = await notifier.exportToExcel();
                    if (path != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Workbook generated & shared successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                : null,
            icon: state.isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.file_download_rounded, size: 18),
            label: Text(
              state.isExporting
                  ? 'Compiling Multi-Sheet .xlsx...'
                  : 'Export to Excel (.xlsx)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
          ),
          if (state.lastExportedFilePath != null) ...[
            const SizedBox(height: 8),
            Text(
              'Saved to: ${state.lastExportedFilePath!.split(RegExp(r'[\\/]')).last}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
