import 'package:intl/intl.dart';

/// Centralized Date formatting utilities using `intl`.
class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _shortDate = DateFormat('MMM d');
  static final DateFormat _mediumDate = DateFormat('MMM d, yyyy');
  static final DateFormat _fullDate = DateFormat('MMMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, h:mm a');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');

  static String short(DateTime date) => _shortDate.format(date);
  static String medium(DateTime date) => _mediumDate.format(date);
  static String full(DateTime date) => _fullDate.format(date);
  static String time(DateTime date) => _timeFormat.format(date);
  static String dateTime(DateTime date) => _dateTimeFormat.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// Human relative time (e.g., "Just now", "5m ago", "2h ago", "Yesterday", "3d ago")
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return _shortDate.format(date);
    }
  }
}
