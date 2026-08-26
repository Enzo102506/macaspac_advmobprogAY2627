import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'saved_user';

  // LAB ACTIVITY 4 - ENHANCEMENT 2:
  // Authenticate the user through the DummyJSON login endpoint and save the
  // user result so the splash screen can recover the active session.
  Future<User> login({required String username, required String password}) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid login response.');
      }

      final user = User.fromJson(data);
      await saveUser(user);
      return user;
    }

    try {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? 'Invalid username or password.';
      throw Exception(message);
    } on FormatException {
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);

    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return User.fromJson(decoded);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
