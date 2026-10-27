import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/budget_calculator.dart';

class FishPlateCard extends StatelessWidget {
  final BudgetCalculationResult budget;
  final ValueChanged<double>? onSavingChanged;

  const FishPlateCard({
    super.key,
    required this.budget,
    this.onSavingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fishCount = (budget.fishPercentage * 5).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.parse(
          isDark
              ? '1px solid ${AppColors.darkBorder.value.toRadixString(16)}'
              : '1px solid ${AppColors.border.value.toRadixString(16)}',
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wb_sunny_rounded, size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Text(
                'Hôm nay thoải mái tiêu',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Big Main Number
          FittedBox(
            child: Text(
              CurrencyFormatter.format(budget.remainingToday),
              style: AppTypography.displayLarge.copyWith(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: budget.isOverspent
                    ? AppColors.danger
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dried Fish Plate Visualization (Đĩa cá khô)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Đĩa cá khô: ',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                ...List.generate(5, (index) {
                  final hasFish = index < fishCount;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      hasFish ? '🐟' : '🦴',
                      style: TextStyle(
                        fontSize: 18,
                        color: hasFish ? AppColors.fishGold : Colors.grey,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${(budget.fishPercentage * 100).toInt()}%',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          if (budget.isOverspent) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.emotionImpulsive.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Mèo đã tự cân bằng lại cá cho các ngày sau rồi nhé! Thong thả nha~',
                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Saving Goal Quick Slider
          Row(
            children: [
              Text(
                'Mục tiêu tiết kiệm:',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${budget.savingPercentage.toInt()}% (${CurrencyFormatter.formatCompact(budget.savingAmount)})',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.border,
              thumbColor: AppColors.primaryDark,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: budget.savingPercentage.clamp(0.0, 50.0),
              min: 0.0,
              max: 50.0,
              divisions: 10,
              onChanged: onSavingChanged,
            ),
          ),
        ],
      ),
    );
  }
}
