import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/profile_provider.dart';

class WorkHoursScreen extends ConsumerStatefulWidget {
  const WorkHoursScreen({super.key});

  @override
  ConsumerState<WorkHoursScreen> createState() => _WorkHoursScreenState();
}

class _WorkHoursScreenState extends ConsumerState<WorkHoursScreen> {
  late TextEditingController _incomeCtrl;
  late double _monthlyIncome;
  late double _workDaysPerWeek;
  late double _hoursPerDay;
  late bool _showWorkHours;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _monthlyIncome = profile.monthlyIncome > 0 ? profile.monthlyIncome : 12000000.0;
    _incomeCtrl = TextEditingController(
      text: CurrencyFormatter.format(_monthlyIncome).replaceAll('đ', '').trim(),
    );
    _hoursPerDay = 8.0;
    _workDaysPerWeek = 5.0; // 22 công/tháng
    _showWorkHours = profile.showWorkHours;
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  double get _workingDaysPerMonth {
    if (_workDaysPerWeek <= 5.0) return 22.0;
    if (_workDaysPerWeek <= 5.5) return 24.0;
    return 26.0;
  }

  double get _totalMonthlyHours => _hoursPerDay * _workingDaysPerMonth;

  double get _hourlyRate {
    if (_totalMonthlyHours <= 0) return 68180.0;
    return _monthlyIncome / _totalMonthlyHours;
  }

  String _formatWorkDuration(double amount) {
    if (_hourlyRate <= 0) return '0 phút';
    final hours = amount / _hourlyRate;
    if (hours < 1.0) {
      final mins = (hours * 60).round().clamp(1, 60);
      return '$mins phút';
    } else if (hours < 8.0) {
      return '${hours.toStringAsFixed(1)} giờ';
    } else {
      final days = (hours / _hoursPerDay).toStringAsFixed(1);
      return '$days ngày công';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: (isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0))
            .withOpacity(0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quy Đổi Giờ Làm Việc',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Block 1: Master Toggle Card
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
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.schedule_rounded,
                              color: AppColors.primaryDark),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Quy đổi Giờ làm việc',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Độc bản',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Hiểu giá trị mồ hôi công sức',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _showWorkHours,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _showWorkHours = v),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : const Color(0xFFF9F4EE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                        fontFamily: 'Nunito',
                      ),
                      children: const [
                        TextSpan(
                          text:
                              'Thay vì chỉ nhìn thấy con số 45.000đ vô tri, Meo Xu sẽ thì thầm: ',
                        ),
                        TextSpan(
                          text: '"≈ 40 phút làm việc chăm chỉ" ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        TextSpan(
                          text:
                              'giúp bạn tạm dừng suy ngẫm trước mỗi lần chạm thẻ quẹt ví.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Block 2: Income & Working Rhythm Setup
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
                const Text(
                  'Thiết lập thu nhập & thời gian',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Thu nhập thực nhận mỗi tháng (VNĐ):',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _incomeCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                    final parsed = double.tryParse(clean);
                    if (parsed != null) {
                      setState(() => _monthlyIncome = parsed);
                    }
                  },
                  decoration: InputDecoration(
                    suffixText: 'đ/tháng',
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
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Số ngày làm việc mỗi tuần:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRhythmChip('5 ngày (Nghỉ T7, CN)', 5.0, _workDaysPerWeek == 5.0, () {
                      setState(() => _workDaysPerWeek = 5.0);
                    }),
                    const SizedBox(width: 8),
                    _buildRhythmChip('5.5 ngày', 5.5, _workDaysPerWeek == 5.5, () {
                      setState(() => _workDaysPerWeek = 5.5);
                    }),
                    const SizedBox(width: 8),
                    _buildRhythmChip('6 ngày', 6.0, _workDaysPerWeek == 6.0, () {
                      setState(() => _workDaysPerWeek = 6.0);
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Số giờ làm việc mỗi ngày:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRhythmChip('7 giờ', 7.0, _hoursPerDay == 7.0, () {
                      setState(() => _hoursPerDay = 7.0);
                    }),
                    const SizedBox(width: 8),
                    _buildRhythmChip('8 giờ (Tiêu chuẩn)', 8.0, _hoursPerDay == 8.0, () {
                      setState(() => _hoursPerDay = 8.0);
                    }),
                    const SizedBox(width: 8),
                    _buildRhythmChip('9 giờ', 9.0, _hoursPerDay == 9.0, () {
                      setState(() => _hoursPerDay = 9.0);
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                // Metrics Calculation Result Card
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : const Color(0xFFF9F4EE),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giờ chuẩn/tháng',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_totalMonthlyHours.toInt()} giờ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${_hoursPerDay.toInt()}h/ngày × ${_workingDaysPerMonth.toInt()} công',
                              style: AppTypography.caption.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '1 Giờ công tương đương',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.primaryDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(_hourlyRate),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              'Thu nhập / ${_totalMonthlyHours.toInt()}h',
                              style: AppTypography.caption.copyWith(
                                  fontSize: 10, color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Block 3: Concrete Preview Samples
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
                    Text('✨', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text(
                      'Bảng quy đổi thực tế ví dụ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSampleRow('☕', 'Cà phê muối sáng', 35000),
                _buildSampleRow('🥖', 'Bánh mì ốp la chả', 30000),
                _buildSampleRow('🍲', 'Ăn tối cùng bạn bè', 250000),
                _buildSampleRow('👟', 'Đôi giày thể thao mới', 1200000),
                _buildSampleRow('📱', 'Chiếc điện thoại xịn', 15000000),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Save Button
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
            onPressed: () {
              ref.read(profileProvider.notifier).updateProfile(
                    monthlyIncome: _monthlyIncome,
                    monthlyWorkHours: _totalMonthlyHours,
                    showWorkHours: _showWorkHours,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Đã cập nhật cài đặt quy đổi giờ làm việc!'),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Lưu Cài Đặt Giờ Làm Việc 🐾',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRhythmChip(
      String label, double val, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFF0EBE3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSampleRow(String emoji, String title, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    CurrencyFormatter.format(amount),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '≈ ${_formatWorkDuration(amount)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
