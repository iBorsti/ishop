import 'dart:async';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const _kUserKey = 'auth_user_raw';

  const AuthService();

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserKey);
    if (raw == null) return null;
    try {
      return AppUser.fromRawJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (name.trim().isEmpty) throw const AuthException('Ingresa tu nombre');
    if (!_isValidEmail(email)) {
      throw const AuthException('Email no válido');
    }
    if (password.length < 4) {
      throw const AuthException('Contraseña demasiado corta');
    }
    await Future.delayed(const Duration(milliseconds: 350));
    final id =
        'u_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final user = AppUser(id: id, name: name, email: email, role: role);
    await _saveUser(user);
    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw const AuthException('Email no válido');
    }
    if (password.length < 4) {
      throw const AuthException('Contraseña demasiado corta');
    }
    await Future.delayed(const Duration(milliseconds: 320));
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserKey);
    if (raw != null) {
      final existing = AppUser.fromRawJson(raw);
      if (existing.email == email) return existing;
    }
    final user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}',
      name: email.split('@').first,
      email: email,
      role: UserRole.buyer,
    );
    await _saveUser(user);
    return user;
  }

  Future<AppUser> loginDemo(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = AppUser(
      id: 'demo_${role.name}_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Demo ${role.name}',
      email: '${role.name}@demo.app',
      role: role,
    );
    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
  }

  Future<void> _saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserKey, user.toRawJson());
  }

  bool _isValidEmail(String email) => email.contains('@');
}
