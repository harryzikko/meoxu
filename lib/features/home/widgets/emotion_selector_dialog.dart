import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class EmotionSelectorDialog extends StatelessWidget {
  final ValueChanged<String> onSelectEmotion;
  final VoidCallback onDismiss;

  const EmotionSelectorDialog({
    super.key,
    required this.onSelectEmotion,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emotions = [
      {
        'id': 'happy',
        'label': 'Vui vẻ',
        'emoji': '😊',
        'color': AppColors.emotionHappy,
      },
      {
        'id': 'necessary',
        'label': 'Cần thiết',
        'emoji': '👌',
        'color': AppColors.emotionNecessary,
      },
      {
        'id': 'regret',
        'label': 'Hối hận',
        'emoji': '😿',
        'color': AppColors.emotionRegret,
      },
      {
        'id': 'impulsive',
        'label': 'Bốc đồng',
        'emoji': '⚡',
        'color': AppColors.emotionImpulsive,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('🐾', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Khoản này bạn thấy thế nào?',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: 'Bỏ qua',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: emotions.map((item) {
              final color = item['color'] as Color;
              return InkWell(
                onTap: () => onSelectEmotion(item['id'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item['emoji'] as String,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'] as String,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Mẹo: Bạn có thể bỏ qua bất kỳ lúc nào!',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
