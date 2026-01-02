import 'package:flutter/material.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order.dart';
import '../../../core/auth/state/auth_controller.dart';

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
    final sellerId = AuthController.instance.sellerProfile?.id ?? AuthController.instance.user?.id ?? '';
    final list = await OrderService.getOrdersForSeller(sellerId);
    if (mounted) setState(() { _orders = list; _loading = false; });
  }

  Future<void> _updateStatus(String orderId, OrderStatus status) async {
    await OrderService.updateOrderStatus(orderId, status);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No hay pedidos'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final o = _orders[i];
                    return ListTile(
                      title: Text('Pedido ${o.id} - C\$ ${o.total.toStringAsFixed(0)}'),
                      subtitle: Text('Items: ${o.items.length} • Estado: ${o.status.toString().split('.').last}'),
                      trailing: PopupMenuButton<OrderStatus>(
                        onSelected: (s) => _updateStatus(o.id, s),
                        itemBuilder: (_) => OrderStatus.values.map((s) => PopupMenuItem(value: s, child: Text(s.toString().split('.').last))).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}
