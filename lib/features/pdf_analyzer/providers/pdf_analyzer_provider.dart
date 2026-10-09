import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/variable_metadata.dart';
import '../models/extracted_table_model.dart';
import '../services/data_cleaner_service.dart';
import '../services/excel_exporter_service.dart';
import '../services/pdf_parser_service.dart';

class PdfAnalyzerState {
  final int currentStep;
  final String? fileName;
  final int? fileSizeBytes;
  final bool isProcessing;
  final String? errorMessage;
  final List<ExtractedTableModel> extractedTables;
  final int selectedTableIndex;
  final List<String> selectedColumns;
  final String? xAxisColumn;
  final CleaningOption cleaningOption;
  final String chartMode; // 'combined' or 'individual'
  final Map<String, ProcessedChartSeries> processedSeries;
  final bool isExporting;
  final String? lastExportedFilePath;

  const PdfAnalyzerState({
    this.currentStep = 0,
    this.fileName,
    this.fileSizeBytes,
    this.isProcessing = false,
    this.errorMessage,
    this.extractedTables = const [],
    this.selectedTableIndex = 0,
    this.selectedColumns = const [],
    this.xAxisColumn,
    this.cleaningOption = CleaningOption.ignoreMissing,
    this.chartMode = 'combined',
    this.processedSeries = const {},
    this.isExporting = false,
    this.lastExportedFilePath,
  });

  ExtractedTableModel? get currentTable {
    if (extractedTables.isEmpty ||
        selectedTableIndex < 0 ||
        selectedTableIndex >= extractedTables.length) {
      return null;
    }
    return extractedTables[selectedTableIndex];
  }

  PdfAnalyzerState copyWith({
    int? currentStep,
    String? fileName,
    int? fileSizeBytes,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    List<ExtractedTableModel>? extractedTables,
    int? selectedTableIndex,
    List<String>? selectedColumns,
    String? xAxisColumn,
    bool clearXAxis = false,
    CleaningOption? cleaningOption,
    String? chartMode,
    Map<String, ProcessedChartSeries>? processedSeries,
    bool? isExporting,
    String? lastExportedFilePath,
  }) {
    return PdfAnalyzerState(
      currentStep: currentStep ?? this.currentStep,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      extractedTables: extractedTables ?? this.extractedTables,
      selectedTableIndex: selectedTableIndex ?? this.selectedTableIndex,
      selectedColumns: selectedColumns ?? this.selectedColumns,
      xAxisColumn: clearXAxis ? null : (xAxisColumn ?? this.xAxisColumn),
      cleaningOption: cleaningOption ?? this.cleaningOption,
      chartMode: chartMode ?? this.chartMode,
      processedSeries: processedSeries ?? this.processedSeries,
      isExporting: isExporting ?? this.isExporting,
      lastExportedFilePath: lastExportedFilePath ?? this.lastExportedFilePath,
    );
  }
}

class PdfAnalyzerNotifier extends Notifier<PdfAnalyzerState> {
  final _parserService = PdfParserService();
  final _cleanerService = DataCleanerService();
  final _exporterService = ExcelExporterService();

  @override
  PdfAnalyzerState build() {
    return const PdfAnalyzerState();
  }

  /// Process uploaded PDF bytes
  Future<void> processPdfBytes(Uint8List bytes, String fileName, int sizeBytes) async {
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      fileName: fileName,
      fileSizeBytes: sizeBytes,
    );

