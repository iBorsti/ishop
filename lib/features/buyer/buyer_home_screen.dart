import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/auth/widgets/unauthorized_screen.dart';
import '../../core/auth/widgets/logout_button.dart';
import 'buyer_feed.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.instance;
    if (ctrl.user?.role != UserRole.buyer) return const UnauthorizedScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: const [LogoutButton()],
      ),
      body: const BuyerFeed(),
    );
  }
}
