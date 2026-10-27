import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/budget_calculator.dart';
import 'profile_provider.dart';
import 'fixed_expenses_provider.dart';
import 'transaction_provider.dart';

final budgetCalculationProvider = Provider<BudgetCalculationResult>((ref) {
  final profile = ref.watch(profileProvider);
  final fixedExpenses = ref.watch(fixedExpensesProvider);
  final txState = ref.watch(transactionProvider);

  return BudgetCalculator.calculate(
    profile: profile,
    fixedExpenses: fixedExpenses,
    monthlyTransactions: txState.allTransactions,
  );
});
