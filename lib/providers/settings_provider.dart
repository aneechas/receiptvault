import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  // Currency settings
  String _currency = 'GBP';

  // Notification settings
  bool _notificationsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _receiptRemindersEnabled = true;

  // App settings
  bool _biometricEnabled = false;
  String _language = 'en';
  bool _autoBackup = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get budgetAlerts => _budgetAlertsEnabled;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  bool get receiptReminders => _receiptRemindersEnabled;
  bool get biometricEnabled => _biometricEnabled;
  String get language => _language;
  bool get autoBackup => _autoBackup;

  // Load settings from SharedPreferences
  void _loadSettings() {
    final themeString = _prefs.getString(AppConstants.themeKey);
    if (themeString != null) {
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          _isDarkMode = false;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          _isDarkMode = true;
          break;
        default:
          _themeMode = ThemeMode.system;
          _isDarkMode = false;
      }
    }

    _currency = _prefs.getString(AppConstants.currencyKey) ?? 'GBP';
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    _budgetAlertsEnabled = _prefs.getBool('budgetAlertsEnabled') ?? true;
    _receiptRemindersEnabled = _prefs.getBool('receiptRemindersEnabled') ?? true;
    _biometricEnabled = _prefs.getBool('biometricEnabled') ?? false;
    _language = _prefs.getString('language') ?? 'en';
    _autoBackup = _prefs.getBool('autoBackup') ?? true;

    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      _isDarkMode = true;
      await _prefs.setString(AppConstants.themeKey, 'dark');
    } else {
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
      await _prefs.setString(AppConstants.themeKey, 'light');
    }
    notifyListeners();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;

    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }

    await _prefs.setString(AppConstants.themeKey, themeString);
    notifyListeners();
  }

  // Set currency
  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await _prefs.setString(AppConstants.currencyKey, currency);
    notifyListeners();
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool('notificationsEnabled', enabled);
    notifyListeners();
  }

  // Toggle budget alerts
  Future<void> toggleBudgetAlerts(bool enabled) async {
    _budgetAlertsEnabled = enabled;
    await _prefs.setBool('budgetAlertsEnabled', enabled);
    notifyListeners();
  }

  // Toggle receipt reminders
  Future<void> toggleReceiptReminders(bool enabled) async {
    _receiptRemindersEnabled = enabled;
    await _prefs.setBool('receiptRemindersEnabled', enabled);
    notifyListeners();
  }

  // Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    _biometricEnabled = enabled;
    await _prefs.setBool('biometricEnabled', enabled);
    notifyListeners();
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    await _prefs.setString('language', languageCode);
    notifyListeners();
  }

  // Toggle auto backup
  Future<void> toggleAutoBackup(bool enabled) async {
    _autoBackup = enabled;
    await _prefs.setBool('autoBackup', enabled);
    notifyListeners();
  }

  // Check if first time user
  bool isFirstTime() {
    return _prefs.getBool(AppConstants.firstTimeKey) ?? true;
  }

  // Set first time completed
  Future<void> setFirstTimeCompleted() async {
    await _prefs.setBool(AppConstants.firstTimeKey, false);
    notifyListeners();
  }

  // Reset all settings
  Future<void> resetSettings() async {
    await _prefs.clear();
    _loadSettings();
  }

  // Get currency symbol
  String getCurrencySymbol() {
    final symbols = {
      'GBP': '£',
      'USD': '\$',
      'EUR': '€',
      'JPY': '¥',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'CHF': 'CHF',
      'CNY': '¥',
      'INR': '₹',
      'SGD': 'S\$',
    };
    return symbols[_currency] ?? _currency;
  }
}