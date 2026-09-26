import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/network_info.dart';
import 'package:flutter_sixvalley_ecommerce/helper/deep_link_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/notification_route_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/splash_video_loader.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;

  const SplashScreen({super.key, this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final Completer<void> _splashVideoCompleter = Completer<void>();
  bool _hasNavigated = false;
  NotificationBody? _notificationBody;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    _route();
  }

  void _onSplashVideoComplete() {
    if (!_splashVideoCompleter.isCompleted) {
      _splashVideoCompleter.complete();
    }
  }

  Future<void> _ensureSplashAnimationFinished() async {
    await _splashVideoCompleter.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {},
    );
    await Future.delayed(const Duration(milliseconds: 250));
  }

  void _scheduleNavigation(Future<void> Function() navigate) {
    _ensureSplashAnimationFinished().then((_) async {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      await navigate();
      DeepLinkHelper.markBootstrapComplete();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  NotificationBody? _resolveNotificationBody() {
    _notificationBody ??=
        widget.body ?? NotificationRouteHelper.consumePendingNotification();
    return _notificationBody;
  }

  void _navigateFromNotification(NotificationBody body) {
    NotificationRouteHelper.navigateImmediately(
      body,
      action: RouteAction.pushReplacement,
    );
  }

  Future<bool> _navigatePendingDeepLink() {
    return DeepLinkHelper.tryNavigatePendingDeepLinkWithRetry(
      action: RouteAction.pushReplacement,
    );
  }

  void _route() {
    NetworkInfo.checkConnectivity(context);
    Provider.of<SplashController>(context, listen: false).initConfig(context,
        (ConfigModel? configModel) {
      String? minimumVersion = "0";
      UserAppVersionControl? appVersion =
          Provider.of<SplashController>(Get.context!, listen: false)
              .configModel
              ?.userAppVersionControl;
      if (Platform.isAndroid) {
        minimumVersion = appVersion?.forAndroid?.version ?? '0';
      } else if (Platform.isIOS) {
        minimumVersion = appVersion?.forIos?.version ?? '0';
      }
      Provider.of<SplashController>(Get.context!, listen: false)
          .initSharedPrefData();
      final config = Provider.of<SplashController>(Get.context!, listen: false)
          .configModel;
      print("app version:" + minimumVersion);
      print("app version local:" + AppConstants.appVersion);
      print("app version local:" +
          compareVersions(minimumVersion!, AppConstants.appVersion).toString());
      _scheduleNavigation(() async {
        if (compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
          RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
        } else if (config?.maintenanceModeData?.maintenanceStatus == 1 &&
            config?.maintenanceModeData?.selectedMaintenanceSystem
                    ?.customerApp ==
                1 &&
            !Provider.of<SplashController>(Get.context!, listen: false)
                .isConfigCall) {
          RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
        } else if (Provider.of<AuthController>(Get.context!, listen: false)
            .isLoggedIn()) {
          Provider.of<AuthController>(Get.context!, listen: false)
              .updateToken(Get.context!);
          final notificationBody = _resolveNotificationBody();
          if (notificationBody != null) {
            _navigateFromNotification(notificationBody);
          } else if (await _navigatePendingDeepLink()) {
          } else {
            RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
          }
        } else if (Provider.of<SplashController>(Get.context!, listen: false)
            .showIntro()!) {
          RouterHelper.getOnboardingRoute(
            action: RouteAction.pushReplacement,
            indicatorColor:
                Provider.of<ThemeController>(Get.context!, listen: false)
                        .darkTheme
                    ? Theme.of(Get.context!).colorScheme.onTertiary
                    : Theme.of(Get.context!).hintColor,
            selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
          );
        } else {
          if (Provider.of<AuthController>(Get.context!, listen: false)
                      .getGuestToken() !=
                  null &&
              Provider.of<AuthController>(Get.context!, listen: false)
                      .getGuestToken() !=
                  '1') {
            if (await _navigatePendingDeepLink()) {
            } else {
              RouterHelper.getDashboardRoute(
                  action: RouteAction.pushReplacement);
            }
          } else {
            Provider.of<AuthController>(Get.context!, listen: false)
                .getGuestIdUrl();
            if (await _navigatePendingDeepLink()) {
            } else {
              RouterHelper.getDashboardRoute(
                  action: RouteAction.pushReplacement);
            }
          }
        }
      });
    }, (ConfigModel? configModel) {
      String? minimumVersion = "0";
      UserAppVersionControl? appVersion =
          Provider.of<SplashController>(Get.context!, listen: false)
              .configModel
              ?.userAppVersionControl;
      if (Platform.isAndroid) {
        minimumVersion = appVersion?.forAndroid?.version ?? '0';
      } else if (Platform.isIOS) {
        minimumVersion = appVersion?.forIos?.version ?? '0';
      }
      Provider.of<SplashController>(Get.context!, listen: false)
          .initSharedPrefData();
      final config = Provider.of<SplashController>(Get.context!, listen: false)
          .configModel;

      _scheduleNavigation(() async {
        if (compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
          RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
        } else if (config?.maintenanceModeData?.maintenanceStatus == 1 &&
            config?.maintenanceModeData?.selectedMaintenanceSystem
                    ?.customerApp ==
                1 &&
            !config!.localMaintenanceMode!) {
          RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
        } else if (Provider.of<AuthController>(Get.context!, listen: false)
                .isLoggedIn() &&
            !configModel!.hasLocaldb!) {
          Provider.of<AuthController>(Get.context!, listen: false)
              .updateToken(Get.context!);
          final notificationBody = _resolveNotificationBody();
          if (notificationBody != null) {
            _navigateFromNotification(notificationBody);
          } else if (await _navigatePendingDeepLink()) {
          } else {
            RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
          }
        } else if (Provider.of<SplashController>(Get.context!, listen: false)
            .showIntro()!) {
          RouterHelper.getOnboardingRoute(
            action: RouteAction.pushReplacement,
            indicatorColor:
                Provider.of<ThemeController>(Get.context!, listen: false)
                        .darkTheme
                    ? Theme.of(Get.context!).colorScheme.onTertiary
                    : Theme.of(Get.context!).hintColor,
            selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
          );
        } else {
          if (Provider.of<AuthController>(Get.context!, listen: false)
                      .getGuestToken() !=
                  null &&
              Provider.of<AuthController>(Get.context!, listen: false)
                      .getGuestToken() !=
                  '1') {
            if (await _navigatePendingDeepLink()) {
            } else {
              RouterHelper.getDashboardRoute(
                  action: RouteAction.pushReplacement);
            }
          } else {
            Provider.of<AuthController>(Get.context!, listen: false)
                .getGuestIdUrl();
            if (await _navigatePendingDeepLink()) {
            } else {
              RouterHelper.getDashboardRoute(
                action: RouteAction.pushReplacement,
              );
            }
          }
        }
      });
    }).then((bool isSuccess) {
      if (isSuccess) {}
    });
  }

  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    int maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part =
          i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      int v2Part =
          i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: Provider.of<SplashController>(context).hasConnection
            ? SplashWidget(onVideoComplete: _onSplashVideoComplete)
            : const NoInternetOrDataScreenWidget(
                isNoInternet: true, child: SplashScreen()),
      ),
    );
  }
}

