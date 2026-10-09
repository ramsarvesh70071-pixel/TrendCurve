import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'providers/pdf_analyzer_provider.dart';
import 'widgets/data_table_preview_widget.dart';
import 'widgets/export_excel_button.dart';
import 'widgets/pdf_uploader_widget.dart';
import 'widgets/trend_curve_chart_widget.dart';
import 'widgets/trend_summary_cards_widget.dart';
import 'widgets/variable_selector_widget.dart';

class PdfAnalyzerScreen extends ConsumerWidget {
  const PdfAnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfAnalyzerProvider);
    final notifier = ref.read(pdfAnalyzerProvider.notifier);
    final theme = Theme.of(context);

    final steps = [
      {'title': 'Upload PDF', 'icon': Icons.cloud_upload_rounded},
      {'title': 'Select Variables', 'icon': Icons.checklist_rounded},
      {'title': 'Trend Curves', 'icon': Icons.show_chart_rounded},
      {'title': 'Summary & Export', 'icon': Icons.table_chart_rounded},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PDF Trend Analyzer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'PDF to Curve & Excel Engine',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (state.currentTable != null)
            IconButton(
              tooltip: 'Reset Session',
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () => notifier.reset(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: List.generate(steps.length, (index) {
                final isCurrent = state.currentStep == index;
                final isCompleted = state.currentStep > index;
                final step = steps[index];

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (index == 0 || (state.currentTable != null && (index <= 1 || state.selectedColumns.isNotEmpty))) {
                        notifier.setStep(index);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 3,
                                  color: index == 0
                                      ? Colors.transparent
                                      : (isCompleted || isCurrent
                                          ? AppColors.primary
                                          : theme.dividerColor),
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted
                                      ? AppColors.success
                                      : (isCurrent ? AppColors.primary : theme.colorScheme.surfaceContainerHighest),
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isCurrent ? Colors.white : AppColors.textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 3,
                                  color: index == steps.length - 1
                                      ? Colors.transparent
                                      : (isCompleted
                                          ? AppColors.primary
                                          : theme.dividerColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent
                                  ? AppColors.primary
                                  : (isCompleted ? theme.textTheme.bodyMedium?.color : AppColors.textSecondary),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Main Step View Body
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildCurrentStep(state.currentStep),
            ),
          ),
        ],
      ),
      bottomNavigationBar: state.currentTable != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (state.currentStep > 0)
                      OutlinedButton.icon(
                        onPressed: () => notifier.setStep(state.currentStep - 1),
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    const Spacer(),
                    if (state.currentStep < steps.length - 1)
                      ElevatedButton.icon(
                        onPressed: (state.currentStep == 1 && state.selectedColumns.isEmpty)
                            ? null
                            : () => notifier.setStep(state.currentStep + 1),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(state.currentStep == 0 ? 'Select Variables' : 'Next Step'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 0:
        return const PdfUploaderWidget();
      case 1:
        return const VariableSelectorWidget();
      case 2:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              TrendCurveChartWidget(),
              SizedBox(height: 24),
              TrendSummaryCardsWidget(),
            ],
          ),
        );
      case 3:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ExportExcelButton(),
              SizedBox(height: 24),
              DataTablePreviewWidget(),
            ],
          ),
        );
      default:
        return const PdfUploaderWidget();
    }
  }
}
