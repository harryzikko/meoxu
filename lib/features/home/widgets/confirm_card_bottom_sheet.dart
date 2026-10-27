import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/parser/parser_result.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../models/category_item.dart';

class ConfirmCardBottomSheet extends StatefulWidget {
  final ParserResult initialResult;
  final Function(ParserResult finalResult) onConfirm;

  const ConfirmCardBottomSheet({
    super.key,
    required this.initialResult,
    required this.onConfirm,
  });

  @override
  State<ConfirmCardBottomSheet> createState() => _ConfirmCardBottomSheetState();
}

class _ConfirmCardBottomSheetState extends State<ConfirmCardBottomSheet> {
  late double _amount;
  late String _note;
  late String _categoryId;
  late DateTime _dateTime;
  late TransactionType _type;

  int _countdown = 3;
  Timer? _timer;
  bool _isInteracted = false;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialResult.amount;
    _note = widget.initialResult.note;
    _categoryId = widget.initialResult.categoryId;
    _dateTime = widget.initialResult.dateTime;
    _type = widget.initialResult.type;

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isInteracted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _save();
      }
    });
  }

  void _pauseAutoSave() {
    if (!_isInteracted) {
      setState(() {
        _isInteracted = true;
      });
      _timer?.cancel();
    }
  }

  void _save() {
    _timer?.cancel();
    final finalResult = ParserResult(
      amount: _amount,
      note: _note,
      categoryId: _categoryId,
      categoryName: CategoryItem.getById(_categoryId).name,
      dateTime: _dateTime,
      type: _type,
    );
    widget.onConfirm(finalResult);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = CategoryItem.getById(_categoryId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Auto-save countdown
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Text('🐾', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mèo đã hiểu ý bạn:',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              if (!_isInteracted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tự lưu sau ${_countdown}s',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Big Amount Box
          GestureDetector(
            onTap: () {
              _pauseAutoSave();
              _showEditAmountDialog();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _type == TransactionType.income
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: _type == TransactionType.income ? AppColors.success : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    CurrencyFormatter.format(_amount),
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_rounded, size: 18, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Note Field
          GestureDetector(
            onTap: () {
              _pauseAutoSave();
              _showEditNoteDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _note,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Category Selector Chips
          Text(
            'Danh mục:',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: CategoryItem.defaultCategories.map((cat) {
                final isSelected = cat.id == _categoryId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                        const SizedBox(width: 6),
                        Text(cat.name),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryDark,
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                    labelStyle: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryDark : (isDark ? AppColors.darkBorder : AppColors.border),
                      ),
                    ),
                    onSelected: (val) {
                      _pauseAutoSave();
                      setState(() {
                        _categoryId = cat.id;
                        if (cat.id == 'income') {
                          _type = TransactionType.income;
                        } else {
                          _type = TransactionType.expense;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          ElevatedButton(
            onPressed: _save,
            child: const Text('Lưu giao dịch'),
          ),
        ],
      ),
    );
  }

  void _showEditAmountDialog() {
    final controller = TextEditingController(text: _amount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa số tiền'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'VNĐ'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text);
              if (parsed != null && parsed > 0) {
                setState(() => _amount = parsed);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog() {
    final controller = TextEditingController(text: _note);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa ghi chú'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nhập nội dung chi tiêu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _note = controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}
