class AppConstants {
  // App Info
  static const String appName = 'ReceiptVault';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-Powered Receipt Scanner & Expense Tracker';
  
  // Database
  static const String databaseName = 'receiptvault.db';
  static const int databaseVersion = 1;
  
  // Tables
  static const String expensesTable = 'expenses';
  static const String categoriesTable = 'categories';
  static const String receiptsTable = 'receipts';
  
  // Shared Preferences Keys
  static const String firstTimeKey = 'isFirstTime';
  static const String themeKey = 'theme';
  static const String currencyKey = 'currency';
  static const String userIdKey = 'userId';
  static const String premiumKey = 'isPremium';
  
  // API Endpoints
  static const String exchangeRateApiUrl = 'https://api.exchangerate-api.com/v4/latest/';
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/';
  
  // Subscription Tiers
  static const String tierFree = 'free';
  static const String tierPremium = 'premium';
  static const String tierBusiness = 'business';
  
  // Limits
  static const int freeReceiptsLimit = 20;
  static const int premiumReceiptsLimit = 500;
  static const int businessReceiptsLimit = -1; // Unlimited
  
  // Categories
  static const List<String> defaultCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Business',
    'Personal Care',
    'Groceries',
    'Other',
  ];
  
  // Category Icons
  static const Map<String, String> categoryIcons = {
    'Food & Dining': '🍽️',
    'Transportation': '🚗',
    'Shopping': '🛍️',
    'Entertainment': '🎬',
    'Bills & Utilities': '💡',
    'Healthcare': '🏥',
    'Education': '📚',
    'Travel': '✈️',
    'Business': '💼',
    'Personal Care': '💆',
    'Groceries': '🛒',
    'Other': '📌',
  };
  
  // Currencies
  static const List<String> supportedCurrencies = [
    'GBP', 'USD', 'EUR', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'INR', 'SGD'
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp amountRegex = RegExp(
    r'^\d+\.?\d{0,2}$',
  );
  static final RegExp dateRegex = RegExp(
    r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})$',
  );
}