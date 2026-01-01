import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'state/auth_controller.dart';
import '../../features/buyer/buyer_home_screen.dart';
import '../../features/seller/seller_home_screen.dart';
import '../../features/delivery/delivery_home_screen.dart';
import '../../features/fleet/fleet_home_screen.dart';
import '../../features/admin/admin_home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/onboarding_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthController _ctrl = AuthController.instance;
  UserRole? _lastRole;
  bool _navigating = false;
  Future<bool>? _onboardingFuture;
  String? _onboardingUserId;

  Widget _homeFor(UserRole role) {
    switch (role) {
      case UserRole.seller:
        return const SellerHomeScreen();
      case UserRole.delivery:
        return const DeliveryHomeScreen();
      case UserRole.fleet:
        return const FleetHomeScreen();
      case UserRole.admin:
        return const AdminHomeScreen();
      case UserRole.buyer:
        return const BuyerHomeScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChange);
    _ctrl.init();
  }

  void _onChange() => setState(() {
        if (_ctrl.status != AuthStatus.authenticated) {
          _onboardingFuture = null;
          _onboardingUserId = null;
        }
      });

  void _navigateToHome(UserRole role) {
    if (_navigating && _lastRole == role) return;
    _navigating = true;
    _lastRole = role;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _homeFor(role)),
        (_) => false,
      );
      _navigating = false;
    });
  }

  OnboardingRole? _onboardingRoleFor(UserRole role) {
    switch (role) {
      case UserRole.delivery:
        return OnboardingRole.delivery;
      case UserRole.fleet:
        return OnboardingRole.fleet;
      case UserRole.buyer:
        return OnboardingRole.buyer;
      case UserRole.seller:
      case UserRole.admin:
        return null;
    }
  }

  void _ensureOnboardingFuture(AppUser user, OnboardingRole role) {
    if (_onboardingFuture != null && _onboardingUserId == user.id) return;
    _onboardingUserId = user.id;
    _onboardingFuture =
        OnboardingService.hasCompletedOnboarding(user.id, role);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_ctrl.status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        final user = _ctrl.user!;
        final onboardingRole = _onboardingRoleFor(user.role);
        if (onboardingRole == null) {
          _navigateToHome(user.role);
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        _ensureOnboardingFuture(user, onboardingRole);
        return FutureBuilder<bool>(
          future: _onboardingFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final completed = snapshot.data ?? false;
            if (!completed) {
              return OnboardingScreen(
                role: onboardingRole,
                userId: user.id,
                onFinished: () => _navigateToHome(user.role),
              );
            }
            _navigateToHome(user.role);
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
    }
  }
}
