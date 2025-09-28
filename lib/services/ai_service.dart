import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/expense.dart';

class AIService {
  late final GenerativeModel _model;
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<Map<String, dynamic>> generateSpendingInsights(
    List<Expense> expenses,
  ) async {
    try {
      if (expenses.isEmpty) {
        return {
          'success': false,
          'message': 'No expenses to analyze',
        };
      }

      final prompt = _buildInsightsPrompt(expenses);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return {
        'success': true,
        'insights': response.text ?? 'No insights generated',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to generate insights: $e',
      };
    }
  }

  Future<Map<String, dynamic>> suggestBudget(
    List<Expense> expenses,
    String category,
  ) async {
    try {
      if (expenses.isEmpty) {
        return {
          'success': false,
          'message': 'No expenses data available',
        };
      }

      final categoryExpenses = expenses
          .where((e) => e.category == category)
          .toList();

      if (categoryExpenses.isEmpty) {
        return {
          'success': false,
          'message': 'No expenses found for $category',
        };
      }

      final prompt = _buildBudgetPrompt(categoryExpenses, category);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return {
        'success': true,
        'suggestion': response.text ?? 'No suggestion available',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to suggest budget: $e',
      };
    }
  }

  Future<Map<String, dynamic>> predictCategory(String description) async {
    try {
      final prompt = '''
Analyze this expense description and suggest the most appropriate category:

Description: "$description"

Categories:
- Groceries
- Food & Dining
- Transportation
- Shopping
- Entertainment
- Healthcare
- Bills & Utilities
- Travel
- Education
- Personal Care
- Other

Respond with only the category name, nothing else.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return {
        'success': true,
        'category': response.text?.trim() ?? 'Other',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to predict category: $e',
        'category': 'Other',
      };
    }
  }

  Future<Map<String, dynamic>> getSavingsTips(
    List<Expense> expenses,
  ) async {
    try {
      if (expenses.isEmpty) {
        return {
          'success': false,
          'message': 'No expenses to analyze',
        };
      }

      final prompt = _buildSavingsTipsPrompt(expenses);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return {
        'success': true,
        'tips': response.text ?? 'No tips available',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to generate savings tips: $e',
      };
    }
  }

  Future<Map<String, dynamic>> analyzeTrends(
    List<Expense> expenses,
  ) async {
    try {
      if (expenses.isEmpty) {
        return {
          'success': false,
          'message': 'No expenses to analyze',
        };
      }

      final prompt = _buildTrendsPrompt(expenses);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return {
        'success': true,
        'trends': response.text ?? 'No trends identified',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to analyze trends: $e',
      };
    }
  }

  String _buildInsightsPrompt(List<Expense> expenses) {
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final categories = expenses.map((e) => e.category).toSet().toList();

    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return '''
Analyze these expense data and provide 3-4 key insights:

Total Spending: £${totalSpent.toStringAsFixed(2)}
Number of Transactions: ${expenses.length}
Categories: ${categories.join(', ')}

Category Breakdown:
${categoryTotals.entries.map((e) => '- ${e.key}: £${e.value.toStringAsFixed(2)}').join('\n')}

Provide concise, actionable insights about spending patterns, top categories, and potential areas for improvement. Use British English and £ symbol.
''';
  }

  String _buildBudgetPrompt(List<Expense> expenses, String category) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final avgPerTransaction = total / expenses.length;

    return '''
Suggest a realistic monthly budget for "$category" based on this data:

Current Spending:
- Total: £${total.toStringAsFixed(2)}
- Transactions: ${expenses.length}
- Average per transaction: £${avgPerTransaction.toStringAsFixed(2)}

Provide a single recommended monthly budget amount with a brief explanation. Use British English and £ symbol.
''';
  }

  String _buildSavingsTipsPrompt(List<Expense> expenses) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return '''
Based on these spending patterns, provide 3-5 practical money-saving tips:

Top Spending Categories:
${sortedCategories.take(5).map((e) => '- ${e.key}: £${e.value.toStringAsFixed(2)}').join('\n')}

Total Expenses: ${expenses.length}

Provide actionable, specific tips that could help reduce spending. Use British English and £ symbol.
''';
  }

  String _buildTrendsPrompt(List<Expense> expenses) {
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => a.date.compareTo(b.date));

    final monthlyTotals = <String, double>{};
    for (final expense in sortedExpenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    return '''
Analyze spending trends from this data:

Monthly Spending:
${monthlyTotals.entries.map((e) => '- ${e.key}: £${e.value.toStringAsFixed(2)}').join('\n')}

Identify:
1. Spending trends (increasing/decreasing)
2. Seasonal patterns
3. Notable changes or anomalies

Provide a concise analysis. Use British English and £ symbol.
''';
  }
}