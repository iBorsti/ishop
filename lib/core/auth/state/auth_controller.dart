import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/seller_profile.dart';
import '../services/auth_service.dart';

enum AuthStatus { unauthenticated, loading, authenticated }

class AuthController extends ChangeNotifier {
  AuthController._private();

  static final AuthController instance = AuthController._private();

  final AuthService _service = const AuthService();

  AuthStatus status = AuthStatus.unauthenticated;
  AppUser? user;
  SellerProfile? sellerProfile;

  Future<void> init() async {
    status = AuthStatus.loading;
    notifyListeners();
    final u = await _service.getCurrentUser();
    if (u == null) {
      status = AuthStatus.unauthenticated;
    } else {
      user = u;
      if (user?.role == UserRole.seller) await _loadSellerProfile(user!.id);
      status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    status = AuthStatus.loading;
    notifyListeners();
    final u = await _service.login(email: email, password: password);
    user = u;
    if (user?.role == UserRole.seller) await _loadSellerProfile(user!.id);
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
    if (user?.role == UserRole.seller) {
      sellerProfile = SellerProfile(type: SellerType.individual, displayName: user?.name);
      await _saveSellerProfile(user!.id);
    }
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> loginDemo(UserRole role) async {
    status = AuthStatus.loading;
    notifyListeners();
    final u = await _service.loginDemo(role);
    user = u;
    if (user?.role == UserRole.seller) await _loadSellerProfile(user!.id);
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    status = AuthStatus.loading;
    notifyListeners();
    await _service.logout();
    user = null;
    sellerProfile = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _loadSellerProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'seller_profile_$userId';
      final raw = prefs.getString(key);
      if (raw == null) {
        sellerProfile = SellerProfile(type: SellerType.individual, displayName: user?.name);
      } else {
        sellerProfile = SellerProfile.fromRawJson(raw);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveSellerProfile(String userId) async {
    if (sellerProfile == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'seller_profile_$userId';
    await prefs.setString(key, sellerProfile!.toRawJson());
  }

  Future<void> updateSellerProfile(SellerProfile profile) async {
    sellerProfile = profile;
    if (user != null) await _saveSellerProfile(user!.id);
    notifyListeners();
  }
}
