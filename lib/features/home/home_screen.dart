import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_strings.dart';
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
import 'widgets/fish_plate_card.dart';
import 'widgets/quick_input_bar.dart';
import 'widgets/confirm_card_bottom_sheet.dart';
import 'widgets/emotion_selector_dialog.dart';
import '../transactions/widgets/transaction_tile.dart';

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
  Map<String, String> _customKeywords = {};

  @override
  void initState() {
    super.initState();
    _loadCustomKeywords();
  }

  Future<void> _loadCustomKeywords() async {
    try {
      final rules = await AppDatabase.instance.getKeywordRules();
      setState(() => _customKeywords = rules);
    } catch (_) {}
  }

  void _handleQuickInput(String text) {
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

    // Update cat points & streak
    await ref.read(catProvider.notifier).onTransactionRecorded();

    // Show undo snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu: ${newItem.note} (${CurrencyFormatter.format(newItem.amount)})',
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Hoàn tác',
            textColor: AppColors.primary,
            onPressed: () {
              ref.read(transactionProvider.notifier).undoDelete();
            },
          ),
        ),
      );
    }

    // Show emotion prompt if it was an expense
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

  void _showManualInputDialog() {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String category = 'food';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Nhập khoản chi', style: AppTypography.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VNĐ)',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(
                        amountCtrl.text.replaceAll('.', '').replaceAll(',', ''),
                      );
                      if (amount != null && amount > 0) {
                        Navigator.pop(ctx);
                        _saveTransaction(
                          ParserResult(
                            amount: amount,
                            note: noteCtrl.text.trim().isEmpty
                                ? 'Chi tiêu'
                                : noteCtrl.text.trim(),
                            categoryId: category,
                            categoryName: 'Ăn uống',
                            dateTime: DateTime.now(),
                          ),
                        );
                      }
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final catState = ref.watch(catProvider);
    final txState = ref.watch(transactionProvider);
    final budget = ref.watch(budgetCalculationProvider);

    final recentTxs = txState.allTransactions.take(3).toList();

    // Determine Cat Mood message
    String catMessage = AppStrings.catHappyMsg;
    if (txState.allTransactions.isEmpty) {
      catMessage = AppStrings.catSleepingMsg;
    } else if (budget.isOverspent) {
      catMessage = AppStrings.catConfusedMsg;
    } else if (budget.isUnder20Percent) {
      catMessage = AppStrings.catWorriedMsg;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              profile.catName,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: widget.onNavigateToCatHouse,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Row(
                  children: [
                    const Text('🐟', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${catState.cat.fishPoints}',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // Animated Mascot in Center
                  GestureDetector(
                    onTap: widget.onNavigateToCatHouse,
                    child: Column(
                      children: [
                        MeoMascotWidget(
                          mood: catState.cat.currentMood,
                          breed: profile.catBreed,
                          equippedAccessories: catState.cat.equippedAccessories,
                          size: 160,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryLight.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            catMessage,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Fish Plate & Big Number Card
                  FishPlateCard(
                    budget: budget,
                    onSavingChanged: (val) {
                      ref
                          .read(profileProvider.notifier)
                          .setFinance(
                            monthlyIncome: profile.monthlyIncome,
                            savingPercentage: val,
                          );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.recentTransactions,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onNavigateToTransactions,
                        child: Text(
                          AppStrings.viewAllTransactions,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Recent Transactions List
                  if (recentTxs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.noTransactionsToday,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...recentTxs.map((item) {
                      return TransactionTile(
                        item: item,
                        monthlyIncome: profile.monthlyIncome,
                        monthlyHours: profile.monthlyWorkHours,
                        showWorkHours: profile.showWorkHours,
                        onTap: () {
                          // Tap to view/edit
                        },
                      );
                    }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Quick Input Bar
          QuickInputBar(
            onSubmitText: _handleQuickInput,
            onManualInputTap: _showManualInputDialog,
            onVoiceTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Chức năng nhận giọng nói đang kích hoạt qua mic điện thoại',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
