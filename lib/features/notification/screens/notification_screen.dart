import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_loggedin_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/widget/notification_item_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/widget/notification_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key,  this.fromNotification = false});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    if(widget.fromNotification){
      Provider.of<SplashController>(context, listen: false).initConfig(context, null, null).then((value){
        Provider.of<NotificationController>(Get.context!, listen: false).getNotificationList(1);
      });
    }
    if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      if(Provider.of<ProfileController>(context, listen: false).userInfoModel == null) {
        Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
      }
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, notificationController, child) {
        final bool showClearAll =
            Provider.of<AuthController>(context, listen: false).isLoggedIn() &&
                notificationController.hasVisibleNotifications;

        return Scaffold(
          appBar: CustomAppBar(
            title: getTranslated('notification', context),
            onBackPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                RouterHelper.getDashboardRoute(
                    action: RouteAction.pushReplacement);
              }
            },
            showResetIcon: showClearAll,
            reset: TextButton(
              onPressed: () => notificationController.deleteAllNotifications(),
              child: Text(
                getTranslated('clear_all', context)!,
                style: textMedium.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ),
          body: Provider.of<AuthController>(context, listen: false).isLoggedIn()
              ? _NotificationBody(
                  notificationController: notificationController,
                  scrollController: scrollController,
                )
              : NotLoggedInWidget(
                  fromPage: RouterHelper.notificationScreen,
                  onLoginSuccess: () {
                    RouterHelper.getNotificationRoute(
                        action: RouteAction.pushReplacement);
                  },
                ),
        );
      },
    );
  }
}

class _NotificationBody extends StatelessWidget {
  final NotificationController notificationController;
  final ScrollController scrollController;

  const _NotificationBody({
    required this.notificationController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return notificationController.notificationModel != null
        ? (notificationController.notificationModel!.notification != null &&
                notificationController
                    .notificationModel!.notification!.isNotEmpty)
            ? RefreshIndicator(
                onRefresh: () async =>
                    await notificationController.getNotificationList(1),
                child: PaginatedListView(
                  scrollController: scrollController,
                  onPaginate: (int? offset) =>
                      notificationController.getNotificationList(offset ?? 1),
                  totalSize: notificationController.notificationModel?.totalSize,
                  offset: notificationController.notificationModel?.offset,
                  itemView: Flexible(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: notificationController
                          .notificationModel!.notification!.length,
                      itemBuilder: (context, index) {
                        final notificationItem = notificationController
                            .notificationModel!.notification![index];
                        return Dismissible(
                          key: ValueKey('notification_${notificationItem.id}'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            if (notificationItem.id != null) {
                              notificationController
                                  .deleteNotification(notificationItem.id!);
                            }
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                            ),
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withValues(alpha: 0.85),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          child: NotificationItemWidget(
                            notificationItem: notificationItem,
                            index: index,
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                    ),
                  ),
                ),
              )
            : const NoInternetOrDataScreenWidget(
                isNoInternet: false,
                message: 'no_notification',
                icon: Images.noNotification,
              )
        : const NotificationShimmerWidget();
  }
}



