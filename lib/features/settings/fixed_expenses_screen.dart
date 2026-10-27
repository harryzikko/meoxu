import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/fixed_expense.dart';
import '../../providers/fixed_expenses_provider.dart';

class FixedExpensesScreen extends ConsumerStatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  ConsumerState<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends ConsumerState<FixedExpensesScreen> {
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    int day = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Thêm khoản chi cố định'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên khoản chi (ví dụ: Tiền trọ)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số tiền (VNĐ)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: day,
                decoration: const InputDecoration(labelText: 'Ngày thanh toán trong tháng'),
                items: List.generate(31, (i) => i + 1).map((d) {
                  return DropdownMenuItem(value: d, child: Text('Ngày $d hàng tháng'));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => day = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text.replaceAll('.', '').replaceAll(',', ''));
                if (amount != null && nameCtrl.text.trim().isNotEmpty) {
                  final newExp = FixedExpense(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim(),
                    amount: amount,
                    dayOfMonth: day,
                  );
                  ref.read(fixedExpensesProvider.notifier).addFixedExpense(newExp);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fixedList = ref.watch(fixedExpensesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalFixed = fixedList.fold<double>(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khoản chi cố định'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Total banner
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng chi cố định hàng tháng', style: AppTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(totalFixed),
                      style: AppTypography.displayMedium.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const Icon(Icons.shield_outlined, color: AppColors.primaryDark, size: 32),
              ],
            ),
          ),

          Expanded(
            child: fixedList.isEmpty
                ? Center(
                    child: Text('Chưa có khoản cố định nào', style: AppTypography.bodyMedium),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: fixedList.length,
                    itemBuilder: (context, index) {
                      final item = fixedList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.receipt_rounded, color: AppColors.primaryDark),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: AppTypography.titleMedium.copyWith(fontSize: 15)),
                                  Text('Thanh toán ngày ${item.dayOfMonth}', style: AppTypography.caption),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(item.amount),
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                              onPressed: () {
                                ref.read(fixedExpensesProvider.notifier).removeFixedExpense(item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
