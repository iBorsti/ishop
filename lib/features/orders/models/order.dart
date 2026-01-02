import 'dart:convert';

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String sellerId;

  OrderItem({required this.productId, required this.name, required this.price, required this.quantity, required this.sellerId});

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'sellerId': sellerId,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productId: m['productId'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
        quantity: (m['quantity'] as int),
        sellerId: m['sellerId'] as String,
      );
}

enum OrderStatus { newOrder, accepted, preparing, sent, completed, cancelled }

class Order {
  final String id;
  final String buyerId;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;

  Order({required this.id, required this.buyerId, required this.items, required this.total, required this.status, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'buyerId': buyerId,
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'status': status.toString(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Order.fromMap(Map<String, dynamic> m) => Order(
        id: m['id'] as String,
        buyerId: m['buyerId'] as String,
        items: (m['items'] as List<dynamic>).map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e))).toList(),
        total: (m['total'] as num).toDouble(),
        status: OrderStatus.values.firstWhere((v) => v.toString() == (m['status'] as String), orElse: () => OrderStatus.newOrder),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
