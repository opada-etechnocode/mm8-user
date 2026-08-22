import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:go_router/go_router.dart';

class DeepLinkHelper {
  static String? _pendingDeepLink;

  static void setPendingDeepLink(String? location) {
    if (location == null || location.isEmpty) return;
    _pendingDeepLink = location;
  }

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

  static Future<void> navigateFromUri(
    Uri uri, {
    RouteAction action = RouteAction.push,
    bool fromColdStart = false,
  }) async {
    if (!isSupportedDeepLink(uri)) return;

    final location = uriToRouteLocation(uri);
    if (fromColdStart) {
      setPendingDeepLink(location);
      return;
    }

    for (int i = 0; i < 30 && Get.context == null; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (Get.context == null) {
      setPendingDeepLink(location);
      return;
    }

    navigateImmediately(location, action: action);
  }

  static void navigateImmediately(
    String location, {
    RouteAction action = RouteAction.pushReplacement,
  }) {
    final context = Get.context;
    if (context == null) {
      setPendingDeepLink(location);
      return;
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
  }
}
