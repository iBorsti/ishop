import 'package:flutter/material.dart';
import '../../buyer/services/cart_service.dart';

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
