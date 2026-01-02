import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import '../../core/theme/app_colors.dart';
import 'buyer_feed.dart';
import '../mandaditos/buyer_mandadito_create_screen.dart';
import '../mandaditos/buyer_mandadito_list_screen.dart';

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
          backgroundColor: AppColors.turquoise,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add_task),
                      title: const Text('Publicar mandadito'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BuyerMandaditoCreateScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: const Text('Ver mis mandaditos'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BuyerMandaditoListScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
