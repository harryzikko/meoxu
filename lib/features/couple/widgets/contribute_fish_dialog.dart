import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/couple_provider.dart';

class ContributeFishDialog extends ConsumerStatefulWidget {
  const ContributeFishDialog({super.key});

  @override
  ConsumerState<ContributeFishDialog> createState() =>
      _ContributeFishDialogState();
}

class _ContributeFishDialogState extends ConsumerState<ContributeFishDialog> {
  final TextEditingController _amountCtrl =
      TextEditingController(text: '500.000');
  final TextEditingController _msgCtrl = TextEditingController();
  double _amount = 500000.0;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _setAmount(double val) {
    setState(() {
      _amount = val;
      _amountCtrl.text = CurrencyFormatter.format(val).replaceAll('đ', '').trim();
    });
  }

  void _addAmount(double delta) {
    _setAmount(_amount + delta);
  }

  @override
  Widget build(BuildContext context) {
    final couple = ref.watch(coupleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fishEquivalent = (_amount / 4000).toInt();

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('🐟', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thả thêm cá khô vào hũ chung',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Góp cho: ${couple.activeGoal?.title ?? "Mục tiêu chung"}',
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Amount Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(
                        val.replaceAll('.', '').replaceAll(',', ''),
                      );
                      if (parsed != null) {
                        setState(() => _amount = parsed);
                      }
                    },
                  ),
                ),
                Text(
                  'VNĐ',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick Addition Chips
          Row(
            children: [
              _buildAddChip('+100k', 100000),
              const SizedBox(width: 6),
              _buildAddChip('+200k', 200000),
              const SizedBox(width: 6),
              _buildAddChip('+500k', 500000),
              const SizedBox(width: 6),
              _buildAddChip('+1Tr', 1000000),
            ],
          ),
          const SizedBox(height: 12),

          // Cute Fish Equivalent Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '≈ $fishEquivalent con cá khô thơm phức cho hai bé mèo!',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Love Note Input
          TextField(
            controller: _msgCtrl,
            decoration: const InputDecoration(
              labelText: 'Lời nhắn gửi người thương',
              hintText: 'Ví dụ: Bớt trà sữa tuần này bỏ hũ nè em iu ❤️',
              prefixIcon: Icon(Icons.favorite_border, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(height: 18),

          // Submit Button
          ElevatedButton(
            onPressed: () {
              if (_amount > 0) {
                HapticFeedback.lightImpact();
                ref.read(coupleProvider.notifier).addContribution(
                      amount: _amount,
                      message: _msgCtrl.text,
                      contributorName: couple.profile.userNickname,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã thả ${CurrencyFormatter.format(_amount)} vào ống chung! 🐟🎉',
                    ),
                  ),
                );
              }
            },
            child: const Text('Thả cá vào hũ ngay 🐟'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChip(String label, double val) {
    return Expanded(
      child: InkWell(
        onTap: () => _addAmount(val),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryLight),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
