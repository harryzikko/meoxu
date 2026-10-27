import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/work_hours_converter.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../models/transaction_item.dart';
import '../../../models/category_item.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final double monthlyIncome;
  final double monthlyHours;
  final bool showWorkHours;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.item,
    required this.monthlyIncome,
    this.monthlyHours = 176.0,
    this.showWorkHours = true,
    this.onTap,
  });

  Color _getEmotionColor(String? emotion) {
    switch (emotion) {
      case 'happy':
        return AppColors.emotionHappy;
      case 'necessary':
        return AppColors.emotionNecessary;
      case 'regret':
        return AppColors.emotionRegret;
      case 'impulsive':
        return AppColors.emotionImpulsive;
      default:
        return Colors.transparent;
    }
  }

  String _getEmotionEmoji(String? emotion) {
    switch (emotion) {
      case 'happy':
        return '😊';
      case 'necessary':
        return '👌';
      case 'regret':
        return '😿';
      case 'impulsive':
        return '⚡';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = CategoryItem.getById(item.categoryId);
    final workTimeStr = showWorkHours && item.isExpense
        ? WorkHoursConverter.convertToWorkTime(
            amount: item.amount,
            monthlyIncome: monthlyIncome,
            monthlyWorkHours: monthlyHours,
          )
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(cat.icon, color: cat.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Note, Category Name, and Work Hours
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.note.isEmpty ? cat.name : item.note,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.emotion != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getEmotionColor(item.emotion)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getEmotionEmoji(item.emotion),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        DateTimeUtils.formatTime(item.dateTime),
                        style: AppTypography.caption,
                      ),
                      if (workTimeStr.isNotEmpty) ...[
                        Text(' • ', style: AppTypography.caption),
                        Text(
                          workTimeStr,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${item.isIncome ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: item.isIncome
                    ? AppColors.success
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
