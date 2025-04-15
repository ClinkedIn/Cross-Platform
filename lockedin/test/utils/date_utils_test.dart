import 'package:intl/intl.dart';
import 'package:lockedin/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateUtils', () {
    test('timeAgo returns "just now" for less than 60 seconds', () {
      final now = DateTime.now();
      final result = DateUtils.timeAgo(now);
      expect(result, 'just now');
    });

    test('timeAgo returns minutes ago correctly', () {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(Duration(minutes: 5));
      final result = DateUtils.timeAgo(fiveMinutesAgo);
      expect(result, '5m ago');
    });

    test('timeAgo returns hours ago correctly', () {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(Duration(hours: 2));
      final result = DateUtils.timeAgo(twoHoursAgo);
      expect(result, '2h ago');
    });

    test('timeAgo returns days ago correctly', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(Duration(days: 3));
      final result = DateUtils.timeAgo(threeDaysAgo);
      expect(result, '3d ago');
    });

    test('timeAgo returns correct date when more than 7 days ago', () {
      final now = DateTime.now();
      final twoWeeksAgo = now.subtract(Duration(days: 14));
      final result = DateUtils.timeAgo(twoWeeksAgo);
      final expected = DateFormat(
        'd/M/yyyy',
      ).format(twoWeeksAgo); // Formatted date
      expect(result, expected);
    });

    test('timeAgo returns correct result for edge cases (1 minute)', () {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(Duration(minutes: 1));
      final result = DateUtils.timeAgo(oneMinuteAgo);
      expect(result, '1m ago');
    });

    test('timeAgo returns correct result for edge cases (1 hour)', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(Duration(hours: 1));
      final result = DateUtils.timeAgo(oneHourAgo);
      expect(result, '1h ago');
    });
  });
}
