import 'dart:async';

import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:go_router/go_router.dart';

class DeepLinkHelper {
  static String? _pendingDeepLink;
  static bool _isBootstrapping = true;

  static bool get isBootstrapping => _isBootstrapping;
  static bool get hasPendingDeepLink =>
      _pendingDeepLink != null && _pendingDeepLink!.isNotEmpty;

  static void markBootstrapComplete() {
    _isBootstrapping = false;
  }

  static void setPendingDeepLink(String? location) {
    if (location == null || location.isEmpty) return;
    _pendingDeepLink = location;
  }

  static String? peekPendingDeepLink() => _pendingDeepLink;

  static String? consumePendingDeepLink() {
    final location = _pendingDeepLink;
    _pendingDeepLink = null;
    return location;
  }

  static String uriToRouteLocation(Uri uri) {
    if (uri.query.isEmpty) return uri.path;
    return '${uri.path}?${uri.query}';
  }

  static bool isSupportedDeepLink(Uri uri) {
    if (uri.scheme != 'https' && uri.scheme != 'http') return false;
    final host = uri.host.toLowerCase();
    if (host != 'www.mm8market.com' && host != 'mm8market.com') return false;

    final path = uri.path;
    if (path.startsWith('/product/')) return true;
    if (path.startsWith('/vendor-shop/')) return true;
    if (path == '/track-order' || path.startsWith('/track-order/')) return true;
    if (path == '/referral-login' || path.startsWith('/referral-login/')) return true;
    return false;
  }

  static void handleIncomingUri(Uri uri) {
    if (!isSupportedDeepLink(uri)) return;

    setPendingDeepLink(uriToRouteLocation(uri));

    if (!_isBootstrapping) {
      unawaited(tryNavigatePendingDeepLinkWithRetry());
    }
  }

  static Future<void> navigateFromUri(
    Uri uri, {
    RouteAction action = RouteAction.push,
    bool fromColdStart = false,
  }) async {
    if (!isSupportedDeepLink(uri)) return;

    if (fromColdStart || _isBootstrapping) {
      handleIncomingUri(uri);
      return;
    }

    for (int i = 0; i < 30 && Get.context == null; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    handleIncomingUri(uri);
    if (hasPendingDeepLink) {
      await tryNavigatePendingDeepLinkWithRetry(action: action);
    }
  }

  static Future<bool> tryNavigatePendingDeepLinkWithRetry({
    RouteAction action = RouteAction.pushReplacement,
    int maxAttempts = 50,
  }) async {
    final location = peekPendingDeepLink();
    if (location == null) return false;

    consumePendingDeepLink();
    final success = await navigateImmediatelyWithRetry(
      location,
      action: action,
      maxAttempts: maxAttempts,
    );
    if (!success) {
      setPendingDeepLink(location);
    }
    return success;
  }

  static Future<bool> navigateImmediatelyWithRetry(
    String location, {
    RouteAction action = RouteAction.pushReplacement,
    int maxAttempts = 50,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      if (navigateImmediately(location, action: action)) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  static bool navigateImmediately(
    String location, {
    RouteAction action = RouteAction.pushReplacement,
  }) {
    final context = Get.context;
    if (context == null) {
      setPendingDeepLink(location);
      return false;
    }

    switch (action) {
      case RouteAction.push:
        context.push(location);
        break;
      case RouteAction.pushReplacement:
        context.go(location);
        break;
      case RouteAction.pushNamedAndRemoveUntil:
        context.go(location);
        break;
    }
    return true;
  }
}
