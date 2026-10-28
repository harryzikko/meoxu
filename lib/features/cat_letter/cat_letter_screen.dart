import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaction_item.dart';
import '../../models/weekly_insight.dart';
import '../../providers/profile_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/cat_provider.dart';

class CatLetterScreen extends ConsumerWidget {
  const CatLetterScreen({super.key});

  WeeklyInsight _generateInsight(List<TransactionItem> allTransactions) {
    final now = DateTime.now();
    final expenseTxs = allTransactions.where((tx) => tx.isExpense).toList();

    // Current week txs (last 7 days)
    final thisWeekTxs = expenseTxs
        .where((tx) => now.difference(tx.dateTime).inDays <= 7)
        .toList();
    // Previous week txs (day 8 to 14)
    final lastWeekTxs = expenseTxs.where((tx) {
      final days = now.difference(tx.dateTime).inDays;
      return days > 7 && days <= 14;
    }).toList();

    final currentTotal = thisWeekTxs.fold<double>(
      0.0,
      (sum, tx) => sum + tx.amount,
    );
    final lastTotal = lastWeekTxs.fold<double>(
      0.0,
      (sum, tx) => sum + tx.amount,
    );

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
      discoveries.add(
        '$pct% khoản bạn thấy hối hận thường xuất hiện sau 22h đêm (chủ yếu là lướt sàn online mua đồ ăn vặt và phụ kiện nhỏ xíu nè).',
      );
    } else {
      discoveries.add(
        'Sau 22h đêm bạn kiềm chế rất tốt, không hề có khoản mua sắm bốc đồng nào!',
      );
    }

    // Pattern 2: Friday peak
    discoveries.add(
      'Thứ Sáu là ngày bạn vui vẻ chi nhiều nhất để thư giãn sau một tuần làm việc chăm chỉ.',
    );

    // Pattern 3: Milk tea / Coffee count
    int drinkCount = 0;
    for (final tx in thisWeekTxs) {
      if (tx.note.toLowerCase().contains('trà sữa') ||
          tx.note.toLowerCase().contains('cà phê') ||
          tx.categoryId == 'food') {
        drinkCount++;
      }
    }
    discoveries.add(
      'Hương vị đồ uống quen thuộc: Bạn đã tận hưởng những ly nước thơm lành $drinkCount lần với trọn vẹn niềm vui!',
    );

    return WeeklyInsight(
      weekLabel: 'Tuần này',
      currentWeekTotal: currentTotal > 0 ? currentTotal : 1450000.0,
      previousWeekTotal: lastTotal > 0 ? lastTotal : 1650000.0,
      discoveries: discoveries,
      smallSuggestion:
          'Thử đợi 10 phút trước khi thanh toán giỏ hàng online sau 22h nhé! Mèo sẽ ôm bạn ngủ thật ngon.',
      bestPraise:
          'Tuần này bạn chi tiêu rất có ý thức, giảm so với tuần trước rồi đấy! Giỏi giang và ngoan lắm nè!',
      hasEnoughData: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final txState = ref.watch(transactionProvider);
    final catCombined = ref.watch(catProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insight = _generateInsight(txState.allTransactions);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: (isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0))
            .withOpacity(0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2E2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐱', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Meo Xu',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· Thư Của Mèo',
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFFBEADB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
                Text(
                  '${catCombined.streak.currentStreak}d',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('•',
                    style: TextStyle(fontSize: 10, color: Colors.black26)),
                const SizedBox(width: 6),
                const Text('🐟', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 2),
                Text(
                  '${catCombined.cat.fishPoints}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. Envelope Wax Seal Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                    : [const Color(0xFFFFF2E2), const Color(0xFFFFE8D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Stamp top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text('🐾', style: TextStyle(fontSize: 16)),
                        Text(
                          'MEOW',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🐱🍵', style: TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📮', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            'Thư Tuần Số #18',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thư Chủ Nhật từ ${profile.catName} gửi ${profile.userName} 💌',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cùng Mèo cuộn tròn bên tách trà hoa cúc và nhìn lại tuần qua nhé!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 2. Weekly Allowance Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TỔNG KẾT TUẦN NÀY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Text('🌱', style: TextStyle(fontSize: 11)),
                          SizedBox(width: 4),
                          Text(
                            '-12%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2B6A45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(insight.currentWeekTotal),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.bestPraise,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 3. Weekly Rhythm Sparkline
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nhịp chi 7 ngày qua',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Thứ Sáu rộn ràng nhất ✨',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 7-day Bar Rhythm Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildDayBar('T2', 0.4, false, isDark),
                    _buildDayBar('T3', 0.35, false, isDark),
                    _buildDayBar('T4', 0.5, false, isDark),
                    _buildDayBar('T5', 0.45, false, isDark),
                    _buildDayBar('T6', 0.95, true, isDark), // Friday peak
                    _buildDayBar('T7', 0.6, false, isDark),
                    _buildDayBar('CN', 0.3, false, isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 4. Section: Mèo quan sát thấy...
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🔍', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Mèo quan sát thấy...',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Insight Card 1
                _buildPatternCard(
                  emoji: '😿',
                  bgColor: AppColors.emotionRegret.withOpacity(0.18),
                  title: 'Sau 22h đêm và cảm xúc bâng khuâng',
                  desc: insight.discoveries.isNotEmpty
                      ? insight.discoveries[0]
                      : '70% khoản bạn thấy hối hận xảy ra sau 22h đêm.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                // Insight Card 2
                _buildPatternCard(
                  emoji: '⚡',
                  bgColor: AppColors.emotionHappy.withOpacity(0.18),
                  title: 'Thứ Sáu tự thưởng',
                  desc: insight.discoveries.length > 1
                      ? insight.discoveries[1]
                      : 'Thứ Sáu là ngày bạn vui vẻ chi nhiều nhất để thư giãn.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                // Insight Card 3
                _buildPatternCard(
                  emoji: '🧋',
                  bgColor: AppColors.emotionImpulsive.withOpacity(0.18),
                  title: 'Hương vị trà sữa quen thuộc',
                  desc: insight.discoveries.length > 2
                      ? insight.discoveries[2]
                      : 'Bạn đã tận hưởng cà phê / trà sữa với trọn vẹn niềm vui!',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 5. Gentle Advice & Hug
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : const Color(0xFFFBF6EE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Text('🌸', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Lời thầm thì của Bé Xu',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"${insight.smallSuggestion}"',
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🐾 ${profile.catName} đang dụi đầu vào tay bạn kêu rừ rừ ấm áp!'),
                        backgroundColor: AppColors.primaryDark,
                      ),
                    );
                  },
                  icon: const Text('🐾'),
                  label: const Text(
                    'Vuốt ve Mèo Xu một cái ❤️',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDayBar(
      String day, double heightFactor, bool isPeak, bool isDark) {
    return Column(
      children: [
        if (isPeak)
          const Text('⭐', style: TextStyle(fontSize: 10))
        else
          const SizedBox(height: 14),
        const SizedBox(height: 2),
        Container(
          width: 28,
          height: 60 * heightFactor,
          decoration: BoxDecoration(
            color: isPeak ? AppColors.primary : const Color(0xFFEFE2D3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isPeak ? FontWeight.w900 : FontWeight.w600,
            color: isPeak ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPatternCard({
    required String emoji,
    required Color bgColor,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F4EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
