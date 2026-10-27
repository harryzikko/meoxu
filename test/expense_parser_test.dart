import 'package:flutter_test/flutter_test.dart';
import 'package:meoxu/core/parser/expense_parser.dart';
import 'package:meoxu/core/parser/parser_result.dart';

void main() {
  group('ExpenseParser Vietnamese 45 Sample Sentences Suite', () {
    final testCases = <Map<String, dynamic>>[
      // 1-10: Ăn uống (Food)
      {'input': 'trưa ăn bún bò 45k', 'amount': 45000.0, 'category': 'food'},
      {'input': 'sáng ăn phở gà 50k', 'amount': 50000.0, 'category': 'food'},
      {'input': 'cà phê sữa 25k', 'amount': 25000.0, 'category': 'food'},
      {'input': 'trà sữa trân châu 40k', 'amount': 40000.0, 'category': 'food'},
      {'input': 'bánh mì chả lụa 20k', 'amount': 20000.0, 'category': 'food'},
      {'input': 'cơm tấm sườn bì 55k', 'amount': 55000.0, 'category': 'food'},
      {'input': 'cà phê 2 ly 70', 'amount': 70000.0, 'category': 'food'},
      {
        'input': 'pizza hut 180k tối qua',
        'amount': 180000.0,
        'category': 'food',
      },
      {'input': 'gà rán kfc 99k', 'amount': 99000.0, 'category': 'food'},
      {'input': 'sinh tố bơ 35k', 'amount': 35000.0, 'category': 'food'},

      // 11-18: Di chuyển (Transport)
      {
        'input': 'grab bike đi làm 32k',
        'amount': 32000.0,
        'category': 'transport',
      },
      {'input': 'đổ xăng 50k', 'amount': 50000.0, 'category': 'transport'},
      {
        'input': 'gửi xe bệnh viện 5k',
        'amount': 5000.0,
        'category': 'transport',
      },
      {
        'input': 'vé bus tháng 100k',
        'amount': 100000.0,
        'category': 'transport',
      },
      {
        'input': 'be car đi tiệc 85k',
        'amount': 85000.0,
        'category': 'transport',
      },
      {
        'input': 'xanh sm về nhà 42k',
        'amount': 42000.0,
        'category': 'transport',
      },
      {'input': 'rửa xe máy 30k', 'amount': 30000.0, 'category': 'transport'},
      {
        'input': 'thay nhớt xe honda 120k',
        'amount': 120000.0,
        'category': 'transport',
      },

      // 19-25: Hóa đơn (Bills)
      {'input': 'tiền nhà trọ 2tr5', 'amount': 2500000.0, 'category': 'bills'},
      {
        'input': 'tiền điện tháng này 450k',
        'amount': 450000.0,
        'category': 'bills',
      },
      {'input': 'tiền nước 80k', 'amount': 80000.0, 'category': 'bills'},
      {'input': 'wifi viettel 220k', 'amount': 220000.0, 'category': 'bills'},
      {'input': 'tiền mạng 180k', 'amount': 180000.0, 'category': 'bills'},
      {
        'input': 'học phí tiếng anh 1.5tr',
        'amount': 1500000.0,
        'category': 'bills',
      },
      {
        'input': 'phí dịch vụ chung cư 350k',
        'amount': 350000.0,
        'category': 'bills',
      },

      // 26-32: Giải trí (Entertainment)
      {
        'input': 'vé xem phim cgv 110k',
        'amount': 110000.0,
        'category': 'entertainment',
      },
      {
        'input': 'tài khoản netflix 70k',
        'amount': 70000.0,
        'category': 'entertainment',
      },
      {
        'input': 'mua game steam 250k',
        'amount': 250000.0,
        'category': 'entertainment',
      },
      {
        'input': 'mua sách nguyễn nhật ánh 90k',
        'amount': 90000.0,
        'category': 'entertainment',
      },
      {
        'input': 'đi karaoke cùng bạn 150k',
        'amount': 150000.0,
        'category': 'entertainment',
      },
      {
        'input': 'du lịch đà lạt 1tr2 hôm qua',
        'amount': 1200000.0,
        'category': 'entertainment',
      },
      {
        'input': 'gói spotify premium 59k',
        'amount': 59000.0,
        'category': 'entertainment',
      },

      // 33-38: Mua sắm (Shopping)
      {
        'input': 'shopee áo thun 120k',
        'amount': 120000.0,
        'category': 'shopping',
      },
      {
        'input': 'mua giày sneaker 650k',
        'amount': 650000.0,
        'category': 'shopping',
      },
      {
        'input': 'mua son môi black rouge 180k',
        'amount': 180000.0,
        'category': 'shopping',
      },
      {
        'input': 'lazada ốp lưng điện thoại 45k',
        'amount': 45000.0,
        'category': 'shopping',
      },
      {
        'input': 'tiktok shop đồ ăn vặt 85k',
        'amount': 85000.0,
        'category': 'shopping',
      },
      {
        'input': 'mua quần jean 320k',
        'amount': 320000.0,
        'category': 'shopping',
      },

      // 39-42: Sức khỏe (Health)
      {
        'input': 'mua thuốc cảm panadol 35k',
        'amount': 35000.0,
        'category': 'health',
      },
      {
        'input': 'khám nha khoa cạo vôi 150k',
        'amount': 150000.0,
        'category': 'health',
      },
      {
        'input': 'tập gym gói tháng 300k',
        'amount': 300000.0,
        'category': 'health',
      },
      {'input': 'mua vitamin c 80k', 'amount': 80000.0, 'category': 'health'},

      // 43-45: Thu nhập (Income)
      {
        'input': 'lương công ty 12tr',
        'amount': 12000000.0,
        'category': 'income',
        'type': TransactionType.income,
      },
      {
        'input': 'thưởng dự án 2tr',
        'amount': 2000000.0,
        'category': 'income',
        'type': TransactionType.income,
      },
      {
        'input': 'mẹ cho tiền 500k',
        'amount': 500000.0,
        'category': 'income',
        'type': TransactionType.income,
      },
    ];

    int correctAmounts = 0;
    int correctCategories = 0;

    for (final tc in testCases) {
      final input = tc['input'] as String;
      final expectedAmount = tc['amount'] as double;
      final expectedCategory = tc['category'] as String;
      final expectedType =
          tc['type'] as TransactionType? ?? TransactionType.expense;

      test('Parse sentence: "$input"', () {
        final result = ExpenseParser.parse(input);

        expect(
          result.amount,
          equals(expectedAmount),
          reason: 'Amount parse mismatch for "$input"',
        );
        expect(
          result.categoryId,
          equals(expectedCategory),
          reason: 'Category detection mismatch for "$input"',
        );
        expect(
          result.type,
          equals(expectedType),
          reason: 'Type detection mismatch for "$input"',
        );

        if (result.amount == expectedAmount) correctAmounts++;
        if (result.categoryId == expectedCategory) correctCategories++;
      });
    }

    test('Overall accuracy meets Acceptance Criteria (Amount >= 95%, Category >= 85%)', () {
      final total = testCases.length;
      final amountAccuracy = (correctAmounts / total) * 100;
      final categoryAccuracy = (correctCategories / total) * 100;

      expect(amountAccuracy, greaterThanOrEqualTo(95.0));
      expect(categoryAccuracy, greaterThanOrEqualTo(85.0));
    });

    test('Custom learned keyword overrides default rule', () {
      // User teaches app that 'bún đậu' should be 'entertainment' for party
      final customRules = {'bún đậu': 'entertainment'};
      final result = ExpenseParser.parse(
        'bún đậu bạn bè 120k',
        customLearnedKeywords: customRules,
      );

      expect(result.amount, equals(120000.0));
      expect(result.categoryId, equals('entertainment'));
    });
  });
}
