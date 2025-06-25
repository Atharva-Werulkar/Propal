import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/chat_model.dart';

class SecureStorageService {
  // User Management
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  // Chat History Management
  static Future<void> saveChatSessions(List<PropalChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString('chat_sessions', jsonEncode(sessionsJson));
  }

  static Future<List<PropalChatSession>> getChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('chat_sessions');
    if (sessionsJson != null) {
      final List<dynamic> sessions = jsonDecode(sessionsJson);
      return sessions.map((s) => PropalChatSession.fromJson(s)).toList();
    }
    return [];
  }

  static Future<void> saveChatSession(PropalChatSession session) async {
    final sessions = await getChatSessions();
    final existingIndex = sessions.indexWhere((s) => s.id == session.id);

    if (existingIndex != -1) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }

    await saveChatSessions(sessions);
  }

  static Future<void> deleteChatSession(String sessionId) async {
    final sessions = await getChatSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await saveChatSessions(sessions);
  }

  // App Settings
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme);
  }

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_theme') ?? 'dark';
  }
}
