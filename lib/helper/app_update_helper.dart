import 'dart:io';

import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:go_router/go_router.dart';

class AppUpdateHelper {
  static bool needsForceUpdate(ConfigModel? config) {
    if (config == null) return false;

    final ForAndroid? platform = Platform.isIOS
        ? config.userAppVersionControl?.forIos
        : config.userAppVersionControl?.forAndroid;

    if (platform == null || platform.status != 1) return false;

    final minimumVersion = platform.version?.trim() ?? '';
    if (minimumVersion.isEmpty) return false;

    return compareVersions(minimumVersion, AppConstants.appVersion) == 1;
  }

  static void redirectIfNeeded(ConfigModel? config) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final router = GoRouter.of(context);
    final path = router.routerDelegate.currentConfiguration.uri.path;
    final needsUpdate = needsForceUpdate(config);

    if (needsUpdate && path != RouterHelper.updateScreen) {
      context.go(RouterHelper.updateScreen);
      return;
    }

    if (!needsUpdate && path == RouterHelper.updateScreen) {
      context.go(RouterHelper.dashboardScreen);
    }
  }

  static int compareVersions(String version1, String version2) {
    final v1Components = version1.split('.');
    final v2Components = version2.split('.');
    final maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      final v1Part = i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      final v2Part = i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;
      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }
    return 0;
  }
}
