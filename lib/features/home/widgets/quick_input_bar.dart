import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class QuickInputBar extends StatefulWidget {
  final ValueChanged<String> onSubmitText;
  final VoidCallback onManualInputTap;
  final VoidCallback onVoiceTap;

  const QuickInputBar({
    super.key,
    required this.onSubmitText,
    required this.onManualInputTap,
    required this.onVoiceTap,
  });

  @override
  State<QuickInputBar> createState() => _QuickInputBarState();
}

class _QuickInputBarState extends State<QuickInputBar> {
  final TextEditingController _textController = TextEditingController();

  void _handleSubmitted() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitText(text);
      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Manual Keypad button
            IconButton(
              onPressed: widget.onManualInputTap,
              icon: const Icon(Icons.dialpad_rounded, color: AppColors.textSecondary),
              tooltip: 'Nhập tay bằng số',
            ),
            const SizedBox(width: 4),

            // Main Text Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSubmitted(),
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Nhập nhanh: bún bò 45k, grab 32k...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Voice input button
            IconButton(
              onPressed: widget.onVoiceTap,
              icon: const Icon(Icons.mic_rounded, color: AppColors.primaryDark),
              tooltip: 'Nói để nhập',
            ),

            // Send button
            IconButton.filled(
              onPressed: _handleSubmitted,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
