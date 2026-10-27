import '../../models/transaction_item.dart';
import '../../models/fixed_expense.dart';
import '../../models/user_profile.dart';
import 'date_time_utils.dart';

class BudgetCalculationResult {
  final double monthlyIncome;
  final double totalFixedExpenses;
  final double savingPercentage;
  final double savingAmount;
  final double monthlyBudget; // ngân_sách_tháng
  final double spentBeforeToday; // đã chi trước hôm nay trong tháng (chỉ tính chi tiêu biến đổi)
  final double spentToday; // đã chi hôm nay
  final int remainingDays; // ngày còn lại trong tháng tính cả hôm nay
  final double dailyAllowance; // chi_thoải_mái_hôm_nay = (ngân_sách_tháng - spentBeforeToday) / remainingDays
  final double remainingToday; // số tiền còn lại có thể tiêu hôm nay = dailyAllowance - spentToday
  final double fishPercentage; // Tỉ lệ đĩa cá khô (0.0 đến 1.0)
  final bool isOverspent; // Đã tiêu vượt hạn mức hôm nay
  final bool isUnder20Percent; // Còn dưới 20%

  const BudgetCalculationResult({
    required this.monthlyIncome,
    required this.totalFixedExpenses,
    required this.savingPercentage,
    required this.savingAmount,
    required this.monthlyBudget,
    required this.spentBeforeToday,
    required this.spentToday,
    required this.remainingDays,
    required this.dailyAllowance,
    required this.remainingToday,
    required this.fishPercentage,
    required this.isOverspent,
    required this.isUnder20Percent,
  });
}

class BudgetCalculator {
  static BudgetCalculationResult calculate({
    required UserProfile profile,
    required List<FixedExpense> fixedExpenses,
    required List<TransactionItem> monthlyTransactions,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    final remainingDays = DateTimeUtils.getRemainingDaysInMonth(now);

    // 1. Total fixed expenses
    final totalFixed = fixedExpenses.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );

    // 2. Saving amount
    final savingAmount =
        (profile.monthlyIncome * (profile.savingPercentage / 100.0));

    // 3. Monthly budget for variable spending
    // ngân_sách_tháng = thu_nhập_dự_kiến − chi_cố_định − mục_tiêu_tiết_kiệm
    final monthlyBudget = profile.monthlyIncome - totalFixed - savingAmount;

    // 4. Calculate variable expenses spent so far this month
    double spentBeforeToday = 0.0;
    double spentToday = 0.0;

    for (final tx in monthlyTransactions) {
      // Only count non-fixed expenses in variable budget
      if (tx.isExpense && !tx.isFixed) {
        if (DateTimeUtils.isSameDay(tx.dateTime, now)) {
          spentToday += tx.amount;
        } else if (tx.dateTime.year == now.year &&
            tx.dateTime.month == now.month &&
            tx.dateTime.isBefore(now)) {
          spentBeforeToday += tx.amount;
        }
      }
    }

    // 5. Daily allowance formula from Section 4.3:
    // chi_thoải_mái_hôm_nay = (ngân_sách_tháng − đã_chi_thoải_mái_từ_đầu_tháng) / ngày_còn_lại
    final availablePool = monthlyBudget - spentBeforeToday;
    double dailyAllowance = remainingDays > 0
        ? (availablePool / remainingDays)
        : 0.0;
    if (dailyAllowance < 0) dailyAllowance = 0.0;

    // Remaining today
    final remainingToday = dailyAllowance - spentToday;
    final isOverspent = remainingToday <= 0;
    final isUnder20Percent =
        dailyAllowance > 0 && (remainingToday / dailyAllowance) <= 0.2;

    // Fish percentage for visualization
    double fishPct = dailyAllowance > 0
        ? (remainingToday / dailyAllowance)
        : 0.0;
    if (fishPct < 0.0) fishPct = 0.0;
    if (fishPct > 1.0) fishPct = 1.0;

    return BudgetCalculationResult(
      monthlyIncome: profile.monthlyIncome,
      totalFixedExpenses: totalFixed,
      savingPercentage: profile.savingPercentage,
      savingAmount: savingAmount,
      monthlyBudget: monthlyBudget,
      spentBeforeToday: spentBeforeToday,
      spentToday: spentToday,
      remainingDays: remainingDays,
      dailyAllowance: dailyAllowance,
      remainingToday: remainingToday < 0 ? 0 : remainingToday,
      fishPercentage: fishPct,
      isOverspent: isOverspent,
      isUnder20Percent: isUnder20Percent,
    );
  }
}
