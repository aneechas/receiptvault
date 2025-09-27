class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String subscriptionTier;
  final DateTime? subscriptionExpiry;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.subscriptionTier = 'free',
    this.subscriptionExpiry,
    this.preferences,
    required this.createdAt,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'subscriptionTier': subscriptionTier,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      subscriptionTier: map['subscriptionTier'] ?? 'free',
      subscriptionExpiry: map['subscriptionExpiry'] != null
          ? DateTime.parse(map['subscriptionExpiry'])
          : null,
      preferences: map['preferences'] != null
          ? Map<String, dynamic>.from(map['preferences'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: DateTime.parse(map['lastLogin']),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? subscriptionTier,
    DateTime? subscriptionExpiry,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  bool get isPremium => subscriptionTier != 'free';
  bool get isBusinessTier => subscriptionTier == 'business';
}