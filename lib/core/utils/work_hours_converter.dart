class WorkHoursConverter {
  /// Converts an amount to work hours formatted string
  /// [monthlyIncome]: VND per month
  /// [monthlyWorkHours]: Default 176 hours per month (22 days * 8 hours)
  static String convertToWorkTime({
    required double amount,
    required double monthlyIncome,
    double monthlyWorkHours = 176.0,
  }) {
    if (monthlyIncome <= 0 || monthlyWorkHours <= 0 || amount <= 0) {
      return '';
    }

    final hourlyWage = monthlyIncome / monthlyWorkHours;
    final totalHours = amount / hourlyWage;
    final totalMinutes = (totalHours * 60).round();

    if (totalMinutes < 60) {
      final mins = totalMinutes <= 0 ? 1 : totalMinutes;
      return '≈ $mins phút làm việc';
    }

    if (totalHours < 8.0) {
      final hours = totalMinutes ~/ 60;
      final remainingMins = totalMinutes % 60;
      if (remainingMins == 0) {
        return '≈ $hours giờ làm việc';
      }
      return '≈ $hours giờ $remainingMins phút làm việc';
    }

    // >= 8 hours -> represent in working days (1 workday = 8h)
    final workDays = totalHours / 8.0;
    final formattedDays = workDays.toStringAsFixed(1).replaceAll('.', ',');
    // Clean up trailing ',0' if any
    final cleanDays = formattedDays.endsWith(',0')
        ? formattedDays.substring(0, formattedDays.length - 2)
        : formattedDays;

    return '≈ $cleanDays ngày công';
  }
}
