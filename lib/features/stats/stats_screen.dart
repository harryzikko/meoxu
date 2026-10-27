import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/category_item.dart';
import '../../models/transaction_item.dart';
import '../../providers/transaction_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _selectedTab = 0; // 0: Tuần này, 1: Tháng này

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final expenseTxs = txState.allTransactions
        .where((tx) => tx.isExpense)
        .toList();

    // Filter by week or month
    final activeTxs = expenseTxs.where((tx) {
      if (_selectedTab == 0) {
        // Last 7 days
        return now.difference(tx.dateTime).inDays <= 7;
      } else {
        // This month
        return tx.dateTime.year == now.year && tx.dateTime.month == now.month;
      }
    }).toList();

    final totalSpent = activeTxs.fold<double>(
      0.0,
      (sum, tx) => sum + tx.amount,
    );

    // Calculate emotion counts
    int happyCount = 0;
    int necessaryCount = 0;
    int regretCount = 0;
    int impulsiveCount = 0;
    for (final tx in activeTxs) {
      if (tx.emotion == 'happy') happyCount++;
      if (tx.emotion == 'necessary') necessaryCount++;
      if (tx.emotion == 'regret') regretCount++;
      if (tx.emotion == 'impulsive') impulsiveCount++;
    }
    final totalWithEmotion =
        happyCount + necessaryCount + regretCount + impulsiveCount;

    // Top 5 highest expenses
    final topExpenses = List<TransactionItem>.from(activeTxs)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = topExpenses.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê & Thấu hiểu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab Toggle (Tuần / Tháng)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('7 ngày qua', _selectedTab == 0, () {
                      setState(() => _selectedTab = 0);
                    }),
                  ),
                  Expanded(
                    child: _buildTabButton('Tháng này', _selectedTab == 1, () {
                      setState(() => _selectedTab = 1);
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Tổng chi tiêu',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(totalSpent),
                    style: AppTypography.displayLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activeTxs.length} giao dịch được ghi lại',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Simple Clean Daily Bar Chart (Mục 6: Không dùng biểu đồ tròn rối mắt)
            Text('Biểu đồ chi tiêu', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            Container(
              height: 160,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: _buildSimpleBarChart(activeTxs, isDark),
            ),
            const SizedBox(height: 28),

            // Emotion Distribution Bars (Section 4.2 & 6)
            Text('Cảm xúc sau khi chi', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _buildEmotionBar(
                    'Vui vẻ',
                    '😊',
                    happyCount,
                    totalWithEmotion,
                    AppColors.emotionHappy,
                  ),
                  const SizedBox(height: 10),
                  _buildEmotionBar(
                    'Cần thiết',
                    '👌',
                    necessaryCount,
                    totalWithEmotion,
                    AppColors.emotionNecessary,
                  ),
                  const SizedBox(height: 10),
                  _buildEmotionBar(
                    'Hối hận',
                    '😿',
                    regretCount,
                    totalWithEmotion,
                    AppColors.emotionRegret,
                  ),
                  const SizedBox(height: 10),
                  _buildEmotionBar(
                    'Bốc đồng',
                    '⚡',
                    impulsiveCount,
                    totalWithEmotion,
                    AppColors.emotionImpulsive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Top 5 Expenses
            Text('Top 5 khoản chi lớn nhất', style: AppTypography.titleMedium),
            const SizedBox(height: 12),
            if (top5.isEmpty)
              Text(
                'Chưa có dữ liệu chi tiêu',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              )
            else
              ...top5.map((tx) {
                final cat = CategoryItem.getById(tx.categoryId);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.icon, color: cat.color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tx.note.isEmpty ? cat.name : tx.note,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(tx.amount),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart(List<TransactionItem> txs, bool isDark) {
    // Group last 7 days
    final now = DateTime.now();
    final List<double> dailyTotals = List.filled(7, 0.0);
    final List<String> dayLabels = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dayLabels.add('${date.day}/${date.month}');
      for (final tx in txs) {
        if (tx.dateTime.year == date.year &&
            tx.dateTime.month == date.month &&
            tx.dateTime.day == date.day) {
          dailyTotals[6 - i] += tx.amount;
        }
      }
    }

    final maxVal = dailyTotals.reduce(math.max);
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (idx) {
        final pct = (dailyTotals[idx] / safeMax).clamp(0.08, 1.0);
        final height = pct * 90;
        final isToday = idx == 6;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 22,
              height: height,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primaryDark : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dayLabels[idx],
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: isToday ? AppColors.primaryDark : AppColors.textTertiary,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmotionBar(
    String label,
    String emoji,
    int count,
    int total,
    Color barColor,
  ) {
    final pct = total > 0 ? (count / total) : 0.0;

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: AppColors.border.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            '${(pct * 100).toInt()}%',
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
