import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_time_utils.dart';
import '../../models/transaction_item.dart';
import '../../providers/profile_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/cat_provider.dart';
import '../what_if/what_if_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedEmotion;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatWorkDuration(
      double amount, double monthlyIncome, double monthlyHours) {
    if (monthlyHours <= 0 || monthlyIncome <= 0) return '21 phút';
    final hourlyRate = monthlyIncome / monthlyHours;
    final hours = amount / hourlyRate;
    if (hours < 1.0) {
      final mins = (hours * 60).round().clamp(1, 60);
      return '$mins phút';
    } else if (hours < 8.0) {
      return '${hours.toStringAsFixed(1)} giờ';
    } else {
      final days = (hours / 8.0).toStringAsFixed(1);
      return '$days ngày công';
    }
  }

  String _getCategoryEmoji(String categoryId) {
    switch (categoryId) {
      case 'food':
        return '🍜';
      case 'shopping':
        return '🛍️';
      case 'transport':
        return '🛵';
      case 'bills':
        return '⚡';
      case 'entertainment':
        return '🎬';
      default:
        return '✨';
    }
  }

  String _getEmotionDisplay(String? emotion) {
    switch (emotion) {
      case 'happy':
        return '😊 Vui';
      case 'necessary':
        return '👌 Cần thiết';
      case 'impulsive':
        return '⚡ Bốc đồng';
      case 'regret':
        return '😿 Hối hận';
      default:
        return '😊 Vui';
    }
  }

  Color _getEmotionColor(String? emotion) {
    switch (emotion) {
      case 'happy':
        return AppColors.emotionHappy;
      case 'necessary':
        return AppColors.emotionNecessary;
      case 'impulsive':
        return AppColors.emotionImpulsive;
      case 'regret':
        return AppColors.emotionRegret;
      default:
        return AppColors.emotionHappy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final txState = ref.watch(transactionProvider);
    final catCombined = ref.watch(catProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allTxs = txState.allTransactions;

    // Filter
    final filtered = allTxs.where((tx) {
      if (_searchQuery.isNotEmpty) {
        if (!tx.note.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
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

    // Emotion counts
    final int countAll = allTxs.length;
    final int countHappy = allTxs.where((t) => t.emotion == 'happy').length;
    final int countNecessary =
        allTxs.where((t) => t.emotion == 'necessary').length;
    final int countRegret = allTxs.where((t) => t.emotion == 'regret').length;
    final int countImpulsive =
        allTxs.where((t) => t.emotion == 'impulsive').length;

    // Monthly stats
    final now = DateTime.now();
    final thisMonthTxs = allTxs
        .where((t) =>
            t.dateTime.month == now.month && t.dateTime.year == now.year && t.isExpense)
        .toList();
    final monthlyTotal =
        thisMonthTxs.fold<double>(0.0, (sum, t) => sum + t.amount);
    final daysPassed = now.day;
    final dailyAvg = daysPassed > 0 ? monthlyTotal / daysPassed : 0.0;
    final totalWorkHoursSpent = profile.monthlyWorkHours > 0 &&
            profile.monthlyIncome > 0
        ? monthlyTotal / (profile.monthlyIncome / profile.monthlyWorkHours)
        : 70.6;

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
                      '· Sổ Chi Tiêu',
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
                const Text('🐟', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // 1. Search Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Tìm bún bò, grab, shopee, tiền nhà...',
                      hintStyle: TextStyle(fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.cancel, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 2. Emotion Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tất cả', countAll, _selectedEmotion == null, () {
                  setState(() => _selectedEmotion = null);
                }),
                const SizedBox(width: 6),
                _buildFilterChip('😊 Vui', countHappy, _selectedEmotion == 'happy', () {
                  setState(() => _selectedEmotion =
                      _selectedEmotion == 'happy' ? null : 'happy');
                }),
                const SizedBox(width: 6),
                _buildFilterChip('👌 Cần thiết', countNecessary,
                    _selectedEmotion == 'necessary', () {
                  setState(() => _selectedEmotion =
                      _selectedEmotion == 'necessary' ? null : 'necessary');
                }),
                const SizedBox(width: 6),
                _buildFilterChip('😿 Hối hận', countRegret,
                    _selectedEmotion == 'regret', () {
                  setState(() => _selectedEmotion =
                      _selectedEmotion == 'regret' ? null : 'regret');
                }),
                const SizedBox(width: 6),
                _buildFilterChip('⚡ Bốc đồng', countImpulsive,
                    _selectedEmotion == 'impulsive', () {
                  setState(() => _selectedEmotion =
                      _selectedEmotion == 'impulsive' ? null : 'impulsive');
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 3. Monthly Summary Bento Card
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
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Tháng ${now.month} của bạn',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : const Color(0xFFFBEADB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🍂 $daysPassed ngày đã qua',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(monthlyTotal)
                          .replaceAll('đ', '')
                          .trim(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Text(
                      'đ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Tổng đã ghi nhận',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 6),
                    const Text('•',
                        style: TextStyle(fontSize: 10, color: Colors.black26)),
                    const SizedBox(width: 6),
                    Text(
                      'TB: ${CurrencyFormatter.format(dailyAvg)}/ngày',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Work-hour tracker badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : const Color(0xFFF9F4EE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.hourglass_top_rounded,
                                size: 16, color: AppColors.primaryDark),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thời gian làm việc đã tiêu',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary),
                              ),
                              Text(
                                '≈ ${totalWorkHoursSpent.toStringAsFixed(1)} giờ làm việc',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('🐟', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 3),
                            Text(
                              '${catCombined.cat.fishPoints} cá',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                color: AppColors.primaryDark,
                              ),
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
          const SizedBox(height: 14),
          // 4. What-If Simulator Interactive Sticky Bar
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WhatIfScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                      : [const Color(0xFFFFF2E2), const Color(0xFFFFE8D1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_fix_high_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thử nghiệm "Nếu như..."',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Nếu bớt 1 ly trà sữa mỗi tuần sẽ gom được bao nhiêu cá?',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WhatIfScreen()),
                      );
                    },
                    child: const Row(
                      children: [
                        Text('Xem thử',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800)),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          // 5. Grouped Transactions List
          if (grouped.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'Không tìm thấy giao dịch nào phù hợp 🐾',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            ...grouped.entries.map((entry) {
              final dateHeader = entry.key;
              final items = entry.value;
              final dayTotal =
                  items.fold<double>(0.0, (sum, t) => sum + t.amount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dateHeader,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '-${CurrencyFormatter.format(dayTotal)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...items.map((item) {
                    final timeStr = DateFormat('HH:mm').format(item.dateTime);
                    final workText = _formatWorkDuration(
                      item.amount,
                      profile.monthlyIncome,
                      profile.monthlyWorkHours,
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF2E4),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(_getCategoryEmoji(item.categoryId),
                                      style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.note,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      if (profile.showWorkHours) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5EBE1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '≈ $workText',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getEmotionColor(item.emotion)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _getEmotionDisplay(item.emotion),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                _getEmotionColor(item.emotion),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '-${CurrencyFormatter.format(item.amount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                timeStr,
                                style: AppTypography.caption.copyWith(
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, int count, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFFBEADB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
