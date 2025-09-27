import 'package:intl/intl.dart';

class ReceiptParser {
  Map<String, dynamic> parseReceiptText(String text) {
    final Map<String, dynamic> result = {
      'merchant': null,
      'amount': null,
      'date': null,
      'time': null,
      'items': [],
      'category': null,
      'paymentMethod': null,
      'taxAmount': null,
      'confidence': 0.0,
    };

    text = _cleanText(text);
    result['merchant'] = _extractMerchant(text);
    final amountData = _extractAmount(text);
    result['amount'] = amountData['amount'];
    result['date'] = _extractDate(text);
    result['time'] = _extractTime(text);
    result['items'] = _extractItems(text);
    result['category'] = _determineCategory(result['merchant'], result['items']);
    result['paymentMethod'] = _extractPaymentMethod(text);
    result['taxAmount'] = _extractTaxAmount(text);
    result['confidence'] = _calculateParsingConfidence(result);

    return result;
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _extractMerchant(String text) {
    final commonMerchants = [
      'TESCO', 'SAINSBURY', 'ASDA', 'MORRISONS', 'WAITROSE', 'LIDL', 'ALDI',
      'MARKS & SPENCER', 'M&S', 'BOOTS', 'SUPERDRUG', 'COSTA', 'STARBUCKS',
      'PRET A MANGER', 'GREGGS', 'SUBWAY', 'MCDONALDS', 'KFC', 'BURGER KING',
      'AMAZON', 'ARGOS', 'JOHN LEWIS', 'NEXT', 'PRIMARK', 'H&M', 'ZARA',
    ];

    final upperText = text.toUpperCase();
    for (String merchant in commonMerchants) {
      if (upperText.contains(merchant)) {
        return merchant;
      }
    }

    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      final firstLine = lines.first.trim();
      if (firstLine.length > 3 && firstLine.length < 50 && !RegExp(r'^\d').hasMatch(firstLine)) {
        return firstLine;
      }
    }

    return null;
  }

  Map<String, dynamic> _extractAmount(String text) {
    double? highestAmount;

    final amountPatterns = [
      RegExp(r'(?:TOTAL|Total|total)[\s:]*£?(\d+\.?\d{0,2})'),
      RegExp(r'(?:AMOUNT|Amount)[\s:]*£?(\d+\.?\d{0,2})'),
      RegExp(r'(?:SUBTOTAL|Subtotal)[\s:]*£?(\d+\.?\d{0,2})'),
      RegExp(r'£(\d+\.?\d{0,2})'),
      RegExp(r'(\d+\.\d{2})[\s]*GBP'),
      RegExp(r'(\d+\.\d{2})[\s]*£'),
    ];

    for (RegExp pattern in amountPatterns) {
      final matches = pattern.allMatches(text);
      for (Match match in matches) {
        final amountStr = match.group(1);
        if (amountStr != null) {
          try {
            final amount = double.parse(amountStr);
            if (highestAmount == null || amount > highestAmount) {
              highestAmount = amount;
            }
          } catch (e) {
            continue;
          }
        }
      }
    }

    return {'amount': highestAmount};
  }

