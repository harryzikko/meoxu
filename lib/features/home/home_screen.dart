import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/cat_dialogues.dart';
import '../../core/parser/expense_parser.dart';
import '../../core/parser/parser_result.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/database/app_database.dart';
import '../../models/transaction_item.dart';
import '../../models/cat_state.dart';
import '../../providers/profile_provider.dart';
import '../../providers/cat_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/budget_calculator_provider.dart';
import 'widgets/meo_mascot_widget.dart';
import 'widgets/confirm_card_bottom_sheet.dart';
import 'widgets/emotion_selector_dialog.dart';
import 'widgets/numeric_keypad_sheet.dart';
import 'widgets/voice_input_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToTransactions;
  final VoidCallback onNavigateToCatHouse;

  const HomeScreen({
    super.key,
    required this.onNavigateToTransactions,
    required this.onNavigateToCatHouse,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _fastInputCtrl = TextEditingController();
  Map<String, String> _customKeywords = {};
  String? _overrideDialogue;
  String _previewText = '';
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _loadCustomKeywords();
    _fastInputCtrl.addListener(_onFastInputChanged);
  }

  @override
  void dispose() {
    _fastInputCtrl.removeListener(_onFastInputChanged);
    _fastInputCtrl.dispose();
    super.dispose();
  }

  void _onFastInputChanged() {
    final text = _fastInputCtrl.text.trim();
    if (text.length >= 2) {
      final parsed = ExpenseParser.parse(text, customLearnedKeywords: _customKeywords);
      setState(() {
        _showPreview = true;
        _previewText = '[${parsed.categoryName}] • ${CurrencyFormatter.format(parsed.amount)}';
      });
    } else {
      if (_showPreview) {
        setState(() {
          _showPreview = false;
          _previewText = '';
        });
      }
    }
  }

  Future<void> _loadCustomKeywords() async {
    try {
      final rules = await AppDatabase.instance.getKeywordRules();
      setState(() => _customKeywords = rules);
    } catch (_) {}
  }

  void _handleQuickInput(String text) {
    if (text.trim().isEmpty) return;
    final parsed = ExpenseParser.parse(
      text,
      customLearnedKeywords: _customKeywords,
    );
    _showConfirmSheet(parsed, originalText: text);
  }

  void _showConfirmSheet(ParserResult parsed, {String? originalText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConfirmCardBottomSheet(
        initialResult: parsed,
        onConfirm: (finalResult) {
          Navigator.pop(ctx);
          _saveTransaction(finalResult, originalKeyword: originalText);
        },
      ),
    );
  }

  Future<void> _saveTransaction(
    ParserResult result, {
    String? originalKeyword,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newItem = TransactionItem(
      id: id,
      amount: result.amount,
      type: result.type == TransactionType.income ? 'income' : 'expense',
      categoryId: result.categoryId,
      note: result.note,
      dateTime: result.dateTime,
      source: 'manual',
      status: 'confirmed',
    );

    await ref
        .read(transactionProvider.notifier)
        .addTransaction(newItem, originalKeyword: originalKeyword);

    await ref.read(catProvider.notifier).onTransactionRecorded();

    if (mounted) {
      _fastInputCtrl.clear();
      setState(() => _showPreview = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Đã lưu: ${newItem.note} (${CurrencyFormatter.format(newItem.amount)})! +5 cá khô 🐟',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.primaryDark,
          action: SnackBarAction(
            label: 'Hoàn tác',
            textColor: Colors.white,
            onPressed: () {
              ref.read(transactionProvider.notifier).undoDelete();
            },
          ),
        ),
      );
    }

    if (newItem.isExpense && mounted) {
      _showEmotionPrompt(id);
    }
  }

  void _showEmotionPrompt(String transactionId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EmotionSelectorDialog(
        onSelectEmotion: (emotion) async {
          Navigator.pop(ctx);
          await ref
              .read(transactionProvider.notifier)
              .attachEmotion(transactionId, emotion);
          await ref.read(catProvider.notifier).onEmotionAttached();
        },
        onDismiss: () => Navigator.pop(ctx),
      ),
    );
  }

  String _formatWorkDuration(double amount, double monthlyIncome, double monthlyHours) {
    if (monthlyHours <= 0 || monthlyIncome <= 0) return '21 phút';
    final hourlyRate = monthlyIncome / monthlyHours;
    final hours = amount / hourlyRate;
    if (hours < 1.0) {
      final mins = (hours * 60).round().clamp(1, 60);
      return '$mins phút';
    } else if (hours < 8.0) {
      return '${hours.toStringAsFixed(1)} giờ';
    } else {
      final days = (hours / 8.0).toStringAsFixed(1);
      return '$days ngày công';
    }
  }

  String _getEmotionDisplay(String? emotion) {
    switch (emotion) {
      case 'happy':
        return '😊 Vui';
      case 'necessary':
        return '👌 Cần thiết';
      case 'impulsive':
        return '⚡ Bốc đồng';
      case 'regret':
        return '😿 Hối hận';
      default:
        return '😊 Vui';
    }
  }

  Color _getEmotionColor(String? emotion) {
    switch (emotion) {
      case 'happy':
        return AppColors.emotionHappy;
      case 'necessary':
        return AppColors.emotionNecessary;
      case 'impulsive':
        return AppColors.emotionImpulsive;
      case 'regret':
        return AppColors.emotionRegret;
      default:
        return AppColors.emotionHappy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final catCombined = ref.watch(catProvider);
    final txState = ref.watch(transactionProvider);
    final budget = ref.watch(budgetCalculationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final recentTxs = txState.allTransactions.take(3).toList();
    final hasNoTx = txState.allTransactions.isEmpty;

    final catMessage = _overrideDialogue ??
        CatDialogueEngine.getDialogue(
          personality: profile.catPersonality,
          callTerm: profile.formattedCallTerm,
          catName: profile.catName,
          userName: profile.userName,
          mood: catCombined.cat.currentMood,
          isOverspent: budget.isOverspent,
          isUnder20Percent: budget.isUnder20Percent,
          hasNoTransactions: hasNoTx,
        );

    final dailyAllowance = budget.dailyBudget;
    final spentToday = budget.todaySpent;
    final remainingAllowance = budget.remainingToday;
    final progressRatio = budget.percentageRemaining.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: (isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0))
            .withOpacity(0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2E2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐱', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Meo Xu',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· Hôm Nay',
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Streak & Fish pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : const Color(0xFFFBEADB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 2),
                Text(
                  '${catCombined.streak.currentStreak}d',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('•',
                    style: TextStyle(fontSize: 10, color: Colors.black26)),
                const SizedBox(width: 6),
                const Text('🐟', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 2),
                Text(
                  '${catCombined.cat.fishPoints}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Cat Avatar Button -> opens Cat House
          InkWell(
            onTap: widget.onNavigateToCatHouse,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight, width: 1.5),
              ),
              child: const Center(
                child: Text('🐾', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable main feed
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              // 1. Greeting Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Chào ${profile.userName}!',
                            style: AppTypography.displayMedium.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('✨', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Hôm nay ${profile.catName} đang vui nè~',
                            style: AppTypography.caption.copyWith(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('🐾', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.eco_rounded,
                            size: 14, color: Color(0xFF2B6A45)),
                        SizedBox(width: 4),
                        Text(
                          'Thảnh thơi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B6A45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 2. Hero Card: Đĩa Cá Khô & Mèo Xu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Mascot and Speech Bubble
                    MeoMascotWidget(
                      mood: catCombined.cat.currentMood,
                      breed: profile.catBreed,
                      eyeColor: profile.eyeColor,
                      equippedAccessories: catCombined.cat.equippedAccessories,
                      size: 140,
                      onPet: () {
                        final petMsg = CatDialogueEngine.getDialogue(
                          personality: profile.catPersonality,
                          callTerm: profile.formattedCallTerm,
                          catName: profile.catName,
                          userName: profile.userName,
                          mood: catCombined.cat.currentMood,
                          isPetting: true,
                        );
                        setState(() => _overrideDialogue = petMsg);
                      },
                    ),
                    const SizedBox(height: 8),
                    // Speech Bubble
                    InkWell(
                      onTap: () {
                        final nextMsg = CatDialogueEngine.getDialogue(
                          personality: profile.catPersonality,
                          callTerm: profile.formattedCallTerm,
                          catName: profile.catName,
                          userName: profile.userName,
                          mood: catCombined.cat.currentMood,
                          isOverspent: budget.isOverspent,
                          isUnder20Percent: budget.isUnder20Percent,
                          hasNoTransactions: hasNoTx,
                        );
                        setState(() => _overrideDialogue = nextMsg);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          catMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Central Single Massive Metric
                    const Text(
                      'HÔM NAY ĐƯỢC TIÊU THOẢI MÁI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CurrencyFormatter.format(remainingAllowance)
                              .replaceAll('đ', '')
                              .trim(),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'đ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Tâm lý nhẹ tênh, không sợ lố ví',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dried Fish Progress Bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : const Color(0xFFFDF6EE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Row(
                                children: [
                                  const Text('🐟',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Còn ${(progressRatio * 100).toInt()}% đĩa cá khô',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${CurrencyFormatter.format(spentToday)} / ${CurrencyFormatter.format(dailyAllowance)}',
                                style: AppTypography.caption.copyWith(
                                    fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              minHeight: 10,
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressRatio > 0.3
                                    ? AppColors.primary
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đã chi: ${CurrencyFormatter.format(spentToday)}',
                                style: AppTypography.caption.copyWith(
                                    fontSize: 11),
                              ),
                              Text(
                                budget.isOverspent
                                    ? 'Cần giảm nhịp chi 🍲'
                                    : 'Chuẩn mốc an toàn ✓',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: budget.isOverspent
                                      ? AppColors.danger
                                      : AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 3. Interactive Quick Savings Simulator Slider
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.savings_rounded,
                                color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Mức tiết kiệm tháng',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${profile.savingPercentage.toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: profile.savingPercentage.clamp(5.0, 50.0),
                      min: 5.0,
                      max: 50.0,
                      divisions: 9,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(profileProvider.notifier).setFinance(
                              monthlyIncome: profile.monthlyIncome,
                              savingPercentage: val,
                            );
                      },
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thong thả (5%)',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textTertiary)),
                        Text('Tự động cân bằng chi tiêu',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark)),
                        Text('Tích lũy nhanh (50%)',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 4. Recent Transactions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Gần nhất hôm nay',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : const Color(0xFFFBEADB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${recentTxs.length} món',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToTransactions,
                    child: const Text(
                      'Xem sổ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentTxs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Hôm nay chưa có khoản chi nào. Chạm nhập nhanh bên dưới nha meo~ 🐾',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...recentTxs.map((item) {
                  final timeStr = DateFormat('HH:mm').format(item.dateTime);
                  final workText = _formatWorkDuration(
                    item.amount,
                    profile.monthlyIncome,
                    profile.monthlyWorkHours,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF2E4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text('🍜', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.note,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    if (profile.showWorkHours) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5EBE1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '≈ $workText',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getEmotionColor(item.emotion)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getEmotionDisplay(item.emotion),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: _getEmotionColor(item.emotion),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '-${CurrencyFormatter.format(item.amount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              timeStr,
                              style: AppTypography.caption.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),

          // 5. Persistent 3-Second Fast Input Dock (Floats above shell bar)
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live preview bubble
                if (_showPreview)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          _previewText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Nhấn gửi',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Dock bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_note_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fastInputCtrl,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _handleQuickInput,
                          decoration: const InputDecoration(
                            hintText: 'trưa ăn bún 45k, cà phê 2 ly 70...',
                            hintStyle: TextStyle(fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Voice button
                      IconButton(
                        icon: const Icon(Icons.mic_rounded,
                            color: AppColors.primaryDark),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const VoiceInputSheet(),
                          );
                        },
                      ),
                      // Keypad button
                      IconButton(
                        icon: const Icon(Icons.dialpad_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const NumericKeypadSheet(),
                          );
                        },
                      ),
                      // Send button
                      InkWell(
                        onTap: () => _handleQuickInput(_fastInputCtrl.text),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_upward_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
