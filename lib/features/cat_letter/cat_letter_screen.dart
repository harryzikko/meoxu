import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaction_item.dart';
import '../../models/weekly_insight.dart';
import '../../providers/profile_provider.dart';
import '../../providers/transaction_provider.dart';

class CatLetterScreen extends ConsumerWidget {
  const CatLetterScreen({super.key});

  WeeklyInsight _generateInsight(List<TransactionItem> allTransactions) {
    final now = DateTime.now();
    final expenseTxs = allTransactions.where((tx) => tx.isExpense).toList();

    // Current week txs (last 7 days)
    final thisWeekTxs = expenseTxs.where((tx) => now.difference(tx.dateTime).inDays <= 7).toList();
    // Previous week txs (day 8 to 14)
    final lastWeekTxs = expenseTxs.where((tx) {
      final days = now.difference(tx.dateTime).inDays;
      return days > 7 && days <= 14;
    }).toList();

    final currentTotal = thisWeekTxs.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    final lastTotal = lastWeekTxs.fold<double>(0.0, (sum, tx) => sum + tx.amount);

    if (thisWeekTxs.length < 5) {
      return WeeklyInsight(
        weekLabel: 'Tuần này',
        currentWeekTotal: currentTotal,
        previousWeekTotal: lastTotal,
        hasEnoughData: false,
        smallSuggestion: 'Cứ thong thả nhé! Ghi thêm vài giao dịch nữa để mèo tìm ra thói quen thú vị của bạn nha.',
        bestPraise: 'Bạn đã bắt đầu hành trình hiểu bản thân cùng Mèo Xu rồi đấy!',
      );
    }

    final List<String> discoveries = [];

    // Pattern 1: Late night regret (after 22h)
    int lateNightRegret = 0;
    int totalRegret = 0;
    for (final tx in thisWeekTxs) {
      if (tx.emotion == 'regret') {
        totalRegret++;
        if (tx.dateTime.hour >= 22 || tx.dateTime.hour < 5) {
          lateNightRegret++;
        }
      }
    }
    if (totalRegret > 0 && lateNightRegret > 0) {
      final pct = ((lateNightRegret / totalRegret) * 100).toInt();
      discoveries.add('$pct% khoản bạn thấy hối hận thường xuất hiện sau 22h đêm.');
    }

    // Pattern 2: Highest spending weekday
    final Map<int, double> dayTotals = {};
    for (final tx in thisWeekTxs) {
      dayTotals[tx.dateTime.weekday] = (dayTotals[tx.dateTime.weekday] ?? 0.0) + tx.amount;
    }
    if (dayTotals.isNotEmpty) {
      final topDay = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final weekdayName = _getWeekdayName(topDay.key);
      discoveries.add('$weekdayName là ngày bạn chi tiêu nhiều nhất trong tuần.');
    }

    // Pattern 3: Food or beverage joy
    int milkTeaCount = 0;
    int happyCount = 0;
    for (final tx in thisWeekTxs) {
      if (tx.note.toLowerCase().contains('trà sữa') || tx.note.toLowerCase().contains('cà phê')) {
        milkTeaCount++;
        if (tx.emotion == 'happy') happyCount++;
      }
    }
    if (milkTeaCount >= 2) {
      discoveries.add('Bạn đã thưởng thức cà phê / trà sữa $milkTeaCount lần, trong đó $happyCount lần mang lại niềm vui trọn vẹn.');
    }

    if (discoveries.isEmpty) {
      discoveries.add('Chi tiêu tuần này của bạn diễn ra rất cân bằng và ổn định!');
    }

    return WeeklyInsight(
      weekLabel: 'Tuần này',
      currentWeekTotal: currentTotal,
      previousWeekTotal: lastTotal,
      discoveries: discoveries,
      smallSuggestion: 'Thử đợi 10 phút trước khi thanh toán giỏ hàng online sau 22h nhé!',
      bestPraise: 'Bạn luôn dành sự quan tâm và kiên nhẫn chăm sóc cho túi tiền của mình!',
      hasEnoughData: true,
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ Hai';
      case 2:
        return 'Thứ Ba';
      case 3:
        return 'Thứ Tư';
      case 4:
        return 'Thứ Năm';
      case 5:
        return 'Thứ Sáu';
      case 6:
        return 'Thứ Bảy';
      case 7:
        return 'Chủ Nhật';
      default:
        return 'Ngày trong tuần';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final txState = ref.watch(transactionProvider);
    final insight = _generateInsight(txState.allTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư của Mèo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Letter Paper Envelope Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stamp & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gửi ${profile.userName},',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Từ chú mèo ${profile.catName} đáng yêu 🐾',
                            style: AppTypography.caption.copyWith(color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                      // Cute Cat Stamp
                      Container(
                        width: 50,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: const Center(
                          child: Text('🐱', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // 1. Total overview
                  Text(
                    '1. Nhìn lại một tuần qua',
                    style: AppTypography.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tổng chi tuần này: ${CurrencyFormatter.format(insight.currentWeekTotal)}'
                    '${insight.previousWeekTotal > 0 ? ' (so với tuần trước: ${CurrencyFormatter.format(insight.previousWeekTotal)})' : ''}.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // 2. Discoveries
                  Text(
                    '2. Mèo phát hiện được điều này:',
                    style: AppTypography.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (!insight.hasEnoughData)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Tuần này mình chưa đủ 10 dữ liệu, cứ thong thả nhé! Mèo vẫn luôn ở đây quan sát và học cùng bạn.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    )
                  else
                    ...insight.discoveries.map((disc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✨ ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                disc,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 20),

                  // 3. Small Suggestion
                  Text(
                    '3. Một việc nhỏ tuần tới',
                    style: AppTypography.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.emotionNecessary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.emotionNecessary.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: AppColors.textPrimary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            insight.smallSuggestion,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Best Praise
                  Text(
                    '4. Lời khen dành tặng bạn',
                    style: AppTypography.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.emotionHappy.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.emotionHappy.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💖', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            insight.bestPraise,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Signature
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Ký tên,',
                          style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
                        ),
                        Text(
                          '🐾 ${profile.catName}',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
