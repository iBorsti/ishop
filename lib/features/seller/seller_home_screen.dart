import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/config/app_env.dart';
import '../../core/auth/widgets/logout_button.dart';
import '../../core/auth/widgets/role_guard.dart';
import '../../core/widgets/confirm_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/seller_post.dart';
import 'services/seller_post_service.dart';
import 'seller_create_discount_screen.dart';
import 'seller_create_product_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  late Future<List<SellerPost>> _future;
  String _userId = '';
  bool _open = true;

  @override
  void initState() {
    super.initState();
    _userId = AuthController.instance.user?.id ?? '';
    _future = _load();
    _loadOpenState();
  }

  Future<List<SellerPost>> _load() async {
    if (_userId.isEmpty) return [];
    return SellerPostService.getMyPosts(_userId);
  }

  Future<void> _loadOpenState() async {
    if (_userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'seller_open_${AppConfig.env.name}_$_userId';
    final value = prefs.getBool(key);
    setState(() => _open = value ?? true);
  }

  Future<void> _toggleOpen(bool value) async {
    if (_userId.isEmpty) return;
    setState(() => _open = value);
    final prefs = await SharedPreferences.getInstance();
    final key = 'seller_open_${AppConfig.env.name}_$_userId';
    await prefs.setBool(key, value);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _delete(String id) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Eliminar publicación',
      message: '¿Deseas eliminar esta publicación?',
      confirmText: 'Eliminar',
    );
    if (confirmed != true) return;
    await SellerPostService.deletePost(userId: _userId, postId: id);
    if (!mounted) return;
    _refresh();
  }

  Future<void> _openCreateProduct({SellerPost? initial}) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SellerCreateProductScreen(initial: initial),
      ),
    );
    if (created == true) _refresh();
  }

  Future<void> _openCreateDiscount({SellerPost? initial}) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SellerCreateDiscountScreen(initial: initial),
      ),
    );
    if (created == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.seller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vendedor'),
          actions: const [LogoutButton()],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<SellerPost>>(
              future: _future,
              builder: (context, snapshot) {
                final posts = snapshot.data ?? [];
                final activeCount = posts.where((p) => p.active).length;
                final todayCount = posts
                    .where((p) => _isToday(p.createdAt))
                    .length;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Header(
                      userId: _userId,
                      open: _open,
                      onToggleOpen: _toggleOpen,
                    ),
                    const SizedBox(height: 12),
                    _QuickActions(
                      onProduct: () => _openCreateProduct(),
                      onDiscount: () => _openCreateDiscount(),
                    ),
                    const SizedBox(height: 12),
                    _MetricsCard(
                      active: activeCount,
                      today: todayCount,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Publicaciones activas',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (!_open)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Tu tienda está cerrada. Al abrirla volverás a mostrar tus publicaciones.'),
                      )
                    else if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ))
                    else if (posts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Aún no publicas nada')),
                      )
                    else
                      ...posts.map((p) => _SellerPostCard(
                            post: p,
                            onEdit: () {
                              if (p.type == SellerPostType.product) {
                                _openCreateProduct(initial: p);
                              } else {
                                _openCreateDiscount(initial: p);
                              }
                            },
                            onDelete: () => _delete(p.id),
                          )),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class _Header extends StatelessWidget {
  final String userId;
  final bool open;
  final ValueChanged<bool> onToggleOpen;

  const _Header({
    required this.userId,
    required this.open,
    required this.onToggleOpen,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.user;
    final name = user?.name ?? 'Mi negocio';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Categoría: Comida'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: open ? Colors.green : Colors.red,
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(open ? 'Abierto' : 'Cerrado'),
                      const SizedBox(width: 12),
                      Switch(
                        value: open,
                        onChanged: onToggleOpen,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onProduct;
  final VoidCallback onDiscount;

  const _QuickActions({
    required this.onProduct,
    required this.onDiscount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onProduct,
            icon: const Icon(Icons.add_box),
            label: const Text('Publicar producto'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDiscount,
            icon: const Icon(Icons.local_offer),
            label: const Text('Publicar descuento'),
          ),
        ),
      ],
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final int active;
  final int today;

  const _MetricsCard({required this.active, required this.today});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Metric(label: 'Publicaciones activas', value: active.toString()),
            _Metric(label: 'Publicadas hoy', value: today.toString()),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SellerPostCard extends StatelessWidget {
  final SellerPost post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SellerPostCard({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  Color _badgeColor() {
    switch (post.type) {
      case SellerPostType.product:
        return Colors.amber.shade200;
      case SellerPostType.discount:
        return Colors.blue.shade200;
    }
  }

  String _badgeText() {
    switch (post.type) {
      case SellerPostType.product:
        return 'Producto';
      case SellerPostType.discount:
        return 'Descuento';
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM, HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _badgeColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_badgeText()),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (post.type == SellerPostType.product && post.price != null)
                        Text('C\$ ${post.price!.toStringAsFixed(0)}'),
                      Text(
                        'Publicado: ${df.format(post.createdAt)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
