import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unauthenticated, loading, authenticated }

class AuthController extends ChangeNotifier {
  AuthController._private();

  static final AuthController instance = AuthController._private();

  final AuthService _service = const AuthService();

  AuthStatus status = AuthStatus.unauthenticated;
  AppUser? user;

  Future<void> init() async {
    status = AuthStatus.loading;
    notifyListeners();
    final u = await _service.getCurrentUser();
    if (u == null) {
      status = AuthStatus.unauthenticated;
    } else {
      user = u;
      status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    status = AuthStatus.loading;
    notifyListeners();
    final u = await _service.login(email: email, password: password);
    user = u;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    status = AuthStatus.loading;
    notifyListeners();
    final u = await _service.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    user = u;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    status = AuthStatus.loading;
    notifyListeners();
    await _service.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
