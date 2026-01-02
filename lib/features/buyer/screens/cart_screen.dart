import 'package:flutter/material.dart';
import '../../buyer/services/cart_service.dart';
import '../../seller/services/seller_metrics_service.dart';
import '../../orders/models/order.dart';
import '../../orders/services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
    final items = cart.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(it.name),
                        subtitle: Text('C\$ ${it.price.toStringAsFixed(0)} • Cant: ${it.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cart.changeQuantity(it.id, it.quantity - 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => cart.changeQuantity(it.id, it.quantity + 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => cart.removeItem(it.id),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: items.length,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Total: C\$ ${cart.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(context);
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Enviar pedido'),
                              content: const Text('Enviar pedido a repartidores y vaciar el carrito?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
                                TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Enviar')),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            if (!mounted) return;
                            // Crear pedido y registrar ventas por vendedor antes de vaciar carrito
                            final now = DateTime.now();
                            final orderId = 'ord_${now.millisecondsSinceEpoch}';
                            final orderItems = items.map((it) => OrderItem(productId: it.id, name: it.name, price: it.price, quantity: it.quantity, sellerId: it.sellerId)).toList();
                            final orderTotal = items.fold<double>(0.0, (p, e) => p + e.total);
                            final order = Order(id: orderId, buyerId: '', items: orderItems, total: orderTotal, status: OrderStatus.newOrder, createdAt: now);
                            await OrderService.createOrder(order);

                            for (final it in items) {
                              final event = SaleEvent(
                                id: '${now.microsecondsSinceEpoch}_${it.id}',
                                sellerId: it.sellerId,
                                productId: it.id,
                                productName: it.name,
                                amount: it.total,
                                quantity: it.quantity,
                                createdAt: now,
                              );
                              await SellerMetricsService.recordSale(event);
                            }
                            cart.clear();
                            messenger.showSnackBar(const SnackBar(content: Text('Pedido enviado a repartidores')));
                            nav.pop();
                          }
                        },
                        child: const Text('Enviar pedido'),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        onPressed: () => cart.clear(),
                        child: const Text('Vaciar carrito'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