class SplashWidget extends StatefulWidget {
  final VoidCallback? onVideoComplete;

  const SplashWidget({super.key, this.onVideoComplete});

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  VideoPlayerController? _controller;
  bool _ownsController = false;
  bool _ready = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  Future<void> _startPlayback() async {
    // Prefer the controller preloaded before runApp.
    VideoPlayerController? controller = SplashVideoLoader.take();

    if (controller == null || !controller.value.isInitialized) {
      controller = VideoPlayerController.asset(Images.splashIntroVideo);
      _ownsController = true;
      try {
        await controller.initialize();
        await controller.setLooping(false);
      } catch (_) {
        await controller.dispose();
        _finishSplash();
        return;
      }
    } else {
      _ownsController = true;
    }

    if (!mounted) {
      await controller.dispose();
      return;
    }

    _controller = controller;
    controller.addListener(_handleVideoProgress);
    setState(() => _ready = true);
    // Play immediately after first frame is attached.
    await controller.play();
  }

  void _handleVideoProgress() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 100)) {
      _finishSplash();
    }
  }

  void _finishSplash() {
    if (_completed) return;
    _completed = true;
    widget.onVideoComplete?.call();
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleVideoProgress);
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: (_ready && controller != null && controller.value.isInitialized)
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final videoSize = controller.value.size;
                  if (videoSize.width <= 0 || videoSize.height <= 0) {
                    return const SizedBox.shrink();
                  }

                  // Cover screen fully (may crop sides, never leave empty bands).
                  final coverScale = [
                    constraints.maxWidth / videoSize.width,
                    constraints.maxHeight / videoSize.height,
                  ].reduce((a, b) => a > b ? a : b);

                  return ClipRect(
                    child: OverflowBox(
                      minWidth: 0,
                      minHeight: 0,
                      maxWidth: videoSize.width * coverScale,
                      maxHeight: videoSize.height * coverScale,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: videoSize.width,
                        height: videoSize.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  );
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
