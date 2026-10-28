import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/cat_provider.dart';

class DailyFortune {
  final String title;
  final String type; // 'daicat', 'thuongcat', 'tieucat', 'canhbao', 'chualanh'
  final String quote;
  final String luckyColor;
  final String luckyNumber;
  final String warning;
  final String emoji;

  const DailyFortune({
    required this.title,
    required this.type,
    required this.quote,
    required this.luckyColor,
    required this.luckyNumber,
    required this.warning,
    required this.emoji,
  });
}

const List<DailyFortune> _fortunes = [
  DailyFortune(
    title: 'ĐẠI CÁT TÀI LỘC',
    type: 'daicat',
    emoji: '🌟',
    quote: 'Hôm nay tài lộc rủng rỉnh! Nếu nhịn được cơn thèm trà sữa lúc 15h, cuối tuần Thần Mèo sẽ độ cho bạn một bữa ăn no nê!',
    luckyColor: 'Vàng mật ong',
    luckyNumber: '88k',
    warning: 'Tránh xa app giao đồ ăn lúc 15:30 chiều',
  ),
  DailyFortune(
    title: 'THƯỢNG CÁT HẦU BAO',
    type: 'thuongcat',
    emoji: '🍀',
    quote: 'Ví tiền đang mỉm cười. Mèo phát hiện bạn đã vững tay chèo qua 3 đợt flash sale. Giữ vững phong độ này nhé Sen!',
    luckyColor: 'Xanh ngọc bích',
    luckyNumber: '120k',
    warning: 'Đừng tin vào mã giảm giá 10k cho đơn 300k',
  ),
  DailyFortune(
    title: 'TIỂU CÁT BẤT NGỜ',
    type: 'tieucat',
    emoji: '🐟',
    quote: 'Hôm nay có điềm may: Khả năng cao bạn sẽ tìm thấy một tờ 20k hoặc 50k vô tình để quên trong túi áo khoác cũ!',
    luckyColor: 'Cam đào ấm',
    luckyNumber: '50k',
    warning: 'Kiểm tra kỹ các ngăn kéo trước khi vứt đồ cũ',
  ),
  DailyFortune(
    title: 'CẢNH BÁO BỐC ĐỒNG',
    type: 'canhbao',
    emoji: '⚡',
    quote: 'Báo động cấp 1: Giỏ hàng online sau 22h đêm là một cái bẫy ma mị! Hãy tắt điện thoại, xoa bụng mèo rồi đi ngủ ngay!',
    luckyColor: 'Trắng tinh khôi',
    luckyNumber: '0đ (không chi tiêu sau 22h)',
    warning: 'Cất thẻ tín dụng vào ngăn kéo sâu nhất',
  ),
  DailyFortune(
    title: 'TRI KỶ CHỮA LÀNH',
    type: 'chualanh',
    emoji: '🌸',
    quote: 'Hôm nay không cần tiết kiệm quá khắt khe. Hãy tự thưởng một ly cà phê thơm và một món ăn ngon. Sen vui thì Meo mới vui!',
    luckyColor: 'Hồng phấn',
    luckyNumber: '35k',
    warning: 'Đừng tự trách mình vì những khoản chi nho nhỏ',
  ),
  DailyFortune(
    title: 'AN TÂM BẤT BIẾN',
    type: 'chualanh',
    emoji: '🌿',
    quote: 'Bão giá ngoài kia mặc kệ, đĩa cá khô hôm nay vẫn có Meo Xu túc trực canh gác. Cứ thong thả sống vui mỗi ngày!',
    luckyColor: 'Xanh lá cỏ non',
    luckyNumber: '150k',
    warning: 'Né các hội nhóm review đồ công nghệ đắt đỏ',
  ),
];

class DailyFortuneCard extends ConsumerStatefulWidget {
  const DailyFortuneCard({super.key});

  @override
  ConsumerState<DailyFortuneCard> createState() => _DailyFortuneCardState();
}

class _DailyFortuneCardState extends ConsumerState<DailyFortuneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  bool _isFlipped = false;
  int _fortuneIndex = 0;

  @override
  void initState() {
    super.initState();
    // Deterministic fortune based on day of year
    final now = DateTime.now();
    _fortuneIndex = (now.year + now.month * 31 + now.day) % _fortunes.length;

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.mediumImpact();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _redrawFortune() async {
    final catState = ref.read(catProvider);
    if (catState.cat.fishPoints < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần ít nhất 2 cá khô để bốc quẻ mới nha Sen ơi! 🐟'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }

    // Deduct 2 fish
    await ref.read(catProvider.notifier).feedCat(fishCost: 2);
    HapticFeedback.heavyImpact();

    // Flip back first, then roll new fortune
    _flipController.reverse().then((_) {
      setState(() {
        _fortuneIndex = (math.Random().nextInt(_fortunes.length));
        _isFlipped = false;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        _flipCard();
      });
    });
  }

  void _showSharePreview(DailyFortune fortune) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF8F0), Color(0xFFFFECC7)],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'QUẺ BÓI MÈO XU',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '${fortune.emoji} ${fortune.title}',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${fortune.quote}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Màu hên', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(fortune.luckyColor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Số may mắn', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(fortune.luckyNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '📸 Chụp ảnh màn hình để khoe Story hoặc gửi cho bạn bè!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fortune = _fortunes[_fortuneIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🥠', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Quẻ Bói Mèo Mỗi Ngày',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Miễn phí mỗi ngày ✨',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Animated 3D Flip Container
        GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * math.pi;
              final isUnder = angle > (math.pi / 2);

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: isUnder
                    ? Transform(
                        transform: Matrix4.identity()..rotateY(math.pi),
                        alignment: Alignment.center,
                        child: _buildFortuneRevealed(fortune, isDark),
                      )
                    : _buildFortuneHidden(isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneHidden(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF382A22), const Color(0xFF281E18)]
              : [const Color(0xFFFFF6EB), const Color(0xFFFFECC7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gilded wax seal icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ],
            child: const Center(
              child: Text('🐾', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hôm nay Thần Mèo phán gì về ví tiền của bạn?',
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chạm một chạm để lật mở quẻ bói may mắn ngày mới 🥠✨',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✨', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Text(
                  'Lật Thẻ Lấy Hên',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

  Widget _buildFortuneRevealed(DailyFortune fortune, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(fortune.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      fortune.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _flipCard,
                child: const Text('Úp lại 🔄', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Cat Quote
          Text(
            '"${fortune.quote}"',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          // Lucky indicators
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🍀 Màu may mắn:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Text(
                        fortune.luckyColor,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🐟 Con số may mắn:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Text(
                        fortune.luckyNumber,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Action Buttons: Share & Redraw
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _showSharePreview(fortune),
                  icon: const Icon(Icons.share_rounded, size: 16, color: AppColors.primaryDark),
                  label: const Text(
                    'Khoe quẻ bói',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _redrawFortune,
                  icon: const Text('🐟', style: TextStyle(fontSize: 14)),
                  label: const Text(
                    'Đổi quẻ (2 cá)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
