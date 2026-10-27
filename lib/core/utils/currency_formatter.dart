import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount).replaceAll('VND', 'đ').trim();
  }

  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)} tr';
    } else if (amount >= 1000) {
      final val = amount / 1000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 0)}k';
    }
    return '$amount đ';
  }

  /// Parses text like '45k', '1tr2', '1.5tr', '50000', '70' into a double
  static double? parseQuickAmount(String input) {
    final cleaned = input.toLowerCase().trim();
    if (cleaned.isEmpty) return null;

    // Pattern for '1tr2', '1tr250', '2tr'
    final trMatch = RegExp(r'^(\d+)(?:tr|m)(\d+)?$').firstMatch(cleaned);
    if (trMatch != null) {
      final millions = int.parse(trMatch.group(1)!);
      final sub = trMatch.group(2);
      if (sub == null || sub.isEmpty) {
        return millions * 1000000.0;
      }
      // If '1tr2', sub is '2' -> 200,000. If '1tr25' -> 250,000
      final padded = sub.padRight(6, '0').substring(0, 6);
      return (millions * 1000000.0) + double.parse(padded);
    }

    // Pattern for '1.5tr', '2.8m'
    final decimalTrMatch = RegExp(r'^(\d+(?:\.\d+)?)(?:tr|m)$').firstMatch(cleaned);
    if (decimalTrMatch != null) {
      final val = double.tryParse(decimalTrMatch.group(1)!);
      if (val != null) return val * 1000000.0;
    }

    // Pattern for '45k', '120k'
    final kMatch = RegExp(r'^(\d+(?:\.\d+)?)k$').firstMatch(cleaned);
    if (kMatch != null) {
      final val = double.tryParse(kMatch.group(1)!);
      if (val != null) return val * 1000.0;
    }

    // Pattern for plain numbers like '45000', '45.000', '1,000,000'
    final sanitizedNum = cleaned.replaceAll('.', '').replaceAll(',', '');
    final directVal = double.tryParse(sanitizedNum);
    if (directVal != null) {
      // If standalone small number like 50 or 70 in VN context, usually means 50k / 70k
      if (directVal < 1000 && directVal > 0) {
        return directVal * 1000.0;
      }
      return directVal;
    }

    return null;
  }
}
