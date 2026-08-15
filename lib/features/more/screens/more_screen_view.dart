import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/business_pages_model.dart';
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
  bool singleVendor = false;

  @override
  void initState() {
    super.initState();
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
    }
    singleVendor = Provider.of<SplashController>(context, listen: false)
            .configModel?.businessMode ==
        'single';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: false,
            elevation: 0,
            expandedHeight: MediaQuery.of(context).size.height*0.184
          ,
            pinned: true,
            centerTitle: false,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).primaryColor,
            collapsedHeight: MediaQuery.of(context).size.height*0.184,
            flexibleSpace: const ProfileInfoSectionWidget(),
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
    final items = <Widget>[];

    if (!singleVendor) {
      items.add(
        MenuButtonWidget(
          image: Images.chats,
          title: getTranslated('inbox', context),
          onTap: () => RouterHelper.getInboxScreenRoute(action: RouteAction.push),
        ),
      );
    }

    items.addAll([
      MenuButtonWidget(
        image: Images.callIcon,
        title: getTranslated('contact_us', context),
        onTap: () => RouterHelper.getContactUsScreenRoute(),
      ),
      MenuButtonWidget(
        image: Images.preference,
        title: getTranslated('support_ticket', context),
        onTap: () => RouterHelper.getSupportTicketRoute(action: RouteAction.push),
      ),
    ]);

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

  BusinessPageModel? getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    if (pagesList == null || pagesList.isEmpty) return null;
    for (final page in pagesList) {
      if (page.slug == slug) return page;
    }
    return null;
  }
}
