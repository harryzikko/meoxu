import 'package:flutter_test/flutter_test.dart';
import 'package:meoxu/core/utils/budget_calculator.dart';
import 'package:meoxu/models/user_profile.dart';
import 'package:meoxu/models/fixed_expense.dart';
import 'package:meoxu/models/transaction_item.dart';

void main() {
  group('BudgetCalculator Acceptance Test Suite', () {
    const profile = UserProfile(
      id: 'test_user',
      monthlyIncome: 15000000.0, // 15 triệu
      savingPercentage: 20.0, // Tiết kiệm 20% = 3 triệu
      monthlyWorkHours: 176.0,
    );

    final fixedExpenses = [
      const FixedExpense(
        id: '1',
        name: 'Tiền trọ',
        amount: 3000000.0,
      ), // 3 triệu
      const FixedExpense(
        id: '2',
        name: 'Điện nước + wifi',
        amount: 600000.0,
      ), // 600k
    ];
    // Total fixed: 3.6 triệu
    // Saving: 3.0 triệu
    // Monthly budget = 15.0 - 3.6 - 3.0 = 8.4 triệu (8,400,000 VND)

    test('Beginning of month calculation (Day 1 of 30-day month)', () {
      final day1 = DateTime(2026, 4, 1); // April has 30 days
      final result = BudgetCalculator.calculate(
        profile: profile,
        fixedExpenses: fixedExpenses,
        monthlyTransactions: [],
        currentDate: day1,
      );

      expect(result.monthlyBudget, equals(8400000.0));
      expect(result.remainingDays, equals(30));
      // Daily allowance = 8,400,000 / 30 = 280,000 VND
      expect(result.dailyAllowance, equals(280000.0));
      expect(result.remainingToday, equals(280000.0));
      expect(result.isOverspent, isFalse);
      expect(result.fishPercentage, equals(1.0));
    });

    test('Mid-month spending within limit', () {
      final day15 = DateTime(2026, 4, 15); // 16 days left (30 - 15 + 1)
      final transactions = [
        // Already spent 3,600,000 before today
        TransactionItem(
          id: 't1',
          amount: 3600000.0,
          categoryId: 'food',
          note: 'Ăn uống nửa tháng trước',
          dateTime: DateTime(2026, 4, 10),
        ),
        // Spent 100,000 today
        TransactionItem(
          id: 't2',
          amount: 100000.0,
          categoryId: 'food',
          note: 'Trưa nay',
          dateTime: DateTime(2026, 4, 15, 12, 0),
        ),
      ];

      final result = BudgetCalculator.calculate(
        profile: profile,
        fixedExpenses: fixedExpenses,
        monthlyTransactions: transactions,
        currentDate: day15,
      );

      // Remaining pool = 8,400,000 - 3,600,000 = 4,800,000
      // Daily allowance = 4,800,000 / 16 = 300,000 VND
      expect(result.remainingDays, equals(16));
      expect(result.dailyAllowance, equals(300000.0));
      // Remaining today = 300,000 - 100,000 = 200,000 VND
      expect(result.remainingToday, equals(200000.0));
      expect(result.isOverspent, isFalse);
      expect(result.fishPercentage, closeTo(0.666, 0.01));
    });

    test('Overspending today - displays 0đ and flags overspent', () {
      final day15 = DateTime(2026, 4, 15);
      final transactions = [
        // Spent 400,000 today when daily allowance is 300,000
        TransactionItem(
          id: 't1',
          amount: 3600000.0,
          categoryId: 'food',
          note: 'Nửa tháng trước',
          dateTime: DateTime(2026, 4, 10),
        ),
        TransactionItem(
          id: 't2',
          amount: 400000.0,
          categoryId: 'shopping',
          note: 'Mua áo',
          dateTime: DateTime(2026, 4, 15, 14, 0),
        ),
      ];

      final result = BudgetCalculator.calculate(
        profile: profile,
        fixedExpenses: fixedExpenses,
        monthlyTransactions: transactions,
        currentDate: day15,
      );

      expect(result.dailyAllowance, equals(300000.0));
      expect(result.spentToday, equals(400000.0));
      expect(result.remainingToday, equals(0.0)); // Clamped to 0đ
      expect(result.isOverspent, isTrue);
      expect(result.fishPercentage, equals(0.0));
    });

    test('End of month calculation (Last day of month, 1 day remaining)', () {
      final lastDay = DateTime(2026, 4, 30);
      final result = BudgetCalculator.calculate(
        profile: profile,
        fixedExpenses: fixedExpenses,
        monthlyTransactions: [
          TransactionItem(
            id: 't1',
            amount: 8000000.0,
            categoryId: 'various',
            note: 'Cả tháng',
            dateTime: DateTime(2026, 4, 25),
          ),
        ],
        currentDate: lastDay,
      );

      expect(result.remainingDays, equals(1));
      // Pool = 8,400,000 - 8,000,000 = 400,000 VND
      expect(result.dailyAllowance, equals(400000.0));
      expect(result.remainingToday, equals(400000.0));
    });

    test(
      'Changing saving percentage dynamically updates budget immediately',
      () {
        final updatedProfile = profile.copyWith(
          savingPercentage: 10.0,
        ); // reduced from 20% to 10%
        final day1 = DateTime(2026, 4, 1);

        final result = BudgetCalculator.calculate(
          profile: updatedProfile,
          fixedExpenses: fixedExpenses,
          monthlyTransactions: [],
          currentDate: day1,
        );

        // Saving: 1.5 triệu (instead of 3.0 triệu)
        // Monthly budget = 15.0 - 3.6 - 1.5 = 9.9 triệu
        expect(result.monthlyBudget, equals(9900000.0));
        // Daily allowance = 9,900,000 / 30 = 330,000 VND (increased from 280k)
        expect(result.dailyAllowance, equals(330000.0));
      },
    );
  });
}
