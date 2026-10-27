import 'package:flutter_test/flutter_test.dart';
import 'package:meoxu/core/utils/work_hours_converter.dart';

void main() {
  group('WorkHoursConverter Test Suite', () {
    // 17.6 million VND / 176 hours = 100,000 VND / hour
    const double monthlyIncome = 17600000.0;
    const double monthlyHours = 176.0;

    test('Under 1 hour should display minutes', () {
      // 45,000 VND / 100,000 = 0.45h = 27 minutes
      final result = WorkHoursConverter.convertToWorkTime(
        amount: 45000.0,
        monthlyIncome: monthlyIncome,
        monthlyWorkHours: monthlyHours,
      );
      expect(result, equals('≈ 27 phút làm việc'));
    });

    test('Exact 1 hour should display 1 hour', () {
      final result = WorkHoursConverter.convertToWorkTime(
        amount: 100000.0,
        monthlyIncome: monthlyIncome,
        monthlyWorkHours: monthlyHours,
      );
      expect(result, equals('≈ 1 giờ làm việc'));
    });

    test('Between 1 and 8 hours should display hours and minutes', () {
      // 250,000 VND = 2.5 hours = 2 hours 30 mins
      final result = WorkHoursConverter.convertToWorkTime(
        amount: 250000.0,
        monthlyIncome: monthlyIncome,
        monthlyWorkHours: monthlyHours,
      );
      expect(result, equals('≈ 2 giờ 30 phút làm việc'));
    });

    test('Above 8 hours (workday) should display work days', () {
      // 1200,000 VND = 12 hours = 1.5 workdays (12 / 8)
      final result = WorkHoursConverter.convertToWorkTime(
        amount: 1200000.0,
        monthlyIncome: monthlyIncome,
        monthlyWorkHours: monthlyHours,
      );
      expect(result, equals('≈ 1,5 ngày công'));
    });
  });
}
