import 'package:flutter/material.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import '../../core/theme/app_colors.dart';
import 'buyer_feed.dart';
import 'screens/cart_screen.dart';
import 'services/cart_service.dart';
import '../mandaditos/buyer_mandadito_create_screen.dart';
import '../mandaditos/buyer_mandadito_list_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final cart = CartService.instance;

  @override
  void initState() {
    super.initState();
    cart.addListener(_onChange);
  }

  @override
  void dispose() {
    cart.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

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
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  tooltip: 'Ver carrito',
                ),
                if (cart.totalCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Center(
                        child: Text(
                          cart.totalCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
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
