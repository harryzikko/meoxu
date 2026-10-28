import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/couple_provider.dart';
import 'contribute_fish_dialog.dart';

class ContributionHistorySheet extends ConsumerWidget {
  const ContributionHistorySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider);
    final goal = couple.activeGoal;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final targetAmount = goal?.targetAmount ?? 10000000.0;
    final currentAmount = goal?.currentAmount ?? 6800000.0;
    final progress = goal?.progressPercentage ?? 0.68;
    final userPercentage = goal?.userPercentage ?? 0.35;
    final partnerPercentage = goal?.partnerPercentage ?? 0.33;

    final fishCount = (currentAmount / 4000).toInt();
    final remainingFish = ((targetAmount - currentAmount) / 4000).toInt();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nhật ký tích lũy chung',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          goal?.title ?? 'Mục tiêu chung',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Goal summary card
                Container(
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CurrencyFormatter.format(currentAmount),
                                style: AppTypography.displayLarge.copyWith(
                                  color: AppColors.primaryDark,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '/ ${CurrencyFormatter.format(targetAmount)}',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('🐟', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            'Đã gom $fishCount cá khô (thiếu ~$remainingFish cá nữa)',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Multi-segment progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 14,
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.surfaceVariant,
                          child: Row(
                            children: [
                              Expanded(
                                flex: (userPercentage * 1000).toInt(),
                                child: Container(color: AppColors.primary),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                flex: (partnerPercentage * 1000).toInt(),
                                child: Container(color: const Color(0xFF8EC5FC)),
                              ),
                              Expanded(
                                flex: (((1.0 - progress) * 1000).toInt())
                                    .clamp(0, 1000),
                                child: Container(color: Colors.transparent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
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
                              const SizedBox(width: 4),
                              Text(
                                '${couple.profile.userNickname}: ${CurrencyFormatter.format(goal?.userContribution ?? 3500000)}',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8EC5FC),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${couple.profile.partnerName}: ${CurrencyFormatter.format(goal?.partnerContribution ?? 3300000)}',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const ContributeFishDialog(),
                          );
                        },
                        icon: const Icon(Icons.savings_outlined, size: 20),
                        label: const Text(
                          'Thả thêm cá +',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          ref.read(coupleProvider.notifier).sendHeart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('💌 Đã gửi xoa đầu và 1 cá thơm tới bạn đồng hành!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Text('💌'),
                        label: Text(
                          'Gửi cá thơm',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Milestone Journey Timeline
                Container(
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.between,
                        children: [
                          Row(
                            children: [
                              const Text('🗺️', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                'Hành trình cột mốc',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: progress >= 0.5
                                  ? AppColors.emotionHappy.withOpacity(0.2)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              progress >= 1.0
                                  ? '4/4 chặng'
                                  : progress >= 0.75
                                      ? '3/4 chặng'
                                      : progress >= 0.5
                                          ? '2/4 chặng'
                                          : '1/4 chặng',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: progress >= 0.5
                                    ? const Color(0xFF2B6A45)
                                    : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMilestoneItem(
                        icon: '🚌',
                        title: '25% • Vé xe giường đôi',
                        subtitle: '2.500.000đ • Đã hoàn thành',
                        isReached: progress >= 0.25,
                        isCurrent: progress < 0.5 && progress >= 0.25,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildMilestoneItem(
                        icon: '🏡',
                        title: '50% • Homestay view thông reo',
                        subtitle: '5.000.000đ • Đã hoàn thành',
                        isReached: progress >= 0.50,
                        isCurrent: progress < 0.75 && progress >= 0.50,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildMilestoneItem(
                        icon: '🍢',
                        title: '75% • Tiệc BBQ & Lẩu ấm bụng',
                        subtitle: '7.500.000đ • Sắp tới rồi!',
                        isReached: progress >= 0.75,
                        isCurrent: progress < 1.0 && progress >= 0.50,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildMilestoneItem(
                        icon: '🎉',
                        title: '100% • Vali đầy ắp cá & Đi thôi!',
                        subtitle: '10.000.000đ • Cán đích trọn vẹn',
                        isReached: progress >= 1.0,
                        isCurrent: false,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Contribution Feed List
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Row(
                      children: [
                        const Text('📜', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          'Chi tiết các lần góp',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${couple.contributions.length} lượt',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (couple.contributions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Chưa có khoản góp nào. Hãy là người đầu tiên thả cá khô! 🐟',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...couple.contributions.map((item) {
                    final isUser =
                        item.contributorName == couple.profile.userNickname;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isUser
                              ? AppColors.primary.withOpacity(0.3)
                              : const Color(0xFF8EC5FC).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.primary.withOpacity(0.18)
                                  : const Color(0xFF8EC5FC).withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(isUser ? '🐱' : '😸',
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.between,
                                  children: [
                                    Text(
                                      item.contributorName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '+${CurrencyFormatter.format(item.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: isUser
                                            ? AppColors.primaryDark
                                            : const Color(0xFF246293),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.message,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(item.dateTime),
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem({
    required String icon,
    required String title,
    required String subtitle,
    required bool isReached,
    required bool isCurrent,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isReached
            ? (isDark
                ? AppColors.emotionHappy.withOpacity(0.12)
                : const Color(0xFFE8F8F0))
            : (isCurrent
                ? (isDark
                    ? AppColors.primary.withOpacity(0.15)
                    : const Color(0xFFFFF4EA))
                : (isDark
                    ? AppColors.darkSurfaceVariant
                    : const Color(0xFFF9F6F0))),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReached
              ? AppColors.emotionHappy.withOpacity(0.5)
              : (isCurrent
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.transparent),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isReached
                  ? AppColors.emotionHappy
                  : (isCurrent
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : Colors.black12)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isReached
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(icon, style: const TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Đang tới',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
