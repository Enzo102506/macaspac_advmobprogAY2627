import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const String _userKey = 'saved_user';
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

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

      final user = User.fromJson(data).copyWith(loginType: 'dummyjson');
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

  Future<User> signIn({
    required String emailOrUsername,
    required String password,
  }) async {
    final value = emailOrUsername.trim();

    if (value.isEmpty) {
      throw Exception('Please enter your email or username.');
    }

    try {
      return await _signInWithFirebase(email: value, password: password);
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'invalid-email' ||
          error.code == 'user-not-found' ||
          error.code == 'wrong-password') {
        return login(username: value, password: password);
      }
      throw Exception(_messageFromFirebaseError(error));
    }
  }

  Future<User> createAccount({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String emailAddress,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Account creation failed.');
      }

      final displayName = username.trim();
      await firebaseUser.updateDisplayName(displayName);

      final user = User(
        id: 0,
        username: displayName,
        email: firebaseUser.email ?? emailAddress.trim(),
        firstName: fName.trim(),
        lastName: lName.trim(),
        gender: '',
        image: firebaseUser.photoURL ?? '',
        token: await firebaseUser.getIdToken() ?? '',
        uid: firebaseUser.uid,
        loginType: 'firebase',
        age: age,
        contactNo: contactNo.trim(),
      );

      await saveUser(user);
      return user;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw Exception(_messageFromFirebaseError(error));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await clearSession();
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<User?> getUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return getSavedUser();
    }

    final profile = User(
      id: 0,
      username: currentUser.displayName?.trim().isNotEmpty == true
          ? currentUser.displayName!
          : (currentUser.email ?? '').split('@').first,
      email: currentUser.email ?? '',
      firstName: '',
      lastName: '',
      gender: '',
      image: currentUser.photoURL ?? '',
      token: await currentUser.getIdToken() ?? '',
      uid: currentUser.uid,
      loginType: 'firebase',
    );

    await saveUser(profile);
    return profile;
  }

  Future<void> updateUsername(String newUsername) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No active Firebase user found.');
    }

    final cleaned = newUsername.trim();
    if (cleaned.isEmpty) {
      throw Exception('Username cannot be empty.');
    }

    await currentUser.updateDisplayName(cleaned);

    final savedUser = await getSavedUser();
    if (savedUser != null) {
      final updated = savedUser.copyWith(
        username: cleaned,
        loginType: 'firebase',
        uid: currentUser.uid,
      );
      await saveUser(updated);
    }
  }

  Future<void> deleteAccount({required String password}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No active Firebase user found.');
    }

    if (currentUser.email == null || currentUser.email!.isEmpty) {
      throw Exception('Email address is missing.');
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: currentUser.email!,
      password: password.trim(),
    );

    await currentUser.reauthenticateWithCredential(credential);
    await currentUser.delete();
    await clearSession();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No active Firebase user found.');
    }

    if (currentUser.email == null || currentUser.email!.isEmpty) {
      throw Exception('Email address is missing.');
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: currentUser.email!,
      password: currentPassword.trim(),
    );

    await currentUser.reauthenticateWithCredential(credential);
    await currentUser.updatePassword(newPassword.trim());
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

  Future<User> _signInWithFirebase({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase sign in failed.');
    }

    final user = User(
      id: 0,
      username: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!
          : (firebaseUser.email ?? '').split('@').first,
      email: firebaseUser.email ?? '',
      firstName: '',
      lastName: '',
      gender: '',
      image: firebaseUser.photoURL ?? '',
      token: await firebaseUser.getIdToken() ?? '',
      uid: firebaseUser.uid,
      loginType: 'firebase',
    );

    await saveUser(user);
    return user;
  }

  String _messageFromFirebaseError(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'requires-recent-login':
        return 'Please sign in again and try this action.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}
