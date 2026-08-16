import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/enums/vacation_duration_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShopInfoWidget extends StatelessWidget {
  final String slug = '';
  final bool vacationIsOn;
  final bool temporaryClose;
  final String sellerName;
  final int sellerId;
  final int? totalReview;
  final int? totalProduct;
  final String? rating;
  final String banner;
  final String shopImage;
  final DateTime? vacationEndDate;
  final DateTime? vacationStartDate;
  final VacationDurationType? vacationDurationType;
  final bool fromMore;
  const ShopInfoWidget({super.key, required this.vacationIsOn, required this.sellerName,
    required this.sellerId, required this.banner, required this.shopImage, required this.temporaryClose, this.totalReview, this.totalProduct, this.rating, this.vacationEndDate, this.vacationStartDate, this.vacationDurationType, required this.fromMore});

  @override
  Widget build(BuildContext context) {

    var splashController = Provider.of<SplashController>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall + 5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const imageSize = 80.0;
          const spacing = Dimensions.paddingSizeSmall;

          return Container(
            padding: const EdgeInsets.symmetric(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
              boxShadow: Provider.of<ThemeController>(context, listen: false).darkTheme
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).highlightColor,
                            boxShadow: Provider.of<ThemeController>(context, listen: false).darkTheme
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                            child: CustomImageWidget(
                              height: imageSize,
                              width: imageSize,
                              fit: BoxFit.cover,
                              image: sellerId == 0
                                  ? splashController.configModel?.inHouseShop?.imageFullUrl?.path ?? ''
                                  : shopImage,
                            ),
                          ),
                        ),
                        if (temporaryClose || vacationIsOn)
                          Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .5),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.paddingSizeExtraSmall),
                              ),
                            ),
                          ),
                        if (temporaryClose)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Center(
                                child: Text(
                                  getTranslated('temporary_closed', context)!.replaceAll(' ', '\n'),
                                  textAlign: TextAlign.center,
                                  style: textRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (vacationIsOn)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Center(
                                child: Text(
                                  getTranslated('close_for_now', context)!,
                                  textAlign: TextAlign.center,
                                  style: textRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: spacing),
                    SizedBox(
                      width: constraints.maxWidth - imageSize - spacing,
                      child: Consumer<ShopController>(
                        builder: (context, sellerProvider, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sellerName,
                                      style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    child: InkWell(
                                      onTap: () {
                                        if (temporaryClose) {
                                          showCustomSnackBarWidget(
                                            '${getTranslated('this_shop_is_close_now', context)}',
                                            context,
                                            snackBarType: SnackBarType.warning,
                                          );
                                        } else {
                                          if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (_) => NotLoggedInBottomSheetWidget(
                                                fromPage: RouterHelper.topSellerScreen,
                                                onLoginSuccess: () {
                                                  RouterHelper.getTopSellerRoute(
                                                    action: RouteAction.pushReplacement,
                                                    slug: slug,
                                                    sellerId: sellerId,
                                                    temporaryClose: temporaryClose,
                                                    vacationStatus: vacationIsOn,
                                                    vacationEndDate: vacationEndDate,
                                                    vacationStartDate: vacationStartDate,
                                                    vacationDurationType: vacationDurationType,
                                                    name: sellerName,
                                                    banner: banner,
                                                    image: shopImage,
                                                    fromMore: fromMore,
                                                    totalReview: totalReview,
                                                    totalProduct: totalProduct,
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            Provider.of<ChatController>(context, listen: false)
                                                .setUserTypeIndex(context, 1);
                                            RouterHelper.getChatScreenRoute(
                                              action: RouteAction.push,
                                              id: sellerId,
                                              name: sellerName,
                                              userType: 1,
                                              isShopOnVacation: vacationIsOn,
                                              image: sellerId == 0
                                                  ? splashController
                                                          .configModel
                                                          ?.inHouseShop
                                                          ?.imageFullUrl
                                                          ?.path ??
                                                      ''
                                                  : shopImage,
                                            );
                                          }
                                        }
                                      },
                                      child: CustomAssetImageWidget(
                                        Images.storeChatIcon,
                                        height: 20,
                                        width: 20,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if ((sellerProvider.sellerInfoModel != null) ||
                                  (rating != null && totalProduct != null && totalReview != null))
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                    Row(
                                      children: [
                                        if (sellerProvider.sellerInfoModel?.minimumOrderAmount != null &&
                                            sellerProvider.sellerInfoModel!.minimumOrderAmount! > 0)
                                          Text(
                                            '${PriceConverter.convertPrice(context, sellerProvider.sellerInfoModel!.minimumOrderAmount)} '
                                            '${getTranslated('minimum_order', context)}',
                                            style: titleRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        Text(
                                          '${totalProduct ?? sellerProvider.sellerInfoModel!.totalProduct} ${getTranslated('products', context)}',
                                          style: titleRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class ShopInfoShimmerWidget extends StatelessWidget {
  const ShopInfoShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: Theme.of(context).hintColor.withValues(alpha: .5),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 120,
            color: Colors.white,
          ),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 15,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 10),


                        Row(
                          children: [
                            Container(height: 12, width: 40, color: Colors.white),
                            const SizedBox(width: 10),
                            Container(height: 12, width: 80, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 10),


                        Row(
                          children: [
                            Container(height: 12, width: 100, color: Colors.white),
                            const SizedBox(width: 10),
                            Container(height: 12, width: 60, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}