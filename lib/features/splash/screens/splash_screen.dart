import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/widgets/typewriter_text_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/network_info.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final Completer<void> _typingCompleter = Completer<void>();
  bool _hasNavigated = false;
  // late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    // bool firstTime = true;
    // _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   if(!firstTime) {
    //     bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
    //     isNotConnected ? const SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       backgroundColor: isNotConnected ? Colors.red : Colors.green,
    //       duration: Duration(seconds: isNotConnected ? 6000 : 3),
    //       content: Text(isNotConnected ? getTranslated('no_connection', context)! : getTranslated('connected', context)!,
    //         textAlign: TextAlign.center)));
    //     if(!isNotConnected) {
    //       _route();
    //     }
    //   }
    //   firstTime = false;
    // });

    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _route();
  }

  void _onTypingComplete() {
    if (!_typingCompleter.isCompleted) {
      _typingCompleter.complete();
    }
  }

  Future<void> _ensureSplashAnimationFinished() async {
    await _typingCompleter.future;
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void _scheduleNavigation(VoidCallback navigate) {
    _ensureSplashAnimationFinished().then((_) {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      navigate();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // _onConnectivityChanged.cancel();
  }

  void _route() {
    NetworkInfo.checkConnectivity(context);
    Provider.of<SplashController>(context, listen: false).initConfig(context, (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(Get.context!, listen: false).configModel?.userAppVersionControl;
        if(Platform.isAndroid) {
          minimumVersion =  appVersion?.forAndroid?.version ?? '0';
        } else if(Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(Get.context!, listen: false).initSharedPrefData();
        // Timer(const Duration(seconds: 2), () {
          final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;

          _scheduleNavigation(() {
            if(compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
              RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
            } else if(
            config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1
                && !Provider.of<SplashController>(Get.context!, listen: false).isConfigCall) {
              RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
            } else if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()) {
              Provider.of<AuthController>(Get.context!, listen: false).updateToken(Get.context!);
              if(widget.body != null){
                if (widget.body!.type == 'order') {
                  RouterHelper.getOrderDetailsScreenRoute(
                    action: RouteAction.pushReplacement,
                    orderId: widget.body!.orderId!,
                  );
                } else if(widget.body!.type == 'notification') {
                  RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement);
                } else if(widget.body!.type == 'wallet') {
                  RouterHelper.getWalletRoute(action: RouteAction.pushReplacement, isBackButtonExist: true);
                } else  if (widget.body!.type == 'chatting') {
                  RouterHelper.getInboxScreenRoute(
                    action: RouteAction.pushReplacement,
                    isBackButtonExist: true,
                    fromNotification: true,
                    initIndex: widget.body!.messageKey == 'message_from_delivery_man' ? 0 : 1,
                  );
                } else if(widget.body!.type == 'product_restock_update') {
                  RouterHelper.getProductDetailsRoute(action: RouteAction.pushReplacement, productId: int.parse(widget.body!.productId!), slug: widget.body!.slug, isNotification: true);
                } else {
                  RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
                }
              }else{
                // Navigator.of(Get.context!).pushReplacement(
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                //     transitionDuration: Duration.zero, // Removes transition duration
                //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
                //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                //   ),
                // );

                RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
              }
            }

            else if(Provider.of<SplashController>(Get.context!, listen: false).showIntro()!){
              RouterHelper.getOnboardingRoute(
                action: RouteAction.pushReplacement,
                indicatorColor: Provider.of<ThemeController>(Get.context!, listen: false).darkTheme ?
                  Theme.of(Get.context!).colorScheme.onTertiary : Theme.of(Get.context!).hintColor,
                selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
              );
            }
            else{
              if(Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != null &&
                  Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != '1') {
                // Navigator.of(Get.context!).pushReplacement(
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                //     transitionDuration: Duration.zero, // Removes transition duration
                //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
                //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                //   ),
                // );

                RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);


              }else{
                Provider.of<AuthController>(Get.context!, listen: false).getGuestIdUrl();
                RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);

                // Navigator.of(Get.context!).pushReplacement(
                //   PageRouteBuilder(
                //     pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                //     transitionDuration: Duration.zero, // Removes transition duration
                //     reverseTransitionDuration: Duration.zero, // Removes reverse transition
                //     transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                //   ),
                // );

              }
            }
          });
       //  });
      },


      (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(Get.context!, listen: false).configModel?.userAppVersionControl;
        if(Platform.isAndroid) {
          minimumVersion =  appVersion?.forAndroid?.version ?? '0';
        } else if(Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(Get.context!, listen: false).initSharedPrefData();
        final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;

        _scheduleNavigation(() {
          if(compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
            RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
          } else if(
            config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1
            && !config!.localMaintenanceMode!
          ) {
            RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
          } else if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn() && !configModel!.hasLocaldb!) {
            Provider.of<AuthController>(Get.context!, listen: false).updateToken(Get.context!);
            if(widget.body != null) {
              if (widget.body!.type == 'order') {
                RouterHelper.getOrderDetailsScreenRoute(
                  action: RouteAction.pushReplacement,
                  orderId: widget.body!.orderId!,
                );
              } else if(widget.body!.type == 'notification') {
                RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement);
              } else if(widget.body!.type == 'wallet') {
                RouterHelper.getWalletRoute(action: RouteAction.pushReplacement, isBackButtonExist: true);
              } else  if (widget.body!.type == 'chatting') {
                RouterHelper.getInboxScreenRoute(
                  action: RouteAction.push,
                  isBackButtonExist: true,
                  fromNotification: true,
                  initIndex: widget.body!.messageKey == 'message_from_delivery_man' ? 0 : 1,
                );
              } else if(widget.body!.type == 'product_restock_update') {
                RouterHelper.getProductDetailsRoute(action: RouteAction.push, productId: int.parse(widget.body!.productId!), slug: widget.body!.slug, isNotification: true);
              } else {
                RouterHelper.getNotificationRoute(action: RouteAction.pushReplacement, fromNotification: true);
              }
            }else{
              RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
            }
          }

          else if(Provider.of<SplashController>(Get.context!, listen: false).showIntro()! &&  !configModel!.hasLocaldb!){
            RouterHelper.getOnboardingRoute(
              action: RouteAction.pushReplacement,
              indicatorColor: Provider.of<ThemeController>(Get.context!, listen: false).darkTheme ?
                Theme.of(Get.context!).colorScheme.onTertiary : Theme.of(Get.context!).hintColor,
              selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
            );
          }
          else if(!configModel!.hasLocaldb! || (configModel.hasLocaldb! && configModel.localMaintenanceMode! && !(config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1))){
            if(Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != null &&
                Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != '1'){
              RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
            }else{
              Provider.of<AuthController>(Get.context!, listen: false).getGuestIdUrl();
              RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
            }
          }
        });
      }


    ).then((bool isSuccess) {
      if(isSuccess) {

      }
    });
  }


  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    int maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part = i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      int v2Part = i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Provider.of<SplashController>(context).hasConnection ?
      SplashWidget(onTypingComplete: _onTypingComplete) : const NoInternetOrDataScreenWidget(isNoInternet: true, child: SplashScreen()),
    );
  }
}

class SplashWidget extends StatelessWidget {
  final VoidCallback? onTypingComplete;

  const SplashWidget({super.key, this.onTypingComplete});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          Positioned(
              top: -200,
              left: -50,
              child: Center(
                  child: Image.asset(Images.backgroundBubble2,color:Theme.of(context).primaryColor))),
          Positioned(
              top: 30,
              right: -330,
              child:  Transform.rotate(
                  angle: 270 * (math.pi / 180),
                  child: Image.asset(Images.backgroundBubble,color: Theme.of(context).primaryColor,))),
          Column(mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Row(children: []),

          SizedBox(width: 150, child: Image.asset(Images.logo, width: 150.0)),


            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: TypewriterText(
                text: getTranslated('splash_welcome_message', context) ?? '',
                speed: const Duration(milliseconds: 38),
                step: 1,
                textAlign: TextAlign.center,
                onComplete: onTypingComplete,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault+1,
                 color: Theme.of(context).textTheme.bodyLarge!.color,
                  height: 1.5,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
