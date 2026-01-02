import 'package:flutter/material.dart';

import '../models/seller_post.dart';
import '../services/seller_post_service.dart';
import '../../../core/auth/state/auth_controller.dart';

class SellerPromotionsScreen extends StatefulWidget {
  const SellerPromotionsScreen({super.key});

  @override
  State<SellerPromotionsScreen> createState() => _SellerPromotionsScreenState();
}

class _SellerPromotionsScreenState extends State<SellerPromotionsScreen> {
  List<SellerPost> _promos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  Future<void> _loadPromos() async {
    setState(() => _loading = true);
    final userId = AuthController.instance.user?.id ?? '';
    if (userId.isEmpty) {
      setState(() {
        _promos = [];
        _loading = false;
      });
      return;
    }
    final posts = await SellerPostService.getMyPosts(userId);
    setState(() {
      _promos = posts.where((p) => p.type == SellerPostType.discount).toList();
      _loading = false;
    });
  }

  Future<void> _createPromo() async {
    final descCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear promoción'),
        content: TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Crear')),
        ],
      ),
    );
    if (ok != true) return;
    final userId = AuthController.instance.user?.id ?? '';
    if (userId.isEmpty) return;
    await SellerPostService.createDiscount(userId: userId, description: descCtrl.text.trim(), sellerName: AuthController.instance.user?.name ?? 'Vendedor');
    await _loadPromos();
  }

  Future<void> _toggleActive(SellerPost p) async {
    final userId = AuthController.instance.user?.id ?? '';
    if (userId.isEmpty) return;
    await SellerPostService.updatePost(
      userId: userId,
      postId: p.id,
      description: p.description,
      title: p.title,
      price: p.price,
      imageUrl: p.imageUrl,
      sellerName: p.sellerName,
      sellerId: p.sellerId,
      active: !p.active,
    );
    await _loadPromos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promociones')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPromo,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _promos.isEmpty
                ? const Center(child: Text('No hay promociones'))
                : ListView.builder(
                    itemCount: _promos.length,
                    itemBuilder: (context, idx) {
                      final p = _promos[idx];
                      return ListTile(
                        title: Text(p.description),
                        subtitle: Text('Activo: ${p.active ? 'Sí' : 'No'}'),
                        trailing: TextButton(
                          onPressed: () => _toggleActive(p),
                          child: Text(p.active ? 'Pausar' : 'Activar'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
