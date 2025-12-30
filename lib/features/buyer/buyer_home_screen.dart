import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import 'buyer_feed.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.buyer,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          actions: const [LogoutButton()],
        ),
        body: const BuyerFeed(),
      ),
    );
  }
}
