import '../models/product.dart';

class BuyerService {
  static List<Product> getFeedProducts() {
    return [
      Product(
        id: '1',
        name: 'Queso fresco',
        description: 'Media libra de queso fresco del mercado',
        price: 120,
        imageUrl: '',
        sellerName: 'Doña Marta',
        sellerId: 'seller_1',
      ),
      Product(
        id: '2',
        name: 'Pollo frito',
        description: 'Combo de pollo frito',
        price: 250,
        imageUrl: '',
        sellerName: 'Pollos El Buen Sabor',
        sellerId: 'seller_2',
      ),
    ];
  }
}
