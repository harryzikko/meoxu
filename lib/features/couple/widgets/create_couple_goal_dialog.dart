import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/couple_provider.dart';
import '../../../providers/profile_provider.dart';

class CreateCoupleGoalDialog extends ConsumerStatefulWidget {
  const CreateCoupleGoalDialog({super.key});

  @override
  ConsumerState<CreateCoupleGoalDialog> createState() =>
      _CreateCoupleGoalDialogState();
}

class _CreateCoupleGoalDialogState
    extends ConsumerState<CreateCoupleGoalDialog> {
  final TextEditingController _titleCtrl = TextEditingController(
      text: 'Chuyến đi ngắm hoa Dã Quỳ Đà Lạt 🌸🏕️');
  final TextEditingController _amountCtrl =
      TextEditingController(text: '10.000.000');
  final TextEditingController _initDepositCtrl =
      TextEditingController(text: '500.000');

  double _targetAmount = 10000000.0;
  double _initDeposit = 500000.0;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 45));
  String _rhythm = 'weekly'; // weekly, daily, flexible
  int _splitPercentUser = 50; // 50, 60, etc.

  final List<Map<String, dynamic>> _presets = [
    {
      'title': 'Chuyến trốn phố Đà Lạt 🏕️🌲',
      'amount': 10000000.0,
      'label': '🏕️ Trốn phố Đà Lạt',
    },
    {
      'title': 'Xe xinh chung đôi vi vu 🛵💨',
      'amount': 25000000.0,
      'label': '🛵 Xe xinh chung đôi',
    },
    {
      'title': 'Tổ ấm nhỏ tương lai 🏠🛋️',
      'amount': 50000000.0,
      'label': '🏠 Tổ ấm nhỏ',
    },
    {
      'title': 'Đêm nhạc thần tượng bùng nổ 🎸🎤',
      'amount': 6000000.0,
      'label': '🎸 Concert',
    },
    {
      'title': 'Kỷ niệm ngày yêu nhau 💍💐',
      'amount': 8000000.0,
      'label': '💍 Kỷ niệm năm',
    },
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _initDepositCtrl.dispose();
    super.dispose();
  }

  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _titleCtrl.text = preset['title'] as String;
      _targetAmount = preset['amount'] as double;
      _amountCtrl.text = CurrencyFormatter.format(_targetAmount)
          .replaceAll('đ', '')
          .trim();
    });
  }

  void _setAmount(double val) {
    setState(() {
      _targetAmount = val;
      _amountCtrl.text =
          CurrencyFormatter.format(val).replaceAll('đ', '').trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final couple = ref.watch(coupleProvider);
    final profile = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hourlyRate = profile.monthlyWorkHours > 0
        ? profile.monthlyIncome / profile.monthlyWorkHours
        : 68000.0;
    final fishEquivalent = (_targetAmount / 4000).toInt();
    final workHoursEquivalent =
        hourlyRate > 0 ? (_targetAmount / hourlyRate).toStringAsFixed(0) : '146';

    final daysRemaining = _targetDate.difference(DateTime.now()).inDays.clamp(1, 999);

    final userGoalShare = _targetAmount * (_splitPercentUser / 100);
    final partnerGoalShare = _targetAmount * ((100 - _splitPercentUser) / 100);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🍯', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Tạo Ống Tiết Kiệm Chung',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
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
          // Form Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Preset Goal Chips
                const Text(
                  'Chọn nhanh chủ đề yêu thích:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _presets.map((preset) {
                      final isSelected = _targetAmount == preset['amount'] &&
                          _titleCtrl.text == preset['title'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(preset['label'] as String),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white : AppColors.textPrimary),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          onSelected: (_) => _selectPreset(preset),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                // Section 1: Goal details card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Chi tiết dự định',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tên mục tiêu chung',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('🌸', style: TextStyle(fontSize: 18)),
                          ),
                          hintText: 'Ví dụ: Trốn phố ngắm hoa Đà Lạt...',
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : const Color(0xFFF9F4EE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Số tiền cần tích lũy cả hai (VNĐ)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final clean =
                              val.replaceAll(RegExp(r'[^0-9]'), '');
                          final parsed = double.tryParse(clean);
                          if (parsed != null) {
                            setState(() => _targetAmount = parsed);
                          }
                        },
                        decoration: InputDecoration(
                          suffixText: 'đ',
                          suffixStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.primaryDark,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : const Color(0xFFF9F4EE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Quick Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickAmountBtn('3 Triệu', 3000000),
                          _buildQuickAmountBtn('5 Triệu', 5000000),
                          _buildQuickAmountBtn('10 Triệu', 10000000),
                          _buildQuickAmountBtn('20 Triệu', 20000000),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Mascot reflection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Text('🐟', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '≈ $fishEquivalent con cá khô 🐟 hoặc $workHoursEquivalent giờ làm việc chung',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Section 2: Target date & pace
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. Thời hạn & Nhịp gom cá',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _targetDate,
                            firstDate: DateTime.now().add(const Duration(days: 1)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 730)),
                          );
                          if (picked != null) {
                            setState(() => _targetDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                                  const Icon(Icons.event_outlined,
                                      color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_targetDate),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Còn $daysRemaining ngày',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tần suất đóng góp thoải mái nhất:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<String>(
                        title: const Text('Hàng tuần (Cuối tuần gộp cá)',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: const Text('Mỗi tối Chủ Nhật hai đứa cùng chốt sổ thảnh thơi',
                            style: TextStyle(fontSize: 11)),
                        value: 'weekly',
                        groupValue: _rhythm,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _rhythm = v!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Hàng ngày (Góp theo đĩa cá dư)',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: const Text('Mỗi ngày trích một phần nhỏ khi đi ngủ',
                            style: TextStyle(fontSize: 11)),
                        value: 'daily',
                        groupValue: _rhythm,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _rhythm = v!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Linh hoạt tự do',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: const Text('Bao giờ có thưởng hoặc tiền dư thì thả vào',
                            style: TextStyle(fontSize: 11)),
                        value: 'flexible',
                        groupValue: _rhythm,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _rhythm = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Section 3: Split share
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3. Phân chia đóng góp yêu thương',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSplitBtn('50% - 50%', 50),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSplitBtn('60% - 40%', 60),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSplitBtn('70% - 30%', 70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Text('🐱', style: TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(
                                    couple.profile.userNickname,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Góp $_splitPercentUser%',
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.primaryDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(userGoalShare),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8EC5FC).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Text('😸', style: TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(
                                    couple.profile.partnerName,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Góp ${100 - _splitPercentUser}%',
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF246293)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(partnerGoalShare),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Color(0xFF246293),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Tiền khởi đầu bỏ vào hũ ngay hôm nay (VNĐ):',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _initDepositCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                          final parsed = double.tryParse(clean);
                          if (parsed != null) {
                            setState(() => _initDeposit = parsed);
                          }
                        },
                        decoration: InputDecoration(
                          suffixText: 'đ',
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : const Color(0xFFF9F4EE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Create Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final title = _titleCtrl.text.trim().isEmpty
                        ? 'Chuyến trốn phố Đà Lạt 🌲'
                        : _titleCtrl.text.trim();

                    await ref.read(coupleProvider.notifier).createNewGoal(
                          title: title,
                          targetAmount: _targetAmount,
                          targetDate: _targetDate,
                          initialContribution: _initDeposit,
                        );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 Đã khởi động mục tiêu: $title!'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Bắt Đầu Tích Lũy Cùng Nhau 🐾',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountBtn(String label, double val) {
    final isSelected = _targetAmount == val;
    return InkWell(
      onTap: () => _setAmount(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFEFE2D3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSplitBtn(String label, int percent) {
    final isSelected = _splitPercentUser == percent;
    return InkWell(
      onTap: () => setState(() => _splitPercentUser = percent),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
