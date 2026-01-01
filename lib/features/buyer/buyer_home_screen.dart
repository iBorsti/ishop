import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import 'buyer_feed.dart';
import '../mandaditos/buyer_mandadito_create_screen.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.buyer,
      allowIfUnauthenticated: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Buscar',
            ),
            const LogoutButton(),
          ],
        ),
        body: const BuyerFeed(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BuyerMandaditoCreateScreen(),
              ),
            );
          },
          icon: const Icon(Icons.assignment),
          label: const Text('Mandaditos'),
        ),
      ),
    );
  }
}
