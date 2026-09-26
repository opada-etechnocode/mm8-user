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
  bool _hasNavigated = false;
  bool _configStarted = false;
  NotificationBody? _notificationBody;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startConfigInBackground();
    });
  }

  /// Config / API keep loading after we leave splash — never block navigation.
  void _startConfigInBackground() {
    if (_configStarted) return;
    _configStarted = true;

    NetworkInfo.checkConnectivity(context);
    final splash = Provider.of<SplashController>(context, listen: false);

    splash.initConfig(
      context,
      (ConfigModel? configModel) {
        splash.initSharedPrefData();
      },
      (ConfigModel? configModel) {
        splash.initSharedPrefData();
        // If user already left splash, still honor forced redirects.
        if (_hasNavigated) {
          _applyForcedRedirects(configModel);
        }
      },
    );
  }

  void _onSplashVideoComplete() {
    _navigateImmediately();
  }

  void _navigateImmediately() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final splash = Provider.of<SplashController>(context, listen: false);
    final auth = Provider.of<AuthController>(context, listen: false);
    splash.initSharedPrefData();

    final config = splash.configModel;
    if (config != null && _needsForceUpdate(config)) {
      RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
      DeepLinkHelper.markBootstrapComplete();
      return;
    }

    // Navigate synchronously — never await network/deeplink before leaving splash
    // (awaiting caused a black frame after the video).
    if (auth.isLoggedIn()) {
      RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
      auth.updateToken(Get.context!);
      Future.microtask(_openPendingNotificationOrDeepLink);
    } else if (splash.showIntro() == true) {
      RouterHelper.getOnboardingRoute(
        action: RouteAction.pushReplacement,
        indicatorColor:
            Provider.of<ThemeController>(Get.context!, listen: false).darkTheme
                ? Theme.of(Get.context!).colorScheme.onTertiary
                : Theme.of(Get.context!).hintColor,
        selectedIndicatorColor: Theme.of(Get.context!).primaryColor,
      );
    } else {
      if (auth.getGuestToken() == null || auth.getGuestToken() == '1') {
        auth.getGuestIdUrl();
      }
      RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
      Future.microtask(_navigatePendingDeepLink);
    }

    DeepLinkHelper.markBootstrapComplete();
  }

  Future<void> _openPendingNotificationOrDeepLink() async {
    final notificationBody = _resolveNotificationBody();
    if (notificationBody != null) {
      _navigateFromNotification(notificationBody);
      return;
    }
    await _navigatePendingDeepLink();
  }

  bool _needsForceUpdate(ConfigModel config) {
    String minimumVersion = '0';
    final appVersion = config.userAppVersionControl;
    if (Platform.isAndroid) {
      minimumVersion = appVersion?.forAndroid?.version ?? '0';
    } else if (Platform.isIOS) {
      minimumVersion = appVersion?.forIos?.version ?? '0';
    }
    return compareVersions(minimumVersion, AppConstants.appVersion) == 1;
  }

  void _applyForcedRedirects(ConfigModel? config) {
    if (config == null || !mounted) return;

    String minimumVersion = '0';
    final appVersion = config.userAppVersionControl;
    if (Platform.isAndroid) {
      minimumVersion = appVersion?.forAndroid?.version ?? '0';
    } else if (Platform.isIOS) {
      minimumVersion = appVersion?.forIos?.version ?? '0';
    }

    if (compareVersions(minimumVersion, AppConstants.appVersion) == 1) {
      RouterHelper.getUpdateRoute(action: RouteAction.pushReplacement);
      return;
    }

    if (config.maintenanceModeData?.maintenanceStatus == 1 &&
        config.maintenanceModeData?.selectedMaintenanceSystem?.customerApp ==
            1) {
      RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
    }
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
    final preloaded = SplashVideoLoader.take();
    if (preloaded != null && preloaded.value.isInitialized) {
      _controller = preloaded;
      _ownsController = true;
      _ready = true;
      preloaded.addListener(_handleVideoProgress);
      preloaded.play();
    } else {
      _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
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
    await controller.play();
  }

  void _handleVideoProgress() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _completed) {
      return;
    }

    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration <= Duration.zero) return;

    final remaining = duration - position;

    // Leave while the last frames are still on screen. Waiting for true EOS
    // blanks the video texture and shows a black gap before navigation.
    final bool nearEnd =
        position > Duration.zero && remaining <= const Duration(milliseconds: 60);
    final bool reachedEnd = position >= duration;
    final bool stoppedAtEnd = !controller.value.isPlaying &&
        position > Duration.zero &&
        remaining.inMilliseconds.abs() <= 80;

    if (nearEnd || reachedEnd || stoppedAtEnd) {
      _finishSplash();
    }
  }

  void _finishSplash() {
    if (_completed) return;
    _completed = true;
    _controller?.removeListener(_handleVideoProgress);
    // Navigate immediately — no pause/seek/post-frame (those caused the black gap).
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
      // Match video letterboxing only — transition should replace this instantly.
      color: const Color(0xFF000000),
      child: SizedBox.expand(
        child: (_ready && controller != null && controller.value.isInitialized)
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final videoSize = controller.value.size;
                  if (videoSize.width <= 0 || videoSize.height <= 0) {
                    return const SizedBox.shrink();
                  }

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
