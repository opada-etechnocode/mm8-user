import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/logout_confirm_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/more_section_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/profile_info_section_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/more_horizontal_section_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/features/more/widgets/title_button_widget.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
    }
  }

  double _headerHeight(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    // Avatar + name + phone + spacing (compact expanded header).
    const profileContentHeight = 110.0;
    final tabletExtra = ResponsiveHelper.isTab(context) ? 8.0 : 0.0;
    return topPadding + profileContentHeight + tabletExtra;
  }

  double _collapsedHeaderHeight(BuildContext context) {
    return MediaQuery.paddingOf(context).top + 30;
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = _headerHeight(context);
    final collapsedHeight = _collapsedHeaderHeight(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: false,
            stretch: true,
            elevation: 0,
            expandedHeight: headerHeight,
            pinned: true,
            centerTitle: false,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            collapsedHeight: collapsedHeight,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return ProfileInfoSectionWidget(
                  expandedHeight: headerHeight,
                  collapsedHeight: collapsedHeight,
                  currentHeight: constraints.biggest.height,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<AuthController>(
              builder: (ctx, authController, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MoreHorizontalSection(),
                    MoreSectionTitle(
                      title: getTranslated('general', context) ?? '',
                      icon: Icons.grid_view_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: Consumer<SplashController>(
                        builder: (context, splashController, _) {
                          return MoreSectionCard(
                            children: _buildGeneralMenuItems(
                              context,
                              authController,
                              splashController,
                            ),
                          );
                        },
                      ),
                    ),
                    MoreSectionTitle(
                      title: getTranslated('help_and_support', context) ?? '',
                      icon: Icons.support_agent_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: Consumer<SplashController>(
                        builder: (context, splashController, _) {
                          return MoreSectionCard(
                            children: _buildHelpMenuItems(
                              context,
                              splashController,
                            ),
                          );
                        },
                      ),
                    ),
                    MoreAuthButton(
                      title: !authController.isLoggedIn()
                          ? getTranslated('sign_in', context)!
                          : getTranslated('sign_out', context)!,
                      isLoggedIn: authController.isLoggedIn(),
                      onTap: () {
                        if (!authController.isLoggedIn()) {
                          RouterHelper.getLoginRoute(
                            action: RouteAction.push,
                            fromPage: '${RouterHelper.dashboardScreen}?page=more',
                          );
                        } else {
                          showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (_) => const LogoutCustomBottomSheetWidget(),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10,)
                  ],
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildGeneralMenuItems(
    BuildContext context,
    AuthController authController,
    SplashController splashController,
  ) {
    final items = <Widget>[
      MenuButtonWidget(
        image: Images.trackOrderIcon,
        title: getTranslated('TRACK_ORDER', context),
        onTap: () => RouterHelper.getGuestTrackOrderRoute(action: RouteAction.push),
      ),
      if (authController.isLoggedIn())
        MenuButtonWidget(
          image: Images.user,
          title: getTranslated('profile', context),
          onTap: () => RouterHelper.getProfileScreen1Route(action: RouteAction.push),
        ),
      MenuButtonWidget(
        image: Images.address,
        title: getTranslated('addresses', context),
        onTap: () => RouterHelper.getAddressListScreen(action: RouteAction.push),
      ),
      MenuButtonWidget(
        image: Images.coupon,
        title: getTranslated('coupons', context),
        onTap: () => RouterHelper.getCouponListScreenRoute(),
      ),
      if (authController.isLoggedIn() &&
          splashController.configModel?.refEarningStatus == '1')
        MenuButtonWidget(
          image: Images.refIcon,
          title: getTranslated('refer_and_earn', context),
          isProfile: true,
          onTap: () => RouterHelper.getReferAndEarnRoute(action: RouteAction.push),
        ),
      MenuButtonWidget(
        image: Images.category,
        title: getTranslated('CATEGORY', context),
        onTap: () => RouterHelper.getCategoryScreenRoute(action: RouteAction.push),
      ),
      if (authController.isLoggedIn())
        MenuButtonWidget(
          image: Images.restockIcon,
          title: getTranslated('restock_requests', context),
          onTap: () => RouterHelper.getRestockListRoute(action: RouteAction.push),
        ),
      if (splashController.configModel!.activeTheme != 'default' &&
          authController.isLoggedIn())
        MenuButtonWidget(
          image: Images.compare,
          title: getTranslated('compare_products', context),
          onTap: () => RouterHelper.getCompareProductScreenRoute(),
        ),
      MenuButtonWidget(
        image: Images.notification,
        title: getTranslated('notification', context),
        isNotification: true,
        onTap: () => RouterHelper.getNotificationRoute(action: RouteAction.push),
      ),
      MenuButtonWidget(
        image: Images.settings,
        title: getTranslated('settings', context),
        onTap: () => RouterHelper.getSettingsRoute(action: RouteAction.push),
      ),
      if (splashController.configModel?.blogUrl?.isNotEmpty ?? false)
        MenuButtonWidget(
          image: Images.blogIcon,
          title: getTranslated('blog', context),
          onTap: () => RouterHelper.getBlogScreenRoute(
            action: RouteAction.push,
            url: splashController.configModel?.blogUrl ?? '',
          ),
        ),
    ];
    return items;
  }

  List<Widget> _buildHelpMenuItems(
    BuildContext context,
    SplashController splashController,
  ) {
    final items = <Widget>[
      MenuButtonWidget(
        image: Images.chats,
        title: getTranslated('inbox', context),
        onTap: () => _openMm8SupportChat(context),
      ),
      MenuButtonWidget(
        image: Images.preference,
        title: getTranslated('support_ticket', context),
        onTap: () => RouterHelper.getSupportTicketRoute(action: RouteAction.push),
      ),
    ];

    if (splashController.defaultBusinessPages != null &&
        splashController.defaultBusinessPages!.isNotEmpty) {
      final pages = splashController.defaultBusinessPages!;
      final slugs = [
        ('terms-and-conditions', Images.termCondition, 'terms_condition'),
        ('privacy-policy', Images.privacyPolicy, 'privacy_policy'),
        ('refund-policy', Images.termCondition, 'refund_policy'),
        ('return-policy', Images.termCondition, 'return_policy'),
        ('cancellation-policy', Images.termCondition, 'cancellation_policy'),
        ('shipping-policy', Images.termCondition, 'shipping_policy'),
      ];

      for (final slug in slugs) {
        final page = getPageBySlug(slug.$1, pages);
        if (page != null) {
          items.add(
            MenuButtonWidget(
              image: slug.$2,
              title: getTranslated(slug.$3, context),
              onTap: () => RouterHelper.getHtmlViewRoute(page: page),
            ),
          );
        }
      }
    }

    items.add(
      MenuButtonWidget(
        image: Images.faq,
        title: getTranslated('faq', context),
        onTap: () => RouterHelper.getFaqRoute(action: RouteAction.push),
      ),
    );

    final aboutPage = getPageBySlug('about-us', splashController.defaultBusinessPages);
    if (aboutPage != null) {
      items.add(
        MenuButtonWidget(
          image: Images.user,
          title: getTranslated('about_us', context),
          onTap: () => RouterHelper.getHtmlViewRoute(page: aboutPage),
        ),
      );
    }

    if (splashController.businessPages != null &&
        splashController.businessPages!.isNotEmpty) {
      for (final page in splashController.businessPages!) {
        items.add(
          MenuButtonWidget(
            image: Images.termCondition,
            title: page.title,
            onTap: () => RouterHelper.getHtmlViewRoute(page: page),
          ),
        );
      }
    }

    return items;
  }

  void _openMm8SupportChat(BuildContext context) {
    if (!Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => NotLoggedInBottomSheetWidget(
          fromPage: '${RouterHelper.dashboardScreen}?page=more',
        ),
      );
      return;
    }

    Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
    RouterHelper.getChatScreenRoute(
      action: RouteAction.push,
      id: 1,
      name: 'MM8',
      userType: 1,
      image: '',
      isShopOnVacation: false,
      isShopTemporaryClosed: false,
    );
  }

  BusinessPageModel? getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    if (pagesList == null || pagesList.isEmpty) return null;
    for (final page in pagesList) {
      if (page.slug == slug) return page;
    }
    return null;
  }
}
