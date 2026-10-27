import 'parser_result.dart';
import '../utils/currency_formatter.dart';

class ExpenseParser {
  // Built-in categories with keywords
  static const Map<String, List<String>> defaultKeywords = {
    'income': [
      'lương',
      'thuởng',
      'thưởng',
      'được cho',
      'tiền về',
      'nhận tiền',
      'bán đồ',
      'hoàn tiền',
      'thu nhập',
      'lãi',
    ],
    'food': [
      'ăn',
      'bún',
      'phở',
      'cơm',
      'cà phê',
      'cf',
      'cafe',
      'trà sữa',
      'trưa',
      'sáng',
      'tối',
      'bánh',
      'chè',
      'nhậu',
      'pizza',
      'kfc',
      'bột chiên',
      'hủ tiếu',
      'nem rán',
      'gà rán',
      'mì',
      'miến',
      'xôi',
      'trà đá',
      'sinh tố',
      'nước ép',
      'trái cây',
      'hoa quả',
      'đồ ăn',
      'ăn vặt',
      'chè bưởi',
      'trứng',
      'thịt',
      'rau',
    ],
    'transport': [
      'grab',
      'be',
      'gojek',
      'taxi',
      'xăng',
      'gửi xe',
      'bus',
      'xe buýt',
      'vé xe',
      'rửa xe',
      'thay nhớt',
      'bảo dưỡng xe',
      'sửa xe',
      'xanh sm',
      'vé tàu',
      'vé máy bay',
    ],
    'bills': [
      'tiền nhà',
      'phòng trọ',
      'tiền trọ',
      'điện',
      'nước',
      'wifi',
      'internet',
      'rác',
      'phí chung cư',
      'truyền hình cáp',
      'tiền mạng',
      'hóa đơn',
      'học phí',
    ],
    'entertainment': [
      'phim',
      'game',
      'du lịch',
      'netflix',
      'xem phim',
      'sách',
      'truyện',
      'hát',
      'karaoke',
      'boardgame',
      'spotify',
      'youtube',
      'vé xem kịch',
      'vé concert',
    ],
    'shopping': [
      'mua',
      'shopee',
      'lazada',
      'tiktok shop',
      'quần',
      'áo',
      'giày',
      'mỹ phẩm',
      'son',
      'váy',
      'túi xách',
      'đồng hồ',
      'tai nghe',
      'đồ gia dụng',
      'siêu thị',
    ],
    'health': [
      'thuốc',
      'khám',
      'bác sĩ',
      'gym',
      'nha khoa',
      'khẩu trang',
      'bệnh viện',
      'xét nghiệm',
      'vitamin',
      'thực phẩm chức năng',
      'yoga',
    ],
  };

  static const Map<String, String> categoryDisplayNames = {
    'food': 'Ăn uống',
    'transport': 'Di chuyển',
    'bills': 'Hóa đơn',
    'entertainment': 'Giải trí',
    'shopping': 'Mua sắm',
    'health': 'Sức khỏe',
    'income': 'Thu nhập',
    'other': 'Chi tiêu khác',
  };

  /// Parses a raw user sentence into structured transaction data
  static ParserResult parse(
    String rawInput, {
    Map<String, String>? customLearnedKeywords,
  }) {
    var text = rawInput.trim();
    if (text.isEmpty) {
      return ParserResult(
        amount: 0,
        note: 'Giao dịch mới',
        categoryId: 'other',
        categoryName: categoryDisplayNames['other']!,
        dateTime: DateTime.now(),
      );
    }

    // 1. Extract Date / Time modifiers
    DateTime targetDate = DateTime.now();
    final lowerText = text.toLowerCase();

    if (lowerText.contains('hôm qua')) {
      targetDate = targetDate.subtract(const Duration(days: 1));
      text = text
          .replaceAll(RegExp(r'hôm qua', caseSensitive: false), '')
          .trim();
    } else if (lowerText.contains('hôm kia')) {
      targetDate = targetDate.subtract(const Duration(days: 2));
      text = text
          .replaceAll(RegExp(r'hôm kia', caseSensitive: false), '')
          .trim();
    } else if (lowerText.contains('sáng nay')) {
      targetDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        8,
        30,
      );
      text = text
          .replaceAll(RegExp(r'sáng nay', caseSensitive: false), '')
          .trim();
    } else if (lowerText.contains('trưa nay')) {
      targetDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        12,
        15,
      );
      text = text
          .replaceAll(RegExp(r'trưa nay', caseSensitive: false), '')
          .trim();
    } else if (lowerText.contains('tối qua')) {
      targetDate = targetDate.subtract(const Duration(days: 1));
      targetDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        19,
        30,
      );
      text = text
          .replaceAll(RegExp(r'tối qua', caseSensitive: false), '')
          .trim();
    }

    // 2. Extract Amount
    // Regex matches expressions like '1tr250', '1tr2', '1.5tr', '45k', '50.000', '50000', or standalone number '70'
    final amountRegex = RegExp(
      r'(\d+(?:[.,]\d+)?\s*(?:tr|triệu|k|nghìn|ngàn|đ|vnd|m)\b|\b\d+tr\d+\b|\b\d{1,3}(?:\.\d{3})+\b|\b\d{4,9}\b|\b\d{2,3}\b)',
      caseSensitive: false,
    );

    double extractedAmount = 0;
    String matchedAmountToken = '';
    final matches = amountRegex.allMatches(text);

    // Pick the most likely amount token (prefer suffixes like k, tr or large numbers)
    for (final m in matches) {
      final token = m.group(0)!;
      final parsed = CurrencyFormatter.parseQuickAmount(token);
      if (parsed != null && parsed > 0) {
        extractedAmount = parsed;
        matchedAmountToken = token;
        break;
      }
    }

    // 3. Clean Note by removing the amount token
    String cleanNote = text;
    if (matchedAmountToken.isNotEmpty) {
      cleanNote = cleanNote.replaceFirst(matchedAmountToken, '').trim();
    }

    // Clean multiple consecutive spaces and trailing punctuation
    cleanNote = cleanNote.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanNote.isEmpty) {
      cleanNote = 'Khoản chi không tên';
    }

    // 4. Identify Category
    final lowerNote = cleanNote.toLowerCase();
    String detectedCategory = 'other';
    TransactionType detectedType = TransactionType.expense;

    // Check custom learned keywords first
    if (customLearnedKeywords != null) {
      for (final entry in customLearnedKeywords.entries) {
        if (lowerNote.contains(entry.key.toLowerCase())) {
          detectedCategory = entry.value;
          if (detectedCategory == 'income') {
            detectedType = TransactionType.income;
          }
          break;
        }
      }
    }

    // If not found in custom, check default keyword rules
    if (detectedCategory == 'other') {
      for (final catEntry in defaultKeywords.entries) {
        final catId = catEntry.key;
        final words = catEntry.value;
        for (final word in words) {
          if (lowerNote.contains(word)) {
            detectedCategory = catId;
            if (catId == 'income') {
              detectedType = TransactionType.income;
            }
            break;
          }
        }
        if (detectedCategory != 'other') break;
      }
    }

    return ParserResult(
      amount: extractedAmount,
      note: cleanNote,
      categoryId: detectedCategory,
      categoryName: categoryDisplayNames[detectedCategory] ?? 'Chi tiêu',
      dateTime: targetDate,
      type: detectedType,
      confidence: extractedAmount > 0 ? 0.95 : 0.5,
    );
  }
}
