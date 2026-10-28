import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/couple_provider.dart';

class DisburseFundDialog extends ConsumerStatefulWidget {
  const DisburseFundDialog({super.key});

  @override
  ConsumerState<DisburseFundDialog> createState() => _DisburseFundDialogState();
}

class _DisburseFundDialogState extends ConsumerState<DisburseFundDialog> {
  String _selectedMethod = 'travel_ledger'; // 'travel_ledger' or 'split_bank'

  @override
  Widget build(BuildContext context) {
    final couple = ref.watch(coupleProvider);
    final goal = couple.activeGoal;
    final totalAmount = goal?.currentAmount ?? 10000000.0;
    final fishCount = (totalAmount / 4000).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
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
          const SizedBox(height: 12),
          // Top Joyful Badge Pill
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'SẴN SÀNG KHỞI HÀNH • MỞ VALI DU LỊCH 🧳',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            'Mở Vali Xuất Quỹ: ${CurrencyFormatter.format(totalAmount)}',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$fishCount chú cá béo múp đã sẵn sàng hóa thành ngân sách ăn chơi ${goal?.title ?? "Đà Lạt"} của hai bạn meo!',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Celebration Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                    : [const Color(0xFFFFF2E2), const Color(0xFFFFE8D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🧳', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.emotionHappy, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Cán đích 100% xuất sắc!',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Cả hai đã cùng gom cá bền bỉ suốt 45 ngày qua 🐾',
                        style: AppTypography.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Options
          const Text(
            'Chọn cách xuất quỹ:',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          // Option 1
          InkWell(
            onTap: () => setState(() => _selectedMethod = 'travel_ledger'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _selectedMethod == 'travel_ledger'
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: _selectedMethod == 'travel_ledger' ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<String>(
                    value: 'travel_ledger',
                    groupValue: _selectedMethod,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _selectedMethod = v!),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Tạo Sổ Chuyến Đi Riêng Biệt',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Khuyên dùng',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chuyển thẳng vào sổ riêng để hai bạn cùng ghi chép ăn uống thả ga mà không đụng vào đĩa cá sinh hoạt thường ngày!',
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Option 2
          InkWell(
            onTap: () => setState(() => _selectedMethod = 'split_bank'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _selectedMethod == 'split_bank'
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: _selectedMethod == 'split_bank' ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<String>(
                    value: 'split_bank',
                    groupValue: _selectedMethod,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _selectedMethod = v!),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chia đôi 50:50 về tài khoản riêng',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mỗi người nhận lại ${CurrencyFormatter.format(totalAmount / 2)} về tài khoản ngân hàng cá nhân.',
                          style: AppTypography.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Confirm Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              await ref
                  .read(coupleProvider.notifier)
                  .disburseGoal(_selectedMethod);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        '🧳🎉 Đã mở vali xuất quỹ thành công! Chúc hai bạn có chuyến đi thật ngọt ngào!'),
                    backgroundColor: AppColors.primaryDark,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text(
              'Xác Nhận Xuất Quỹ & Lên Đường 🚀',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
