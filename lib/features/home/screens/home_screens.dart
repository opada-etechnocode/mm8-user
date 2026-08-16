import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banners_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/footer_banner_slider_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/single_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/widgets/brand_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/clearance_sale/widgets/clearance_sale_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/featured_deal_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/flash_deals_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/flash_deal_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/announcement_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/featured_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/home_notification_icon_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/product_type_popup_menu_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/home_category_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/recommended_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/top_seller_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/home_load_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

import '../../../localization/controllers/localization_controller.dart';
import '../widgets/AnimatedCategorySearchText.dart';
import '../widgets/home_inbox_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static Future<void> loadData(bool reload) async {
    final flashDealController =
        Provider.of<FlashDealController>(Get.context!, listen: false);
    final categoryController =
        Provider.of<CategoryController>(Get.context!, listen: false);
    final bannerController =
        Provider.of<BannerController>(Get.context!, listen: false);
    final addressController =
        Provider.of<AddressController>(Get.context!, listen: false);
    final productController =
        Provider.of<ProductController>(Get.context!, listen: false);
    final brandController =
        Provider.of<BrandController>(Get.context!, listen: false);
    final featuredDealController =
        Provider.of<FeaturedDealController>(Get.context!, listen: false);
    final notificationController =
        Provider.of<NotificationController>(Get.context!, listen: false);
    final cartController =
        Provider.of<CartController>(Get.context!, listen: false);
    final profileController =
        Provider.of<ProfileController>(Get.context!, listen: false);
    final authController =
        Provider.of<AuthController>(Get.context!, listen: false);

    await HomeLoadHelper.runGuarded(
      reload,
      criticalTasks: [
        () async => categoryController.getCategoryList(reload),
        () async => bannerController.getBannerList(reload: reload),
        () async {
          if (flashDealController.flashDealList.isEmpty || reload) {
            await flashDealController.getFlashDealList(reload, false);
          }
        },
        () async => cartController.getCartData(Get.context!),
      ],
      secondaryTasks: [
        () async => productController.getHomeCategoryProductList(reload),
        () async => brandController.getBrandList(
              offset: 1,
              isUpdate: reload,
              reload: reload,
            ),
        () async => featuredDealController.getFeaturedDealList(reload: reload),
        () async => productController.getLatestProductList(
              1,
              isUpdate: reload,
              reload: reload,
            ),
        () async => productController.getSelectedProductModel(
              1,
              isUpdate: reload,
              reload: reload,
            ),
        () async => productController.getFeaturedProductModel(
              1,
              isUpdate: reload,
              reload: reload,
            ),
        () async => productController.getRecommendedProduct(reload: reload),
        () async => productController.getClearanceAllProductList(
              1,
              isUpdate: reload,
              reload: reload,
            ),
      ],
      deferredTasks: [
        () async => addressController.getAddressList(),
        () async {
          if (notificationController.notificationModel == null ||
              (notificationController.notificationModel != null &&
                  notificationController
                      .notificationModel!.notification!.isEmpty) ||
              reload) {
            await notificationController.getNotificationList(1);
          }
        },
        () async {
          if (authController.isLoggedIn() &&
              profileController.userInfoModel == null) {
            await profileController.getUserInfo(Get.context!);
          }
        },
      ],
    );
  }
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  void passData(int index, String title) {
    index = index;
    title = title;
  }

  bool singleVendor = false;

  @override
  void initState() {
    super.initState();

    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel
            ?.businessMode ==
        "single";
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel =
        Provider.of<SplashController>(context, listen: false).configModel;

    final bool isArabic =
        Provider.of<LocalizationController>(context, listen: false)
                .locale
                .languageCode ==
            'ar';

    final topPadding = MediaQuery.paddingOf(context).top;
    const headerContentHeight = 48.0;
    const headerSearchGap = 12.0;
    const searchBarHeight = 43.0;
    const searchBottomPadding = 17.0;
    final expandedHeight = topPadding +
        headerContentHeight +
        headerSearchGap +
        searchBarHeight +
        searchBottomPadding;
    final collapsedHeight =
        topPadding + searchBarHeight + searchBottomPadding;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await HomePage.loadData(true);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                expandedHeight:MediaQuery.of(context).size.height<850?170: 130,

                // 150,
                collapsedHeight: 65,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final double top = constraints.biggest.height;
                    final bool collapsed = top <= kToolbarHeight + 100;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        /// Background
                        ///
                        ///

                        !collapsed
                            ? PositionedDirectional(
                                top: -190,
                                end: -70,
                                child: Transform.flip(
                                  flipX: isArabic,
                                  child: Transform.rotate(
                                    angle: 90 * (math.pi / 180),
                                    child: Image.asset(
                                      Images.backgroundBubble2,
                                      height: 360,
                                      color: Theme.of(context).primaryColor,
                                      width: 360,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),

                        !collapsed
                            ? PositionedDirectional(
                                top: -200,
                                end: -120,
                                child: Transform.flip(
                                  flipX: isArabic,
                                  child: Transform.rotate(
                                    angle: 45 * (math.pi / 180),
                                    child: Image.asset(
                                      Images.backgroundBubble,
                                      height: 300,
                                      color: Theme.of(context).primaryColor,
                                      width: 300,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),

                        Column(
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: collapsed ? 0 : 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 55,
                                  left: 16,
                                  right: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                  Images.logoWithNameImage,
                                                  height: 48,
                                                  color:
                                                      Provider.of<ThemeController>(
                                                                  context)
                                                              .darkTheme
                                                          ? Colors.white
                                                          : null),
                                            ],
                                          ),
                                        ),
                                        Consumer<ProfileController>(
                                          builder: (_, pro, __) {
                                            final String name =
                                                pro.userInfoModel?.name ??
                                                    getTranslated(
                                                        "to_mm8", context)!;

                                            final String key = isArabic
                                                ? "header_title2"
                                                : "header_title";

                                            return Text(
                                              getTranslated(key, context)!
                                                  .replaceFirst("{name}", name),
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment:Provider.of<LocalizationController>(context).isLtr?Alignment.bottomLeft:Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 17,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      RouterHelper.getSearchRoute(
                                        action: RouteAction.push,
                                      );
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withAlpha(25),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          Icon(
                                            CupertinoIcons.search,
                                            color: Colors.grey.withAlpha(170),
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: AnimatedCategorySearchText(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                 SizedBox(width: !collapsed ?20:8),
                                const HomeNotificationIconWidget(),
                                SizedBox(width: 10,),
                                const HomeInboxIconWidget(),
                              ],
                            ),
                          ),
                          ),

                        /// Search
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                  child: Provider.of<SplashController>(context, listen: false)
                              .configModel!
                              .announcement!
                              .status ==
                          '1'
                      ? Consumer<SplashController>(
                          builder: (context, announcement, _) {
                          return (announcement.configModel!.announcement!
                                          .announcement !=
                                      null &&
                                  announcement.onOff)
                              ? AnnouncementWidget(
                                  announcement:
                                      announcement.configModel!.announcement)
                              : const SizedBox();
                        })
                      : const SizedBox()),
              SliverToBoxAdapter(child: BannersWidget()),
              SliverToBoxAdapter(
                child: CategoryListWidget(isHomePage: true),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Consumer<FlashDealController>(
                        builder: (context, megaDeal, child) {
                      return megaDeal.flashDeal == null
                          ? const FlashDealShimmer()
                          : megaDeal.flashDealList.isNotEmpty
                              ? Column(children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault),
                                    child: FlashDealBar(
                                      title:
                                          getTranslated('flash_deal', context)!
                                              .toUpperCase(),
                                      eventDuration: megaDeal.flashDeal != null
                                          ? megaDeal.duration
                                          : null,
                                      onTap: () {
                                        RouterHelper
                                            .getFlashDealScreenViewRoute();
                                      },
                                    ),

                                    // TitleRowWidget(
                                    //   title: getTranslated('flash_deal', context)?.toUpperCase(),
                                    //   eventDuration: megaDeal.flashDeal != null ? megaDeal.duration : null,
                                    //   onTap: () {
                                    //     RouterHelper.getFlashDealScreenViewRoute();
                                    //   },
                                    //   isFlash: true,
                                    // ),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault),
                                    child: Text(
                                      getTranslated(
                                              'hurry_up_the_offer_is_limited_grab_while_it_lasts',
                                              context) ??
                                          '',
                                      style: textRegular.copyWith(
                                          color: Provider.of<ThemeController>(
                                                      context,
                                                      listen: false)
                                                  .darkTheme
                                              ? Theme.of(context).hintColor
                                              : Theme.of(context).primaryColor,
                                          fontSize: Dimensions.fontSizeDefault),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeSmall),
                                  const FlashDealsListWidget()
                                ])
                              : const SizedBox.shrink();
                    }),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<FeaturedDealController>(
                    builder: (context, featuredDealProvider, child) {
                  return featuredDealProvider.featuredDealProductList != null
                      ? featuredDealProvider.featuredDealProductList!.isNotEmpty
                          ? Column(
                              children: [
                                Stack(children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 150,
                                    color: Provider.of<ThemeController>(context,
                                                listen: false)
                                            .darkTheme
                                        ? Theme.of(context).highlightColor
                                        : Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                  ),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeDefault),
                                      child: TitleRowWidget(
                                        title:
                                            '${getTranslated('featured_deals', context)}',
                                        onTap: () {
                                          RouterHelper
                                              .getFeaturedDealScreenViewRoute();
                                        },
                                      ),
                                    ),
                                    const FeaturedDealsListWidget(),
                                  ]),
                                ]),
                                const SizedBox(
                                    height: Dimensions.paddingSizeDefault),
                              ],
                            )
                          : const SizedBox.shrink()
                      : const FindWhatYouNeedShimmer();
                }),
              ),
              SliverToBoxAdapter(
                child: const ClearanceListWidget(),
              ),
              SliverToBoxAdapter(
                child: Consumer<BannerController>(
                    builder: (context, footerBannerProvider, child) {
                  return footerBannerProvider.footerBannerList != null &&
                          footerBannerProvider.footerBannerList!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault),
                          child: SingleBannersWidget(
                              bannerModel:
                                  footerBannerProvider.footerBannerList?[0]))
                      : const SizedBox();
                }),
              ),
              SliverToBoxAdapter(
                child: const FeaturedProductWidget(),
              ),

              if (!singleVendor)
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      children: [
                        Consumer<ShopController>(
                            builder: (context, topSellerProvider, child) {
                          return (topSellerProvider.topSellerModel != null &&
                                  (topSellerProvider.topSellerModel!.sellers !=
                                          null &&
                                      topSellerProvider
                                          .topSellerModel!.sellers!.isNotEmpty))
                              ? TitleRowWidget(
                                  title: getTranslated('top_seller', context),
                                  onTap: () =>
                                      RouterHelper.getAllTopSellerRoute(
                                          action: RouteAction.push,
                                          title: 'top_seller'))
                              : const SizedBox();
                        }),
                        singleVendor
                            ? const SizedBox(height: 0)
                            : const SizedBox(
                                height: Dimensions.paddingSizeSmall),
                        singleVendor
                            ? const SizedBox()
                            : Consumer<ShopController>(
                                builder: (context, topSellerProvider, child) {
                                return (topSellerProvider.topSellerModel !=
                                            null &&
                                        (topSellerProvider
                                                    .topSellerModel!.sellers !=
                                                null &&
                                            topSellerProvider.topSellerModel!
                                                .sellers!.isNotEmpty))
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(
                                                bottom:
                                                    Dimensions
                                                        .paddingSizeDefault),
                                        child:
                                            SizedBox(
                                                height: ResponsiveHelper.isTab(
                                                        context)
                                                    ? 170
                                                    : 150,
                                                child: const TopSellerWidget()))
                                    : const SizedBox();
                              })
                      ],
                    ),
                  ),
                ),
              if (!singleVendor)
                SliverToBoxAdapter(
                    child: SizedBox(height: Dimensions.paddingSizeDefault)),
              SliverToBoxAdapter(
                child: Padding(
                    padding:
                        EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: RecommendedProductWidget()),
              ),
              SliverToBoxAdapter(
                child: Padding(
                    padding:
                        EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: LatestProductListWidget()),
              ),
              if (configModel!.brandSetting == "1")
                SliverToBoxAdapter(
                    child: Column(
                  children: [
                    const BrandListWidget(isHomePage: true),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                )),
              const HomeCategoryProductWidget(isHomePage: true),
              SliverToBoxAdapter(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((Provider.of<BannerController>(context, listen: false)
                                  .footerBannerList
                                  ?.length ??
                              0) >
                          1)
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      const FooterBannerSliderWidget(),
                    ]),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(
                    height: 50,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: const ProductPopupFilterWidget()),
                    ),
                  )),
              HomeProductListWidget(scrollController: _scrollController),
            ],
          ),
        ),
      ),
      // ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

class SliverSearchDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverSearchDelegate({required this.child, this.height = 70});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverSearchDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
