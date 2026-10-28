import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class EmotionSelectorDialog extends StatefulWidget {
  final ValueChanged<String> onSelectEmotion;
  final VoidCallback onDismiss;

  const EmotionSelectorDialog({
    super.key,
    required this.onSelectEmotion,
    required this.onDismiss,
  });

  @override
  State<EmotionSelectorDialog> createState() => _EmotionSelectorDialogState();
}

class _EmotionSelectorDialogState extends State<EmotionSelectorDialog>
    with SingleTickerProviderStateMixin {
  String? _stampedEmotionId;
  late AnimationController _stampCtrl;
  late Animation<double> _stampScale;

  final emotions = [
    {
      'id': 'happy',
      'label': 'Vui vẻ',
      'emoji': '😊',
      'color': AppColors.emotionHappy,
      'seal': 'CHI CHO NIỀM VUI ✨',
    },
    {
      'id': 'necessary',
      'label': 'Cần thiết',
      'emoji': '👌',
      'color': AppColors.emotionNecessary,
      'seal': 'KHOẢN CẦN THIẾT 🌿',
    },
    {
      'id': 'regret',
      'label': 'Hối hận',
      'emoji': '😿',
      'color': AppColors.emotionRegret,
      'seal': 'RÚT KINH NGHIỆM 😿',
    },
    {
      'id': 'impulsive',
      'label': 'Bốc đồng',
      'emoji': '⚡',
      'color': AppColors.emotionImpulsive,
      'seal': 'CHỚP NHOÁNG ⚡',
    },
  ];

  @override
  void initState() {
    super.initState();
    _stampCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _stampScale = Tween<double>(begin: 2.2, end: 1.0).animate(
      CurvedAnimation(parent: _stampCtrl, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _stampCtrl.dispose();
    super.dispose();
  }

  void _handleSelect(String id) {
    HapticFeedback.heavyImpact();
    setState(() {
      _stampedEmotionId = id;
    });

    _stampCtrl.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) {
          widget.onSelectEmotion(id);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Text('🐾', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Khoản này bạn thấy thế nào?',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onDismiss,
                icon: const Icon(Icons.close_rounded, size: 20),
                tooltip: 'Bỏ qua',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Gắn nhãn để Mèo Xu tìm ra thói quen chi tiêu giúp bạn nhé!',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),

          // Emotion Stamp Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: emotions.map((item) {
              final id = item['id'] as String;
              final color = item['color'] as Color;
              final isSelected = _stampedEmotionId == id;

              return InkWell(
                onTap: _stampedEmotionId != null ? null : () => _handleSelect(id),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 76,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.35)
                        : color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.4),
                      width: isSelected ? 2.5 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      // Stamp Animation Overlay on selected
                      if (isSelected)
                        ScaleTransition(
                          scale: _stampScale,
                          child: Transform.rotate(
                            angle: -math.pi / 24,
                            child: Text(
                              item['emoji'] as String,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        )
                      else
                        Text(
                          item['emoji'] as String,
                          style: const TextStyle(fontSize: 26),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Rubber Ink Stamp Banner
          if (_stampedEmotionId != null)
            AnimatedBuilder(
              animation: _stampCtrl,
              builder: (context, _) {
                final emotion = emotions.firstWhere((e) => e['id'] == _stampedEmotionId);
                return ScaleTransition(
                  scale: _stampScale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: (emotion['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: emotion['color'] as Color, width: 1.5),
                    ),
                    child: Text(
                      '✓ ${emotion['seal']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: emotion['color'] as Color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Text(
              'Vuốt xuống hoặc bấm X để bỏ qua gắn nhãn',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
