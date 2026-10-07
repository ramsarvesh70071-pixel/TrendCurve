import 'package:flutter_test/flutter_test.dart';
import 'package:trend_curve/core/utils/date_formatter.dart';
import 'package:trend_curve/core/utils/number_formatter.dart';
import 'package:trend_curve/core/utils/validators.dart';

void main() {
  group('AppNumberFormatter Tests', () {
    test('formatValue prefixes currency symbols properly', () {
      expect(AppNumberFormatter.formatValue(1000, '₹'), equals('₹1,000'));
      expect(AppNumberFormatter.formatValue(2500.5, '\$'), equals('\$2,500.5'));
      expect(AppNumberFormatter.formatValue(75.5, 'kg'), equals('75.5 kg'));
      expect(AppNumberFormatter.formatValue(120, 'hrs'), equals('120 hrs'));
    });

    test('formatPercentage formats signs and decimals accurately', () {
      expect(AppNumberFormatter.formatPercentage(15.4), equals('+15.4%'));
      expect(AppNumberFormatter.formatPercentage(-8.2), equals('-8.2%'));
      expect(AppNumberFormatter.formatPercentage(0.0), equals('0.0%'));
      expect(AppNumberFormatter.formatPercentage(15.4, includePlus: false), equals('15.4%'));
    });

    test('formatCompact converts large numbers', () {
      final compactVal = AppNumberFormatter.formatCompact(1500000, '\$');
      expect(compactVal.contains('\$'), isTrue);
      expect(compactVal.contains('1.5M') || compactVal.contains('1.50M'), isTrue);
    });
  });

  group('AppValidators Tests', () {
    test('email validator verifies email pattern', () {
      expect(AppValidators.email('valid@example.com'), isNull);
      expect(AppValidators.email('invalid-email'), isNotNull);
      expect(AppValidators.email(''), isNotNull);
      expect(AppValidators.email(null), isNotNull);
    });

    test('password validator enforces minimum length', () {
      expect(AppValidators.password('123456'), isNull);
      expect(AppValidators.password('12345'), isNotNull);
      expect(AppValidators.password(''), isNotNull);
    });

    test('confirmPassword validator ensures matching strings', () {
      expect(AppValidators.confirmPassword('secret123', 'secret123'), isNull);
      expect(AppValidators.confirmPassword('secret123', 'different'), isNotNull);
      expect(AppValidators.confirmPassword('', 'secret123'), isNotNull);
    });
  });

  group('AppDateFormatter Tests', () {
    test('formats dates consistently', () {
      final dt = DateTime(2025, 5, 15);
      expect(AppDateFormatter.short(dt), contains('May'));
      expect(AppDateFormatter.medium(dt), contains('2025'));
    });
  });
}
