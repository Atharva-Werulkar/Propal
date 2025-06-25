import 'dart:developer';

import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../repos/chat_repo.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const Uuid _uuid = Uuid();

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate using biometrics
  static Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access Propal',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false, // Changed to false to avoid blocking
        ),
      );
      return didAuthenticate;
    } catch (e) {
      // Handle specific exceptions
      print('Biometric authentication error: $e');
      return false;
    }
  }

  // Create a new user (simple implementation)
  static Future<User> createUser({
    required String name,
    required String email,
    String? profileImagePath,
  }) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
      email: email,
      profileImagePath: profileImagePath,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await SecureStorageService.saveUser(user);
    return user;
  }

  // Update user login time
  static Future<void> updateLastLogin(User user) async {
    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
    await SecureStorageService.saveUser(updatedUser);
  }

  // Login user
  static Future<bool> login() async {
    final user = await SecureStorageService.getCurrentUser();
    if (user == null) return false;

    final isBiometricEnabled = await SecureStorageService.isBiometricEnabled();

    log('User ${user.name} is trying to log in. Biometric enabled: $isBiometricEnabled');

    if (isBiometricEnabled && await isBiometricAvailable()) {
      final success = await authenticateWithBiometrics();
      if (success) {
        await updateLastLogin(user);
        return true;
      }
      return false;
    }

    // If biometric is not enabled, just update login time
    await updateLastLogin(user);
    return true;
  }

  // Logout user
  static Future<void> logout() async {
    // We don't clear user data, just mark as logged out
    // User data persists for next login
  }

  // Check if user is logged in (simplified - check if user exists)
  static Future<bool> isLoggedIn() async {
    final user = await SecureStorageService.getCurrentUser();
    return user != null;
  }
}
