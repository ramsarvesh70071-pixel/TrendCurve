import 'package:intl/intl.dart';

/// Centralized number and currency formatting utilities.
class AppNumberFormatter {
  AppNumberFormatter._();

  static final NumberFormat _standardFormat = NumberFormat('#,##0.##');
  static final NumberFormat _compactFormat = NumberFormat.compact();

  /// Formats value with unit (e.g., "$12,450.50" or "75.2 kg" or "₹1,00,000")
  static String formatValue(double value, String unit) {
    final formattedNumber = _standardFormat.format(value);
    final isSymbolPrefix = ['\$', '₹', '€', '£', '¥'].contains(unit);

    if (isSymbolPrefix) {
      return '$unit$formattedNumber';
    } else if (unit.isNotEmpty) {
      return '$formattedNumber $unit';
    }
    return formattedNumber;
  }

  /// Compact representation for charts or small cards (e.g., "$12.5k")
  static String formatCompact(double value, String unit) {
    final compactStr = _compactFormat.format(value);
    final isSymbolPrefix = ['\$', '₹', '€', '£', '¥'].contains(unit);

    if (isSymbolPrefix) {
      return '$unit$compactStr';
    } else if (unit.isNotEmpty) {
      return '$compactStr $unit';
    }
    return compactStr;
  }

  /// Formats percentage with sign: "+18.4%" or "-5.2%" or "0.0%"
  static String formatPercentage(double percent, {bool includePlus = true}) {
    final sign = (percent > 0 && includePlus) ? '+' : '';
    return '$sign${percent.toStringAsFixed(1)}%';
  }
}
