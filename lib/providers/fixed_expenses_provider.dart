import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fixed_expense.dart';
import '../core/database/app_database.dart';

class FixedExpensesNotifier extends StateNotifier<List<FixedExpense>> {
  FixedExpensesNotifier() : super([]) {
    loadFixedExpenses();
  }

  Future<void> loadFixedExpenses() async {
    try {
      final list = await AppDatabase.instance.getFixedExpenses();
      if (list.isEmpty) {
        // Defaults if empty
        final defaults = [
          const FixedExpense(id: 'fix_1', name: 'Tiền nhà/phòng trọ', amount: 3000000.0, dayOfMonth: 5),
          const FixedExpense(id: 'fix_2', name: 'Điện & Nước', amount: 500000.0, dayOfMonth: 10),
          const FixedExpense(id: 'fix_3', name: 'Wifi & 4G', amount: 220000.0, dayOfMonth: 15),
        ];
        for (final item in defaults) {
          await AppDatabase.instance.insertFixedExpense(item);
        }
        state = defaults;
      } else {
        state = list;
      }
    } catch (_) {}
  }

  Future<void> addFixedExpense(FixedExpense item) async {
    await AppDatabase.instance.insertFixedExpense(item);
    state = [...state, item];
  }

  Future<void> removeFixedExpense(String id) async {
    await AppDatabase.instance.deleteFixedExpense(id);
    state = state.where((e) => e.id != id).toList();
  }
}

final fixedExpensesProvider = StateNotifierProvider<FixedExpensesNotifier, List<FixedExpense>>((ref) {
  return FixedExpensesNotifier();
});
