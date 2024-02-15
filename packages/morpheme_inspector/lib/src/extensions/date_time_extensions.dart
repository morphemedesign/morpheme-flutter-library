import 'package:intl/intl.dart';

/// Extension of [DateTime]
extension DateTimeExtension on DateTime {
  /// Convert to string date format 'HH:mm:ss' example '22:43:00'
  String toHHMMSS() => DateFormat('HH:mm:ss').format(this);
}

/// Extension of nullable [DateTime]
extension DateTimeNullExtension on DateTime? {
  /// Convert to string date format 'EEEE, yyyy-MM-dd HH:mm:ss' example 'Thuesday, 2022-06-25 22:43:00'
  ///
  /// Return '-' if date time is null
  String toDateTimeString() => this != null
      ? DateFormat('EEEE, yyyy-MM-dd HH:mm:ss').format(this!)
      : '-';
}