    try {
      final tables = await _parserService.parsePdfBytes(bytes, fileName: fileName);
      if (tables.isEmpty) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'No structured tabular data detected in PDF. Ensure the PDF contains tables.',
        );
        return;
      }

      final firstTable = tables.first;
      // Default: pick first 2-3 numeric columns
      final defaultNumerics = firstTable.numericColumns.take(3).toList();
      final defaultX = firstTable.defaultXAxisColumn;

      final processed = _cleanerService.processData(
        table: firstTable,
        selectedColumns: defaultNumerics,
        xAxisColumn: defaultX,
        cleaningOption: state.cleaningOption,
      );

      state = state.copyWith(
        isProcessing: false,
        extractedTables: tables,
        selectedTableIndex: 0,
        selectedColumns: defaultNumerics,
        xAxisColumn: defaultX,
        processedSeries: processed,
        currentStep: 1, // Advance to variables step
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Loads built-in sample dataset for instant demonstration
  void loadSampleDataset(int index) {
    final samples = PdfParserService.getSampleDatasets();
    final table = samples[index.clamp(0, samples.length - 1)];

    final defaultNumerics = table.numericColumns.take(3).toList();
    final defaultX = table.defaultXAxisColumn;

    final processed = _cleanerService.processData(
      table: table,
      selectedColumns: defaultNumerics,
      xAxisColumn: defaultX,
      cleaningOption: state.cleaningOption,
    );

    state = state.copyWith(
      fileName: '${table.name}.pdf',
      fileSizeBytes: 142000,
      extractedTables: samples,
      selectedTableIndex: index.clamp(0, samples.length - 1),
      selectedColumns: defaultNumerics,
      xAxisColumn: defaultX,
      processedSeries: processed,
      currentStep: 1,
      clearError: true,
    );
  }

  void selectTable(int index) {
    if (index < 0 || index >= state.extractedTables.length) return;
    final table = state.extractedTables[index];
    final defaultNumerics = table.numericColumns.take(3).toList();
    final defaultX = table.defaultXAxisColumn;

    final processed = _cleanerService.processData(
      table: table,
      selectedColumns: defaultNumerics,
      xAxisColumn: defaultX,
      cleaningOption: state.cleaningOption,
    );

    state = state.copyWith(
      selectedTableIndex: index,
      selectedColumns: defaultNumerics,
      xAxisColumn: defaultX,
      processedSeries: processed,
    );
  }

  void toggleVariable(String columnName) {
    final current = List<String>.from(state.selectedColumns);
    if (current.contains(columnName)) {
      current.remove(columnName);
    } else {
      current.add(columnName);
    }
    _recalculate(selectedColumns: current);
  }

  void selectAllVariables() {
    final table = state.currentTable;
    if (table == null) return;
    final numerics = table.numericColumns;
    _recalculate(selectedColumns: numerics);
  }

  void clearAllVariables() {
    _recalculate(selectedColumns: []);
  }

  void setXAxisColumn(String? col) {
    _recalculate(xAxisColumn: col);
  }

  void setCleaningOption(CleaningOption option) {
    state = state.copyWith(cleaningOption: option);
    _recalculate(cleaningOption: option);
  }

  void setChartMode(String mode) {
    state = state.copyWith(chartMode: mode);
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void reset() {
    state = const PdfAnalyzerState();
  }

  void _recalculate({
    List<String>? selectedColumns,
    String? xAxisColumn,
    CleaningOption? cleaningOption,
  }) {
    final table = state.currentTable;
    if (table == null) return;

    final cols = selectedColumns ?? state.selectedColumns;
    final xCol = xAxisColumn ?? state.xAxisColumn;
    final cleanOpt = cleaningOption ?? state.cleaningOption;

    final processed = _cleanerService.processData(
      table: table,
      selectedColumns: cols,
      xAxisColumn: xCol,
      cleaningOption: cleanOpt,
    );

    state = state.copyWith(
      selectedColumns: cols,
      xAxisColumn: xCol,
      cleaningOption: cleanOpt,
      processedSeries: processed,
    );
  }

  /// Exports processed data and summary into multi-sheet Excel file
  Future<String?> exportToExcel() async {
    final table = state.currentTable;
    if (table == null || state.selectedColumns.isEmpty) return null;

    state = state.copyWith(isExporting: true, clearError: true);
    try {
      final path = await _exporterService.exportToExcel(
        table: table,
        selectedColumns: state.selectedColumns,
        xAxisColumn: state.xAxisColumn,
        processedSeries: state.processedSeries,
      );
      state = state.copyWith(isExporting: false, lastExportedFilePath: path);
      return path;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Export failed: ${e.toString()}',
      );
      return null;
    }
  }
}

final pdfAnalyzerProvider =
    NotifierProvider<PdfAnalyzerNotifier, PdfAnalyzerState>(PdfAnalyzerNotifier.new);
