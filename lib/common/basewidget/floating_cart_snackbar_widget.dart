import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

void showFloatingCartSnackBar(BuildContext context) {
  final cartController = Provider.of<CartController>(context, listen: false);
  int totalQuantity = 0;
  double totalAmount = 0;

  for (final item in cartController.cartList) {
    totalQuantity += item.quantity ?? 0;
    totalAmount += ((item.price ?? 0) - (item.discount ?? 0)) * (item.quantity ?? 0);
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      content: InkWell(
        onTap: () {
          messenger.hideCurrentSnackBar();
          RouterHelper.getCartScreenRoute(action: RouteAction.push);
        },
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    Images.cartArrowDownImage,
                    height: Dimensions.iconSizeDefault,
                    width: Dimensions.iconSizeDefault,
                    color: Theme.of(context).highlightColor,
                  ),
                  if (cartController.cartList.isNotEmpty)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: CircleAvatar(
                        radius: ResponsiveHelper.isTab(context) ? 10 : 8,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        child: Text(
                          totalQuantity.toString(),
                          style: titilliumSemiBold.copyWith(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      getTranslated('added_to_cart', context) ?? '',
                      style: titilliumSemiBold.copyWith(
                        color: Theme.of(context).highlightColor,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalQuantity ${getTranslated('items', context) ?? ''} · ${PriceConverter.convertPrice(context, totalAmount)}',
                      style: textRegular.copyWith(
                        color: Theme.of(context).highlightColor.withValues(alpha: 0.9),
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).highlightColor,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
