import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'state/auth_controller.dart';
import '../../features/buyer/buyer_home_screen.dart';
import '../../features/seller/seller_home_screen.dart';
import '../../features/delivery/delivery_home_screen.dart';
import '../../features/fleet/fleet_home_screen.dart';
import '../../features/admin/admin_home_screen.dart';
import '../../features/auth/screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthController _ctrl = AuthController.instance;
  UserRole? _lastRole;
  bool _navigating = false;

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

  void _onChange() => setState(() {});

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
        _navigateToHome(_ctrl.user!.role);
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
