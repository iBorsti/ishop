import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/auth/models/app_user.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Selecciona un rol'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _RoleCard(
              role: UserRole.buyer,
              icon: Icons.shopping_cart,
              title: 'Comprar',
              subtitle: 'Explora productos',
              gradient: AppGradients.buyer,
            ),
            _RoleCard(
              role: UserRole.seller,
              icon: Icons.storefront,
              title: 'Vender',
              subtitle: 'Gestiona tu tienda',
              gradient: AppGradients.seller,
            ),
            _RoleCard(
              role: UserRole.delivery,
              icon: Icons.delivery_dining,
              title: 'Delivery',
              subtitle: 'Recoge y entrega',
              gradient: AppGradients.delivery,
            ),
            _RoleCard(
              role: UserRole.fleet,
              icon: Icons.directions_bike,
              title: 'Flota',
              subtitle: 'Administra vehículos',
              gradient: AppGradients.fleet,
            ),
            _RoleCard(
              role: UserRole.admin,
              icon: Icons.admin_panel_settings,
              title: 'Admin',
              subtitle: 'Panel administrativo',
              gradient: AppGradients.admin,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, widget.role),
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.98 : 1.0,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.hardEdge,
          child: Container(
            decoration: BoxDecoration(gradient: widget.gradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
