import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/currency_formatter.dart';

class WhatIfScreen extends StatefulWidget {
  final String itemName;
  final double singleCost;

  const WhatIfScreen({
    super.key,
    this.itemName = 'Cà phê mỗi sáng',
    this.singleCost = 35000.0,
  });

  @override
  State<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends State<WhatIfScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _costCtrl;
  double _cost = 35000.0;
  double _cutTimesPerWeek = 3.0; // Slider: bớt X lần/tuần

  @override
  void initState() {
    super.initState();
    _cost = widget.singleCost;
    _nameCtrl = TextEditingController(text: widget.itemName);
    _costCtrl = TextEditingController(
      text: widget.singleCost.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculations
    final yearlyDailyTotal = _cost * 365;
    final savedPerWeek = _cost * _cutTimesPerWeek;
    final savedPerMonth = savedPerWeek * 4.33;
    final savedPerYear = savedPerWeek * 52;

    String equivalentReward = '1 chuyến du lịch nghỉ dưỡng Đà Lạt';
    if (savedPerYear >= 20000000) {
      equivalentReward =
          '1 chiếc iPhone mới toanh hoặc 1 chuyến du lịch Nhật Bản';
    } else if (savedPerYear >= 10000000) {
      equivalentReward = '1 chiếc laptop làm việc hoặc 1 chuyến vi vu Thái Lan';
    } else if (savedPerYear >= 5000000) {
      equivalentReward = '1 chiếc tai nghe chống ồn cao cấp';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nếu như... ✨')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item & Cost Input Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Khoản chi lặp lại bạn muốn thử nghiệm:',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên thói quen',
                      prefixIcon: Icon(
                        Icons.coffee_rounded,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _costCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền mỗi lần',
                      prefixIcon: Icon(
                        Icons.payments_rounded,
                        color: AppColors.primaryDark,
                      ),
                      suffixText: 'VNĐ',
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setState(() => _cost = parsed);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Yearly Perspective (Nếu giữ thói quen mỗi ngày)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🗓️ ', style: TextStyle(fontSize: 16)),
                      Text(
                        'Một năm mỗi ngày (${_nameCtrl.text}):',
                        style: AppTypography.titleMedium.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(yearlyDailyTotal),
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '≈ $equivalentReward',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Slider: "Nếu bớt X lần mỗi tuần"
            Text(
              'Nếu bạn thử bớt ${_cutTimesPerWeek.toInt()} lần mỗi tuần:',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 6),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                thumbColor: AppColors.primaryDark,
                trackHeight: 6,
              ),
              child: Slider(
                value: _cutTimesPerWeek,
                min: 1,
                max: 7,
                divisions: 6,
                label: 'Bớt ${_cutTimesPerWeek.toInt()} lần/tuần',
                onChanged: (val) => setState(() => _cutTimesPerWeek = val),
              ),
            ),
            const SizedBox(height: 14),

            // Simulation Result Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Mỗi tháng tiết kiệm',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.formatCompact(savedPerMonth),
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('Một năm tiết kiệm', style: AppTypography.caption),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.formatCompact(savedPerYear),
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Friendly Cat Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.emotionHappy.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mèo không bắt bạn phải cắt giảm đâu nha! Đây chỉ là một góc nhìn thú vị để bạn chủ động lựa chọn những gì thực sự mang lại niềm vui cho mình.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
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
