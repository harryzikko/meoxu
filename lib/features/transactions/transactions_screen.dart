import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_time_utils.dart';
import '../../models/transaction_item.dart';
import '../../models/category_item.dart';
import '../../providers/profile_provider.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedEmotion;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final txState = ref.watch(transactionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter transactions
    final filtered = txState.allTransactions.where((tx) {
      if (_searchQuery.isNotEmpty) {
        if (!tx.note.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (_selectedCategory != null && tx.categoryId != _selectedCategory) {
        return false;
      }
      if (_selectedEmotion != null && tx.emotion != _selectedEmotion) {
        return false;
      }
      return true;
    }).toList();

    // Group by Date
    final Map<String, List<TransactionItem>> grouped = {};
    for (final tx in filtered) {
      final key = DateTimeUtils.formatHeader(tx.dateTime);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử giao dịch')),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo ghi chú...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category & Emotion Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All Filter
                      FilterChip(
                        label: const Text('Tất cả'),
                        selected:
                            _selectedCategory == null &&
                            _selectedEmotion == null,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = null;
                            _selectedEmotion = null;
                          });
                        },
                      ),
                      const SizedBox(width: 6),

                      // Category Filters
                      ...CategoryItem.defaultCategories.map((c) {
                        final isSel = _selectedCategory == c.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(c.name),
                            selected: isSel,
                            onSelected: (val) {
                              setState(() {
                                _selectedCategory = val ? c.id : null;
                              });
                            },
                          ),
                        );
                      }),

                      // Emotion Filters
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('😊 Vui'),
                        selected: _selectedEmotion == 'happy',
                        onSelected: (val) => setState(
                          () => _selectedEmotion = val ? 'happy' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('👌 Cần'),
                        selected: _selectedEmotion == 'necessary',
                        onSelected: (val) => setState(
                          () => _selectedEmotion = val ? 'necessary' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('😿 Hối hận'),
                        selected: _selectedEmotion == 'regret',
                        onSelected: (val) => setState(
                          () => _selectedEmotion = val ? 'regret' : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: const Text('⚡ Bốc đồng'),
                        selected: _selectedEmotion == 'impulsive',
                        onSelected: (val) => setState(
                          () => _selectedEmotion = val ? 'impulsive' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy giao dịch nào',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final header = grouped.keys.elementAt(index);
                      final items = grouped[header]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 14,
                              bottom: 6,
                              left: 4,
                            ),
                            child: Text(
                              header,
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          ...items.map((item) {
                            return Dismissible(
                              key: Key(item.id),
                              background: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              secondaryBackground: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  // Delete with undo
                                  await ref
                                      .read(transactionProvider.notifier)
                                      .deleteTransaction(item.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đã xóa "${item.note}"'),
                                        duration: const Duration(seconds: 5),
                                        action: SnackBarAction(
                                          label: 'Hoàn tác',
                                          textColor: AppColors.primary,
                                          onPressed: () {
                                            ref
                                                .read(
                                                  transactionProvider.notifier,
                                                )
                                                .undoDelete();
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                  return true;
                                } else {
                                  // Edit
                                  _showEditDialog(item);
                                  return false;
                                }
                              },
                              child: TransactionTile(
                                item: item,
                                monthlyIncome: profile.monthlyIncome,
                                monthlyHours: profile.monthlyWorkHours,
                                showWorkHours: profile.showWorkHours,
                                onTap: () => _showEditDialog(item),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(TransactionItem item) {
    final noteCtrl = TextEditingController(text: item.note);
    final amountCtrl = TextEditingController(
      text: item.amount.toStringAsFixed(0),
    );
    String catId = item.categoryId;
    String? emotion = item.emotion;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Chỉnh sửa giao dịch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tiền (VNĐ)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: catId,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: CategoryItem.defaultCategories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => catId = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text) ?? item.amount;
                final updated = item.copyWith(
                  amount: amount,
                  note: noteCtrl.text.trim(),
                  categoryId: catId,
                  emotion: emotion,
                );
                await ref
                    .read(transactionProvider.notifier)
                    .updateTransaction(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}
