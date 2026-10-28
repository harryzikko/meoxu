import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_item.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/cat_provider.dart';

class NumericKeypadSheet extends ConsumerStatefulWidget {
  const NumericKeypadSheet({super.key});

  @override
  ConsumerState<NumericKeypadSheet> createState() => _NumericKeypadSheetState();
}

class _NumericKeypadSheetState extends ConsumerState<NumericKeypadSheet> {
  String _digits = '';
  String _note = '';
  String _selectedCategory = 'food';
  String? _selectedEmotion;

  final TextEditingController _noteCtrl = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'id': 'food', 'label': 'Ăn uống', 'emoji': '🍜'},
    {'id': 'shopping', 'label': 'Mua sắm', 'emoji': '🛍️'},
    {'id': 'transport', 'label': 'Di chuyển', 'emoji': '🛵'},
    {'id': 'bills', 'label': 'Hóa đơn', 'emoji': '⚡'},
    {'id': 'entertainment', 'label': 'Giải trí', 'emoji': '🎬'},
    {'id': 'other', 'label': 'Khác', 'emoji': '✨'},
  ];

  final List<Map<String, String>> _emotions = [
    {'id': 'happy', 'label': 'Vui vẻ', 'emoji': '😊'},
    {'id': 'necessary', 'label': 'Cần thiết', 'emoji': '👌'},
    {'id': 'impulsive', 'label': 'Bốc đồng', 'emoji': '⚡'},
    {'id': 'regret', 'label': 'Tiếc nuối', 'emoji': '🥺'},
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_digits) ?? 0.0;

  void _appendDigit(String d) {
    if (_digits.length >= 10) return;
    setState(() => _digits += d);
  }

  void _backspace() {
    if (_digits.isNotEmpty) {
      setState(() => _digits = _digits.substring(0, _digits.length - 1));
    }
  }

  void _addQuick(int val) {
    final cur = (double.tryParse(_digits) ?? 0.0) + val;
    setState(() => _digits = cur.toInt().toString());
  }

  Future<void> _submit() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền chi tiêu hợp lệ!')),
      );
      return;
    }

    final note = _noteCtrl.text.trim().isNotEmpty
        ? _noteCtrl.text.trim()
        : _categories.firstWhere((c) => c['id'] == _selectedCategory)['label']!;

    final item = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: _amount,
      type: 'expense',
      categoryId: _selectedCategory,
      note: note,
      dateTime: DateTime.now(),
      emotion: _selectedEmotion,
      source: 'manual',
    );

    await ref.read(transactionProvider.notifier).addTransaction(item);
    await ref.read(catProvider.notifier).onTransactionRecorded();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Đã ghi nhận: ${CurrencyFormatter.format(_amount)}! Mèo Xu tích +5 cá! 🐟'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔢', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Bàn Phím Số Nhanh',
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
          const Divider(height: 1),
          const SizedBox(height: 10),
          // Amount Display & Note field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _digits.isEmpty
                          ? '0'
                          : CurrencyFormatter.format(_amount)
                              .replaceAll('đ', '')
                              .trim(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
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
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ghi chú (Ví dụ: Cà phê sáng, Trưa bún chả...)',
                    hintStyle: const TextStyle(fontSize: 13),
                    isDense: true,
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : const Color(0xFFF9F4EE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Category selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((c) {
                final isSelected = _selectedCategory == c['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${c['emoji']} ${c['label']}'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedCategory = c['id']!),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Emotion selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _emotions.map((e) {
                final isSelected = _selectedEmotion == e['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${e['emoji']} ${e['label']}'),
                    selected: isSelected,
                    selectedColor: const Color(0xFF7ED6A5),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF235334) : null,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedEmotion = isSelected ? null : e['id'];
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Quick increments (+20k, +50k, +100k, +200k)
          Row(
            children: [
              _buildQuickBtn('+20k', 20000),
              const SizedBox(width: 6),
              _buildQuickBtn('+50k', 50000),
              const SizedBox(width: 6),
              _buildQuickBtn('+100k', 100000),
              const SizedBox(width: 6),
              _buildQuickBtn('+200k', 200000),
            ],
          ),
          const SizedBox(height: 10),
          // Numeric Dialpad Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDigitBtn('1'),
                _buildDigitBtn('2'),
                _buildDigitBtn('3'),
                _buildDigitBtn('4'),
                _buildDigitBtn('5'),
                _buildDigitBtn('6'),
                _buildDigitBtn('7'),
                _buildDigitBtn('8'),
                _buildDigitBtn('9'),
                _buildDigitBtn('000'),
                _buildDigitBtn('0'),
                _buildActionBtn(
                  icon: Icons.backspace_outlined,
                  onTap: _backspace,
                ),
              ],
            ),
          ),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                'Ghi Nhận Ngay 🐾',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBtn(String text, int amount) {
    return Expanded(
      child: InkWell(
        onTap: () => _addQuick(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFBEADB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBtn(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _appendDigit(digit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
      {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.primaryDark),
      ),
    );
  }
}
