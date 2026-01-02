class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String sellerId;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.sellerId = '',
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'sellerId': sellerId,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as int?) ?? 1,
      sellerId: map['sellerId'] as String? ?? '',
    );
  }
}
