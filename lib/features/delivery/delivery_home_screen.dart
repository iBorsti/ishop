import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import 'delivery_dashboard.dart';
import '../mandaditos/delivery_mandaditos_list_screen.dart';

class DeliveryHomeScreen extends StatelessWidget {
  const DeliveryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.delivery,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery'),
          actions: [
            IconButton(
              icon: const Icon(Icons.assignment),
              tooltip: 'Mandaditos',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DeliveryMandaditosListScreen(),
                  ),
                );
              },
            ),
            const LogoutButton(),
          ],
        ),
        body: const DeliveryDashboard(),
      ),
    );
  }
}
