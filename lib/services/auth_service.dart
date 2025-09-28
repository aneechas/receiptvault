class User {
  final String uid;
  final String? email;
  final String? displayName;

  User({
    required this.uid,
    this.email,
    this.displayName,
  });
}

class AuthService {
  Stream<User?> get authStateChanges => Stream.value(null);

  User? get currentUser => null;

  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled. Re-add Firebase to enable authentication.',
    };
  }

  Future<Map<String, dynamic>> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled. Re-add Firebase to enable registration.',
    };
  }

  Future<void> signOut() async {
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled.',
    };
  }

  Future<Map<String, dynamic>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled.',
    };
  }

  Future<Map<String, dynamic>> updateEmail(
    String currentPassword,
    String newEmail,
  ) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled.',
    };
  }

  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled.',
    };
  }

  Future<Map<String, dynamic>> deleteAccount(String password) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled.',
    };
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    return {
      'success': false,
      'message': 'Firebase authentication is disabled.',
    };
  }
}