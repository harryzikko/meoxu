import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/profile_provider.dart';
import '../../models/cat_state.dart';
import '../home/widgets/meo_mascot_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 2: Cat Info
  String _catName = 'Bánh Mì';
  String _catBreed = 'orange';

  // Step 3: Finance Info
  final TextEditingController _incomeController = TextEditingController(
    text: '12000000',
  );
  double _savingPercent = 20.0;

  // Step 4: Reminder Time
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 30);

  final List<Map<String, dynamic>> _breeds = [
    {
      'id': 'orange',
      'name': 'Mèo Cam',
      'color': Color(0xFFFFB26B),
      'emoji': '🐱',
    },
    {
      'id': 'tabby',
      'name': 'Mèo Mướp',
      'color': Color(0xFFC7A788),
      'emoji': '🐯',
    },
    {
      'id': 'calico',
      'name': 'Tam Thể',
      'color': Color(0xFFF0D5BA),
      'emoji': '🐾',
    },
    {
      'id': 'black',
      'name': 'Mèo Đen',
      'color': Color(0xFF4A4440),
      'emoji': '🐈‍⬛',
    },
    {
      'id': 'white',
      'name': 'Mèo Trắng',
      'color': Color(0xFFFAF7F2),
      'emoji': '🤍',
    },
    {
      'id': 'siamese',
      'name': 'Mèo Xiêm',
      'color': Color(0xFFF2E6D8),
      'emoji': '🤎',
    },
    {
      'id': 'tuxedo',
      'name': 'Tuxedo',
      'color': Color(0xFF2C2F33),
      'emoji': '🎩',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final income =
        double.tryParse(
          _incomeController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        12000000.0;
    final timeStr =
        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

    final currentProfile = ref.read(profileProvider);
    final updated = currentProfile.copyWith(
      catName: _catName.isEmpty ? 'Mèo Xu' : _catName,
      catBreed: _catBreed,
      monthlyIncome: income,
      savingPercentage: _savingPercent,
      reminderTime: timeStr,
      isOnboarded: true,
    );

    await ref.read(profileProvider.notifier).updateProfile(updated);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Step Indicator Dots
                  Row(
                    children: List.generate(4, (index) {
                      final isActive = index == _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryDark
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      AppStrings.onboardSkipBtn,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View with 4 Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentStep = page),
                children: [
                  _buildStep1Welcome(),
                  _buildStep2ChooseCat(),
                  _buildStep3Finance(),
                  _buildStep4Reminder(),
                ],
              ),
            ),

            // Bottom Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentStep == 3
                        ? AppStrings.onboardStartBtn
                        : AppStrings.onboardNextBtn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Welcome
  Widget _buildStep1Welcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MeoMascotWidget(mood: CatMood.happy, breed: _catBreed, size: 200),
          const SizedBox(height: 28),
          Text(
            AppStrings.onboardWelcomeTitle,
            style: AppTypography.displayLarge.copyWith(fontSize: 26),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.onboardWelcomeDesc,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐟', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Tặng bạn 50 đĩa cá khô đầu tiên!',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Breed & Name
  Widget _buildStep2ChooseCat() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            AppStrings.onboardCatBreedTitle,
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.onboardCatBreedDesc,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Mascot Preview
          Center(
            child: MeoMascotWidget(
              mood: CatMood.happy,
              breed: _catBreed,
              size: 150,
            ),
          ),
          const SizedBox(height: 16),

          // Breed Selection Buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _breeds.map((b) {
              final isSelected = b['id'] == _catBreed;
              return ChoiceChip(
                label: Text('${b['emoji']} ${b['name']}'),
                selected: isSelected,
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                onSelected: (val) {
                  if (val) setState(() => _catBreed = b['id'] as String);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Cat Name Input
          Text(
            AppStrings.onboardCatNameTitle,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (val) => setState(() => _catName = val),
            decoration: InputDecoration(
              hintText: AppStrings.onboardCatNameHint,
              prefixIcon: const Icon(
                Icons.pets_rounded,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Financial Setup
  Widget _buildStep3Finance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            AppStrings.onboardFinanceTitle,
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Chỉ để tính con số thoải mái tiêu mỗi ngày, không gửi đi đâu hết.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          Text(
            'Thu nhập ước tính hàng tháng:',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.payments_rounded,
                color: AppColors.primaryDark,
              ),
              suffixText: 'VNĐ',
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu tiết kiệm mong muốn:',
                style: AppTypography.titleMedium,
              ),
              Text(
                '${_savingPercent.toInt()}%',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primaryDark,
            ),
            child: Slider(
              value: _savingPercent,
              min: 0,
              max: 50,
              divisions: 10,
              onChanged: (val) => setState(() => _savingPercent = val),
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Gentle Reminder
  Widget _buildStep4Reminder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MeoMascotWidget(mood: CatMood.excited, breed: _catBreed, size: 160),
          const SizedBox(height: 20),
          Text(
            'Chọn giờ mèo ghé thăm',
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Mỗi ngày mèo chỉ nhắn 1 câu đáng yêu thôi, nếu bạn đã ghi chép rồi thì mèo sẽ không làm phiền đâu!',
            style: AppTypography.bodyMedium.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null) {
                setState(() => _reminderTime = picked);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    style: AppTypography.displayLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