  DateTime? _extractDate(String text) {
    final datePatterns = [
      RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})'),
      RegExp(r'(\d{4}[/-]\d{1,2}[/-]\d{1,2})'),
      RegExp(r'(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{2,4})', caseSensitive: false),
    ];

    for (RegExp pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        try {
          String dateStr = match.group(1)!;

          final formats = [
            DateFormat('dd/MM/yyyy'),
            DateFormat('dd-MM-yyyy'),
            DateFormat('MM/dd/yyyy'),
            DateFormat('MM-dd-yyyy'),
            DateFormat('yyyy/MM/dd'),
            DateFormat('yyyy-MM-dd'),
            DateFormat('dd MMM yyyy'),
            DateFormat('dd MMMM yyyy'),
          ];

          for (DateFormat format in formats) {
            try {
              return format.parse(dateStr);
            } catch (e) {
              continue;
            }
          }
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  String? _extractTime(String text) {
    final timePattern = RegExp(r'(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AP]M)?)', caseSensitive: false);
    final match = timePattern.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return match.group(1);
    }
    return null;
  }

  List<Map<String, dynamic>> _extractItems(String text) {
    List<Map<String, dynamic>> items = [];

    final itemPattern = RegExp(r'([A-Za-z\s]+)[\s\.\-]*£?(\d+\.\d{2})');
    final matches = itemPattern.allMatches(text);

    for (Match match in matches) {
      final itemName = match.group(1)?.trim();
      final priceStr = match.group(2);

      if (itemName != null && priceStr != null) {
        final nonItemWords = ['TOTAL', 'SUBTOTAL', 'TAX', 'VAT', 'CHANGE', 'CASH', 'CARD', 'BALANCE'];
        if (!nonItemWords.any((word) => itemName.toUpperCase().contains(word))) {
          try {
            final price = double.parse(priceStr);
            items.add({
              'name': itemName,
              'price': price,
              'quantity': 1,
            });
          } catch (e) {
            continue;
          }
        }
      }
    }

    return items;
  }

  String _determineCategory(String? merchant, List<Map<String, dynamic>> items) {
    if (merchant != null) {
      final upperMerchant = merchant.toUpperCase();

      if (['COSTA', 'STARBUCKS', 'PRET', 'GREGGS', 'SUBWAY', 'MCDONALDS', 'KFC', 'BURGER KING']
          .any((m) => upperMerchant.contains(m))) {
        return 'Food & Dining';
      }

      if (['TESCO', 'SAINSBURY', 'ASDA', 'MORRISONS', 'WAITROSE', 'LIDL', 'ALDI', 'M&S FOOD']
          .any((m) => upperMerchant.contains(m))) {
        return 'Groceries';
      }

      if (['AMAZON', 'ARGOS', 'JOHN LEWIS', 'NEXT', 'PRIMARK', 'H&M', 'ZARA', 'MARKS & SPENCER']
          .any((m) => upperMerchant.contains(m))) {
        return 'Shopping';
      }

      if (['BOOTS', 'SUPERDRUG', 'PHARMACY', 'CHEMIST', 'NHS', 'HOSPITAL', 'CLINIC']
          .any((m) => upperMerchant.contains(m))) {
        return 'Healthcare';
      }

      if (['UBER', 'LYFT', 'TAXI', 'BUS', 'TRAIN', 'PETROL', 'SHELL', 'BP', 'ESSO']
          .any((m) => upperMerchant.contains(m))) {
        return 'Transportation';
      }
    }

    if (items.isNotEmpty) {
      final foodKeywords = ['COFFEE', 'TEA', 'SANDWICH', 'BURGER', 'PIZZA', 'MEAL', 'DRINK'];
      for (var item in items) {
        final itemName = item['name'].toString().toUpperCase();
        if (foodKeywords.any((keyword) => itemName.contains(keyword))) {
          return 'Food & Dining';
        }
      }
    }

    return 'Other';
  }

  String? _extractPaymentMethod(String text) {
    final upperText = text.toUpperCase();

    if (upperText.contains('CASH')) {
      return 'Cash';
    } else if (upperText.contains('CREDIT') || upperText.contains('VISA') || upperText.contains('MASTERCARD')) {
      return 'Credit Card';
    } else if (upperText.contains('DEBIT')) {
      return 'Debit Card';
    } else if (upperText.contains('CONTACTLESS') || upperText.contains('TAP')) {
      return 'Contactless';
    } else if (upperText.contains('APPLE PAY') || upperText.contains('GOOGLE PAY')) {
      return 'Mobile Payment';
    }

    return null;
  }

  double? _extractTaxAmount(String text) {
    final taxPattern = RegExp(r'(?:TAX|VAT|GST)[\s:]*£?(\d+\.?\d{0,2})', caseSensitive: false);
    final match = taxPattern.firstMatch(text);

    if (match != null && match.group(1) != null) {
      try {
        return double.parse(match.group(1)!);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  double _calculateParsingConfidence(Map<String, dynamic> result) {
    double confidence = 0.0;
    double maxScore = 0.0;

    if (result['merchant'] != null) {
      confidence += 20;
    }
    maxScore += 20;

    if (result['amount'] != null) {
      confidence += 30;
    }
    maxScore += 30;

    if (result['date'] != null) {
      confidence += 20;
    }
    maxScore += 20;

    if (result['items'] != null && (result['items'] as List).isNotEmpty) {
      confidence += 15;
    }
    maxScore += 15;

    if (result['category'] != null && result['category'] != 'Other') {
      confidence += 10;
    }
    maxScore += 10;

    if (result['paymentMethod'] != null) {
      confidence += 5;
    }
    maxScore += 5;

    return (confidence / maxScore);
  }
}