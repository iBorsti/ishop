import 'package:flutter/material.dart';

import '../../../core/auth/state/auth_controller.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sellerId = AuthController.instance.user?.id ?? '';
    final list = await OrderService.getOrdersForSeller(sellerId);
    if (!mounted) return;
    setState(() {
      _orders = list.reversed.toList();
      _loading = false;
    });
  }

  Future<void> _changeStatus(Order o, OrderStatus s) async {
    await OrderService.updateOrderStatus(o.id, s);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado: ${s.name}')));
    await _load();
  }

  void _showDetails(Order o) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pedido ${o.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total: C\$ ${o.total.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              ...o.items.map((it) => ListTile(
                    dense: true,
                    title: Text(it.name),
                    subtitle: Text('Cant: ${it.quantity} • C\$ ${it.price.toStringAsFixed(0)}'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')), 
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No hay pedidos todavía'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final o = _orders[i];
                      final sellerItems = o.items.where((it) => it.sellerId == (AuthController.instance.user?.id ?? '')).toList();
                      final subtitle = '${sellerItems.length} artículo(s) • C\$ ${sellerItems.fold<double>(0, (p, e) => p + e.price * e.quantity).toStringAsFixed(0)}';
                      return ListTile(
                        title: Text('Pedido ${o.id}'),
                        subtitle: Text(subtitle),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            switch (v) {
                              case 'aceptar':
                                await _changeStatus(o, OrderStatus.accepted);
                                break;
                              case 'preparar':
                                await _changeStatus(o, OrderStatus.preparing);
                                break;
                              case 'enviado':
                                await _changeStatus(o, OrderStatus.sent);
                                break;
                              case 'completado':
                                await _changeStatus(o, OrderStatus.completed);
                                break;
                              case 'cancelar':
                                await _changeStatus(o, OrderStatus.cancelled);
                                break;
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'aceptar', child: Text('Aceptar')),
                            const PopupMenuItem(value: 'preparar', child: Text('Marcar preparando')),
                            const PopupMenuItem(value: 'enviado', child: Text('Marcar enviado')),
                            const PopupMenuItem(value: 'completado', child: Text('Marcar completado')),
                            const PopupMenuItem(value: 'cancelar', child: Text('Cancelar')),
                          ],
                        ),
                        onTap: () => _showDetails(o),
                      );
                    },
                  ),
                ),
    );
  }
}

