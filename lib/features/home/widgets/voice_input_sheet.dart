import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_item.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/cat_provider.dart';

class VoiceInputSheet extends ConsumerStatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  ConsumerState<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends ConsumerState<VoiceInputSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _voiceTextCtrl =
      TextEditingController(text: 'Trưa ăn bún bò 45k vui vẻ');

  final List<String> _samplePhrases = [
    'Trưa ăn bún bò 45k vui vẻ',
    'Cà phê muối 35k cần thiết',
    'Siêu thị mua đồ 150k',
    'Grab đi làm 32k',
    'Trà sữa full topping 55k bốc đồng',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _voiceTextCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _parseVoiceText(String input) {
    final lower = input.toLowerCase();

    // 1. Parse amount
    double amount = 0.0;
    final kMatch = RegExp(r'(\d+[\.,]?\d*)\s*(k|nghìn|ngàn|tr|triệu|đ|vnd)?')
        .allMatches(lower);
    for (final m in kMatch) {
      final numStr = m.group(1)?.replaceAll(',', '.') ?? '';
      final unit = m.group(2) ?? '';
      final parsed = double.tryParse(numStr);
      if (parsed != null && parsed > 0) {
        if (unit == 'tr' || unit == 'triệu') {
          amount = parsed * 1000000;
        } else if (unit == 'k' || unit == 'nghìn' || unit == 'ngàn' || parsed < 1000) {
          amount = parsed * 1000;
        } else {
          amount = parsed;
        }
        break;
      }
    }
    if (amount <= 0) amount = 45000.0;

    // 2. Parse category
    String category = 'food';
    if (lower.contains('grab') || lower.contains('xe') || lower.contains('xăng')) {
      category = 'transport';
    } else if (lower.contains('siêu thị') || lower.contains('mua') || lower.contains('áo') || lower.contains('giày')) {
      category = 'shopping';
    } else if (lower.contains('điện') || lower.contains('nước') || lower.contains('mạng') || lower.contains('phòng')) {
      category = 'bills';
    } else if (lower.contains('phim') || lower.contains('game') || lower.contains('chơi')) {
      category = 'entertainment';
    }

    // 3. Parse emotion
    String? emotion;
    if (lower.contains('vui')) {
      emotion = 'happy';
    } else if (lower.contains('cần thiết') || lower.contains('thiết yếu') || lower.contains('bắt buộc')) {
      emotion = 'necessary';
    } else if (lower.contains('bốc đồng') || lower.contains('thích')) {
      emotion = 'impulsive';
    } else if (lower.contains('tiếc') || lower.contains('hối hận')) {
      emotion = 'regret';
    }

    return {
      'amount': amount,
      'category': category,
      'emotion': emotion,
      'note': input.trim(),
    };
  }

  Future<void> _submit() async {
    final text = _voiceTextCtrl.text.trim();
    if (text.isEmpty) return;

    final parsed = _parseVoiceText(text);

    final item = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: parsed['amount'] as double,
      type: 'expense',
      categoryId: parsed['category'] as String,
      note: parsed['note'] as String,
      dateTime: DateTime.now(),
      emotion: parsed['emotion'] as String?,
      source: 'voice',
    );

    await ref.read(transactionProvider.notifier).addTransaction(item);
    await ref.read(catProvider.notifier).onTransactionRecorded();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎙️ Đã ghi nhận giọng nói: ${CurrencyFormatter.format(item.amount)} (${item.note})! +5 cá 🐟',
          ),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsed = _parseVoiceText(_voiceTextCtrl.text);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🎙️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'Ghi Sổ Bằng Giọng Nói',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
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
          const SizedBox(height: 14),
          // Animated Mic Wave Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                    : [const Color(0xFFFFF2E2), const Color(0xFFFFEAD5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final scale = 1.0 + (_animController.value * 0.15);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 16 * _animController.value,
                              spreadRadius: 4 * _animController.value,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic, size: 36, color: Colors.white),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Đang lắng nghe bạn trò chuyện cùng Mèo Xu...',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Sample spoken utterances
          const Text(
            'Chạm vào câu mẫu để thử:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _samplePhrases.map((phrase) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(phrase, style: const TextStyle(fontSize: 11)),
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : const Color(0xFFFBEADB),
                    onPressed: () {
                      setState(() {
                        _voiceTextCtrl.text = phrase;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Editable transcription text field
          TextField(
            controller: _voiceTextCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Nội dung nhận diện:',
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          // Parsing Live Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'AI Tự Nhận Diện: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(parsed['amount'] as double),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                if (parsed['emotion'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7ED6A5).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Cảm xúc: ${parsed['emotion']}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF235334),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _submit,
            child: const Text(
              'Xác Nhận & Ghi Sổ 🐾',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
