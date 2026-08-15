import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class SquareButtonWidget extends StatelessWidget {
  final String image;
  final String? title;
  final Widget? navigateTo;
  final int count;
  final bool hasCount;
  final bool isWallet;
  final double? balance;
  final bool isLoyalty;
  final String? subTitle;
  final Function? onTap;

  const SquareButtonWidget({
    super.key,
    required this.image,
    required this.title,
    this.navigateTo,
    required this.count,
    required this.hasCount,
    this.isWallet = false,
    this.balance,
    this.subTitle,
    this.isLoyalty = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onTap!(),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: isWallet ? 100 : 100,
          height: isWallet ? 100 : 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).hintColor.withValues(alpha: .12),
            ),
          ),
          child: isWallet ? _walletContent(context, primary) : _iconContent(context, primary),
        ),
      ),
    );
  }

  Widget _iconContent(BuildContext context, Color primary) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                image,
                color: primary,
                width: 22,
                height: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        if (hasCount)
          Positioned(
            top: 0,
            right: 0,
            child: _countBadge(context),
          ),
      ],
    );
  }

  Widget _walletContent(BuildContext context, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(image, color: primary, width: 22, height: 22),
            ),

            if (hasCount) _countBadge(context),
          ],
        ),
SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              getTranslated(subTitle, context) ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(width: 5,),
            Text(
              isLoyalty
                  ? (balance != null ? balance!.toStringAsFixed(0) : '0')
                  : (balance != null ? PriceConverter.convertPrice(context, balance) : '0'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeSmall+2,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _countBadge(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cart, child) {
        return Container(
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            count.toString(),
            style: textBold.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        );
      },
    );
  }
}
