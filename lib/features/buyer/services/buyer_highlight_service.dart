import '../../seller/services/seller_post_service.dart';

class BuyerHighlightService {
  static Future<List<BuyerHighlight>> getHighlights() {
    return SellerPostService.getDiscountHighlights();
  }
}
