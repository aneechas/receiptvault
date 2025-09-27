import 'package:intl/intl.dart';

class ReceiptParser {
  // Common receipt patterns
  final List<RegExp> _amountPatterns = [
    RegExp(r'(?:TOTAL|Total|total)[\s:]*£?(\d+\.?\d{0,2})', multiLine: true),
    RegExp(r'(?:AMOUNT|Amount)[\s:]*£?(\d+\.?\d{0,2})', multiLine: true),
    RegExp(r'(?:SUBTOTAL|Subtotal)[\s:]*£?(\d+\.?\d{0,2})', multiLine: true),
    RegExp(r'£(\d+\.?\d{0,2})', multiLine: true),
    RegExp(r'(\d+\.\d{2})[\s]*GBP', multiLine: true),
    RegExp(r'(\d+\.\d{2})[\s]*£', multiLine: true),
  ];

  final List<RegExp> _datePatterns = [
    RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})', multiLine: true),
    RegExp(r'(\d{4}[/-]\d{1,2}[/-]\d{1,2})', multiLine: true),
    RegExp(r'(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{2,4})', multiLine: true, caseSensitive: false),
  ];

  final List<RegExp> _timePatterns = [
    RegExp(r'(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AP]M)?)', multiLine: true, caseSensitive: false),
  ];

  final List<RegExp> _merchantPatterns = [
    RegExp(r'^([A-Z][A-Za-z\s&\']+)(?:\n|$)', multiLine: true),
    RegExp(r'(?:FROM|From|Merchant|MERCHANT)[\s:]*([A-Za-z\s&\']+)', multiLine: true),
  ];

  final List<String> _commonMerchants = [
    'TESCO', 'SAINSBURY', 'ASDA', 'MORRISONS', 'WAITROSE', 'LIDL', 'ALDI',
    'MARKS & SPENCER', 'M&S', 'BOOTS', 'SUPERDRUG', 'COSTA', 'STARBUCKS',
    'PRET A MANGER', 'GREGGS', 'SUBWAY', 'MCDONALDS', 'KFC', 'BURGER KING',
    'AMAZON', 'ARGOS', 'JOHN LEWIS', 'NEXT', 'PRIMARK', 'H&M', 'ZARA',
  ];

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

    // Clean the text
    text = _cleanText(text);

    // Extract merchant
    result['merchant'] = _extractMerchant(text);

    // Extract amount
    final amountData = _extractAmount(text);
    result['amount'] = amountData['amount'];
    
    // Extract date
    result['date'] = _extractDate(text);
    
    // Extract time
    result['time'] = _extractTime(text);
    
    // Extract items
    result['items'] = _extractItems(text);
    
    // Determine category based on merchant and items
    result['category'] = _determineCategory(result['merchant'], result['items']);
    
    // Extract payment method
    result['paymentMethod'] = _extractPaymentMethod(text);
    
    // Extract tax amount
    result['taxAmount'] = _extractTaxAmount(text);
    
    // Calculate confidence score
    result['confidence'] = _calculateParsingConfidence(result);

    return result;
  }

  String _cleanText(String text) {
    // Remove extra whitespace and normalize line breaks
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _extractMerchant(String text) {
    // First check for known merchants
    final upperText = text.toUpperCase();
    for (String merchant in _commonMerchants) {
      if (upperText.contains(merchant)) {
        return merchant;
      }
    }

    // Try pattern matching
    for (RegExp pattern in _merchantPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    // Try to extract from first non-empty line
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
    
    for (RegExp pattern in _amountPatterns) {
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
            // Continue to next match
          }
        }
      }
    }
    
    return {'amount': highestAmount};
  }

  DateTime? _extractDate(String text) {
    for (RegExp pattern in _datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        try {
          String dateStr = match.group(1)!;
          
          // Try different date formats
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
              // Try next format
            }
          }
        } catch (e) {
          // Continue to next match
        }
      }
    }
    
    return null;
  }

  String? _extractTime(String text) {
    for (RegExp pattern in _timePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractItems(String text) {
    List<Map<String, dynamic>> items = [];
    
    // Pattern for item lines (item name followed by price)
    final itemPattern = RegExp(r'([A-Za-z\s]+)[\s\.\-]*£?(\d+\.\d{2})', multiLine: true);
    final matches = itemPattern.allMatches(text);
    
    for (Match match in matches) {
      final itemName = match.group(1)?.trim();
      final priceStr = match.group(2);
      
      if (itemName != null && priceStr != null) {
        // Filter out common non-item words
        final nonItemWords = ['TOTAL', 'SUBTOTAL', 'TAX', 'VAT', 'CHANGE', 'CASH', 'CARD', 'BALANCE'];
        if (!nonItemWords.any((word) => itemName.toUpperCase().contains(word))) {
          try {
            final price = double.parse(priceStr);
            items.add({
              'name': itemName,
              'price': price,
              'quantity': 1, // Default quantity
            });
          } catch (e) {
            // Skip invalid price
          }
        }
      }
    }
    
    return items;
  }

  String _determineCategory(String? merchant, List<Map<String, dynamic>> items) {
    if (merchant != null) {
      final upperMerchant = merchant.toUpperCase();
      
      // Food & Dining
      if (['COSTA', 'STARBUCKS', 'PRET', 'GREGGS', 'SUBWAY', 'MCDONALDS', 'KFC', 'BURGER KING']
          .any((m) => upperMerchant.contains(m))) {
        return 'Food & Dining';
      }
      
      // Groceries
      if (['TESCO', 'SAINSBURY', 'ASDA', 'MORRISONS', 'WAITROSE', 'LIDL', 'ALDI', 'M&S FOOD']
          .any((m) => upperMerchant.contains(m))) {
        return 'Groceries';
      }
      
      // Shopping
      if (['AMAZON', 'ARGOS', 'JOHN LEWIS', 'NEXT', 'PRIMARK', 'H&M', 'ZARA', 'MARKS & SPENCER']
          .any((m) => upperMerchant.contains(m))) {
        return 'Shopping';
      }
      
      // Healthcare
      if (['BOOTS', 'SUPERDRUG', 'PHARMACY', 'CHEMIST', 'NHS', 'HOSPITAL', 'CLINIC']
          .any((m) => upperMerchant.contains(m))) {
        return 'Healthcare';
      }
      
      // Transportation
      if (['UBER', 'LYFT', 'TAXI', 'BUS', 'TRAIN', 'PETROL', 'SHELL', 'BP', 'ESSO']
          .any((m) => upperMerchant.contains(m))) {
        return 'Transportation';
      }
    }
    
    // If no merchant match, try to determine from items
    if (items.isNotEmpty) {
      // Check for food-related items
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
    // Pattern for tax/VAT amounts
    final taxPattern = RegExp(r'(?:TAX|VAT|GST)[\s:]*£?(\d+\.?\d{0,2})', multiLine: true, caseSensitive: false);
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
    
    // Check merchant (20 points)
    if (result['merchant'] != null) {
      confidence += 20;
    }
    maxScore += 20;
    
    // Check amount (30 points - most important)
    if (result['amount'] != null) {
      confidence += 30;
    }
    maxScore += 30;
    
    // Check date (20 points)
    if (result['date'] != null) {
      confidence += 20;
    }
    maxScore += 20;
    
    // Check items (15 points)
    if (result['items'] != null && (result['items'] as List).isNotEmpty) {
      confidence += 15;
    }
    maxScore += 15;
    
    // Check category (10 points)
    if (result['category'] != null && result['category'] != 'Other') {
      confidence += 10;
    }
    maxScore += 10;
    
    // Check payment method (5 points)
    if (result['paymentMethod'] != null) {
      confidence += 5;
    }
    maxScore += 5;
    
    return (confidence / maxScore);
  }
}