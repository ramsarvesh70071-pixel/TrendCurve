import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/pdf_analyzer_provider.dart';
import '../services/data_cleaner_service.dart';

class TrendCurveChartWidget extends ConsumerStatefulWidget {
  const TrendCurveChartWidget({super.key});

  @override
  ConsumerState<TrendCurveChartWidget> createState() => _TrendCurveChartWidgetState();
}

class _TrendCurveChartWidgetState extends ConsumerState<TrendCurveChartWidget> {
  int _individualVariableIndex = 0;

  static const List<Color> _palette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF3B82F6), // Blue
  ];

  Color _getColorForIndex(int idx) => _palette[idx % _palette.length];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfAnalyzerProvider);
    final notifier = ref.read(pdfAnalyzerProvider.notifier);
    final theme = Theme.of(context);
    final seriesList = state.processedSeries.values.toList();

    if (seriesList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.show_chart_rounded, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('No numeric series selected yet.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.setStep(1),
                child: const Text('Back to Variable Selection'),
              ),
            ],
          ),
        ),
      );
    }

    final isCombined = state.chartMode == 'combined';
    final activeSeries = isCombined
        ? seriesList
        : [seriesList[_individualVariableIndex.clamp(0, seriesList.length - 1)]];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Trend Analysis',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // Mode Toggle
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'combined',
                        label: Text('Combined', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.layers_rounded, size: 14),
                      ),
                      ButtonSegment(
                        value: 'individual',
                        label: Text('Individual', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.crop_free_rounded, size: 14),
                      ),
                    ],
                    selected: {state.chartMode},
                    onSelectionChanged: (newSelection) {
                      notifier.setChartMode(newSelection.first);
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              if (!isCombined) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: _individualVariableIndex.clamp(0, seriesList.length - 1),
                  decoration: InputDecoration(
                    labelText: 'Active Variable Curve',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: List.generate(
                    seriesList.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getColorForIndex(i),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(seriesList[i].variableName),
                        ],
                      ),
                    ),
                  ),
                  onChanged: (idx) {
                    if (idx != null) {
                      setState(() => _individualVariableIndex = idx);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Interactive Chart Canvas
        Container(
          height: 320,
          padding: const EdgeInsets.fromLTRB(10, 20, 16, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildLineChart(activeSeries, theme),
        ),
        const SizedBox(height: 14),

        // Dynamic Chart Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(seriesList.length, (idx) {
            final isVisible = isCombined || _individualVariableIndex == idx;
            final color = _getColorForIndex(idx);

            return InkWell(
              onTap: () {
                notifier.setChartMode('individual');
                setState(() => _individualVariableIndex = idx);
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isVisible ? 1.0 : 0.4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        seriesList[idx].variableName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLineChart(List<ProcessedChartSeries> seriesToDisplay, ThemeData theme) {
    if (seriesToDisplay.isEmpty) return const SizedBox.shrink();

    // Determine min and max Y for proper scaling
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    int maxDataPoints = 0;

    for (final s in seriesToDisplay) {
      if (s.cleanedValues.isNotEmpty) {
        final sMin = s.cleanedValues.reduce(math.min);
        final sMax = s.cleanedValues.reduce(math.max);
        if (sMin < minY) minY = sMin;
        if (sMax > maxY) maxY = sMax;
        if (s.cleanedValues.length > maxDataPoints) {
          maxDataPoints = s.cleanedValues.length;
        }
      }
    }

    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 100;
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final yPadding = (maxY - minY) * 0.12;
    minY = (minY - yPadding);
    maxY = (maxY + yPadding);

    // Build LineChartBarData list
    final lineBarsData = <LineChartBarData>[];
    for (int sIdx = 0; sIdx < seriesToDisplay.length; sIdx++) {
      final s = seriesToDisplay[sIdx];
      final color = _getColorForIndex(sIdx);
      final spots = <FlSpot>[];

      for (int i = 0; i < s.cleanedValues.length; i++) {
        spots.add(FlSpot(i.toDouble(), s.cleanedValues[i]));
      }

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 2.8,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 30,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 3.5,
              color: color,
              strokeWidth: 1.5,
              strokeColor: theme.colorScheme.surface,
            ),
          ),
          belowBarData: BarAreaData(
            show: seriesToDisplay.length == 1,
            color: color.withValues(alpha: 0.12),
          ),
        ),
      );
    }

    final xLabels = seriesToDisplay.first.xLabels;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: math.max(0, (maxDataPoints - 1).toDouble()),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E293B),
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final sIndex = spot.barIndex;
                final pointIndex = spot.x.toInt();
                final sName = seriesToDisplay[sIndex].variableName;
                final label = pointIndex < xLabels.length ? xLabels[pointIndex] : '$pointIndex';
                return LineTooltipItem(
                  '$sName\n$label: ${spot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ((maxY - minY) / 5).clamp(0.1, double.infinity),
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.dividerColor.withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: math.max(1, (maxDataPoints / 5).floor()).toDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= xLabels.length) return const SizedBox.shrink();
                final raw = xLabels[idx];
                final shortLabel = raw.length > 8 ? raw.substring(0, 8) : raw;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    shortLabel,
                    style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lineBarsData,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
