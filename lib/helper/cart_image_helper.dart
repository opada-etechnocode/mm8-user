import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/domain/models/order_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';

class CartImageHelper {
  static String? _colorKeyFromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    if (code.startsWith('#') && code.length >= 7) {
      return code.substring(1, 7).toUpperCase();
    }
    return code.toUpperCase();
  }

  static String? _resolveColorImagePath(
    String? color,
    List<ColorImagesFullUrl>? colorImages,
  ) {
    final colorKey = _colorKeyFromCode(color);
    if (colorKey == null || colorImages == null || colorImages.isEmpty) {
      return null;
    }

    for (final entry in colorImages) {
      if (entry.color?.toUpperCase() == colorKey) {
        final path = entry.imageName?.path;
        if (path != null && path.isNotEmpty) {
          return path;
        }
      }
    }

    return null;
  }

  static String? getDisplayImagePath(CartModel cart) {
    return _resolveColorImagePath(cart.color, cart.productInfo?.colorImagesFullUrl) ??
        cart.productInfo?.thumbnailFullUrl?.path ??
        cart.thumbnailFullUrl?.path;
  }

  static String? getOrderDisplayImagePath(OrderDetailsModel order) {
    return _resolveColorImagePath(order.color, order.productDetails?.colorImagesFullUrl) ??
        order.productDetails?.thumbnailFullUrl?.path;
  }
}
