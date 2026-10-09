import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pdf_analyzer_provider.dart';

class PdfUploaderWidget extends ConsumerWidget {
  const PdfUploaderWidget({super.key});

  Future<void> _pickPdfFile(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          await ref.read(pdfAnalyzerProvider.notifier).processPdfBytes(
                file.bytes!,
                file.name,
                file.size,
              );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfAnalyzerProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PDF Data Extraction & Trend Engine',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upload any table-based PDF to extract columns, plot interactive curves, and export to Excel.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Upload Drop Zone
          InkWell(
            onTap: state.isProcessing ? null : () => _pickPdfFile(context, ref),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.fileName != null
                      ? AppColors.primary
                      : theme.dividerColor,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isProcessing) ...[
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Parsing PDF & Extracting Variables...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Detecting tabular columns, numbers, and timestamps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else if (state.fileName != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.fileName!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.fileSizeBytes != null)
                          Chip(
                            label: Text(_formatBytes(state.fileSizeBytes!)),
                            avatar: const Icon(Icons.storage_rounded, size: 14),
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                        const SizedBox(width: 8),
                        if (state.currentTable != null)
                          Chip(
                            label: Text('${state.currentTable!.rowCount} rows • ${state.currentTable!.headers.length} columns'),
                            avatar: const Icon(Icons.table_rows_rounded, size: 14),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _pickPdfFile(context, ref),
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: const Text('Change PDF File'),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose a PDF file to analyze',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Supports reports with sensor logs, finance tables, metrics, etc.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _pickPdfFile(context, ref),
                      icon: const Icon(Icons.file_open_rounded, size: 18),
                      label: const Text('Browse Device Storage'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Error Message Display
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Table Selector if multi-table
          if (state.extractedTables.length > 1) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.layers_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Multiple Tables Detected (${state.extractedTables.length})',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: state.selectedTableIndex,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: List.generate(
                      state.extractedTables.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text('${state.extractedTables[index].name} (${state.extractedTables[index].rowCount} rows)'),
                      ),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(pdfAnalyzerProvider.notifier).selectTable(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],

          // Instant 1-Tap Sample Datasets
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'TRY READY-TO-TEST SAMPLES (1-TAP)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isProcessing
                      ? null
                      : () => ref.read(pdfAnalyzerProvider.notifier).loadSampleDataset(0),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.speed_rounded, size: 22, color: AppColors.primary),
                      SizedBox(height: 6),
                      Text(
                        'Sensor Telemetry',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Temp, Pressure, Voltage',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isProcessing
                      ? null
                      : () => ref.read(pdfAnalyzerProvider.notifier).loadSampleDataset(1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.trending_up_rounded, size: 22, color: AppColors.secondary),
                      SizedBox(height: 6),
                      Text(
                        'Financial Metrics',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Revenue, Margin, Volume',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (state.currentTable != null) ...[
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => ref.read(pdfAnalyzerProvider.notifier).setStep(1),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Proceed to Variable Selection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
