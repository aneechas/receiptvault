import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _currentUser?.isPremium ?? false;
  bool get isBusinessTier => _currentUser?.isBusinessTier ?? false;
  String get subscriptionTier => _currentUser?.subscriptionTier ?? 'free';

  // Set current user
  void setUser(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    _error = null;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement Firebase authentication
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // For now, create a demo user
      final user = User(
        id: 'demo_user_123',
        email: email,
        displayName: 'Demo User',
        subscriptionTier: 'free',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      _currentUser = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement Firebase authentication
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      final user = User(
        id: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        subscriptionTier: 'free',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      _currentUser = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    if (_currentUser == null) return false;

    try {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Upgrade subscription
  Future<bool> upgradeSubscription(String tier) async {
    if (_currentUser == null) return false;

    try {
      final expiry = DateTime.now().add(const Duration(days: 30));
      _currentUser = _currentUser!.copyWith(
        subscriptionTier: tier,
        subscriptionExpiry: expiry,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check subscription status
  bool isSubscriptionActive() {
    if (_currentUser == null) return false;
    if (_currentUser!.subscriptionTier == 'free') return true;

    if (_currentUser!.subscriptionExpiry != null) {
      return _currentUser!.subscriptionExpiry!.isAfter(DateTime.now());
    }

    return false;
  }

  // Get subscription limits
  int getReceiptLimit() {
    if (_currentUser == null) return 20; // Free tier limit

    switch (_currentUser!.subscriptionTier) {
      case 'free':
        return 20;
      case 'premium':
        return 500;
      case 'business':
        return -1; // Unlimited
      default:
        return 20;
    }
  }

  // Update preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      preferences: {...?_currentUser!.preferences, ...preferences},
    );
    notifyListeners();
  }

  // Get preference value
  dynamic getPreference(String key, {dynamic defaultValue}) {
    return _currentUser?.preferences?[key] ?? defaultValue;
  }
}