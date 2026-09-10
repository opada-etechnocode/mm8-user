import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:provider/provider.dart';

class NotificationRouteHelper {
  static const int _mm8SellerId = 1;
  static const String _mm8SellerName = 'MM8';

  static NotificationBody? _pendingNotificationBody;

  static void setPendingNotification(NotificationBody? body) {
    _pendingNotificationBody = body;
  }

  static NotificationBody? get pendingNotificationBody => _pendingNotificationBody;

  static NotificationBody? consumePendingNotification() {
    final body = _pendingNotificationBody;
    _pendingNotificationBody = null;
    return body;
  }

  static NotificationBody parseNotificationData(Map<String, dynamic> data) {
    final type = data['type']?.toString().trim();
    final orderId = _parseInt(data['order_id']);
    final productId = data['product_id']?.toString();
    final slug = data['slug']?.toString();
    final messageKey = data['message_key']?.toString() ?? data['body']?.toString();
    final sellerId = _parseInt(data['seller_id']);
    final deliveryManId = _parseInt(data['delivery_man_id']);
    final name = data['name']?.toString() ?? data['shop_name']?.toString();

    if (type == null || type.isEmpty) {
      if (orderId != null) {
        return NotificationBody(type: 'order', orderId: orderId);
      }
      return NotificationBody(type: 'notification');
    }

    switch (type) {
      case 'notification':
        return NotificationBody(type: 'notification');
      case 'order':
        return NotificationBody(type: 'order', orderId: orderId);
      case 'wallet':
        return NotificationBody(type: 'wallet');
      case 'block':
        return NotificationBody(type: 'block');
      case 'chatting':
        return NotificationBody(
          type: 'chatting',
          messageKey: messageKey,
          sellerId: sellerId,
          deliveryManId: deliveryManId,
          name: name,
          image: data['image']?.toString(),
        );
      case 'product_restock_update':
        return NotificationBody(
          type: 'product_restock_update',
          title: data['title']?.toString(),
          image: data['image']?.toString(),
          productId: productId,
          slug: slug,
          status: data['status']?.toString(),
        );
      case 'referral_code_used':
        return NotificationBody(
          type: 'referral_code_used',
          title: data['title']?.toString(),
          messageKey: messageKey,
          image: data['image']?.toString(),
          productId: productId,
          slug: slug,
          status: data['status']?.toString(),
        );
      default:
        if (orderId != null) {
          return NotificationBody(type: 'order', orderId: orderId);
        }
        return NotificationBody(type: 'notification');
    }
  }

  static NotificationBody notificationItemToBody(NotificationItem item) {
    final type = item.category?.trim();
    final orderId = item.orderId ?? _extractOrderId(item.title) ?? _extractOrderId(item.description);

    if (type == 'order' && orderId != null) {
      return NotificationBody(type: 'order', orderId: orderId);
    }
    if (type == 'wallet') {
      return NotificationBody(type: 'wallet');
    }
    if (type == 'chatting') {
      return NotificationBody(
        type: 'chatting',
        messageKey: item.messageKey,
        sellerId: _mm8SellerId,
        name: _mm8SellerName,
      );
    }
    if (type == 'product_restock_update' && item.productId != null) {
      return NotificationBody(
        type: 'product_restock_update',
        productId: item.productId,
        slug: item.slug,
        title: item.title,
        status: item.status?.toString(),
      );
    }
    if (orderId != null) {
      return NotificationBody(type: 'order', orderId: orderId);
    }
    if (type == 'notification' || type == null || type.isEmpty) {
      return NotificationBody(type: 'notification');
    }
    return NotificationBody(type: type, orderId: orderId, productId: item.productId, slug: item.slug, messageKey: item.messageKey);
  }

  static Future<void> navigateFromNotification(
    NotificationBody body, {
    RouteAction action = RouteAction.push,
    bool fromColdStart = false,
  }) async {
    if (fromColdStart) {
      setPendingNotification(body);
      return;
    }

    for (int i = 0; i < 30 && Get.context == null; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (Get.context == null) {
      setPendingNotification(body);
      return;
    }

    _navigate(body, action: action);
  }

  static void navigateImmediately(
    NotificationBody body, {
    RouteAction action = RouteAction.pushReplacement,
  }) {
    if (Get.context == null) {
      setPendingNotification(body);
      return;
    }
    _navigate(body, action: action);
  }

  static void _navigate(NotificationBody body, {required RouteAction action}) {
    switch (body.type) {
      case 'order':
        if (body.orderId != null) {
          RouterHelper.getOrderDetailsScreenRoute(
            action: action,
            orderId: body.orderId!,
            isNotification: true,
          );
        } else {
          RouterHelper.getNotificationRoute(action: action, fromNotification: true);
        }
        break;
      case 'wallet':
      case 'referral_code_used':
        RouterHelper.getWalletRoute(action: action, isBackButtonExist: true);
        break;
      case 'chatting':
        _openChatFromNotification(body, action: action);
        break;
      case 'product_restock_update':
        final productId = int.tryParse(body.productId ?? '');
        if (productId != null) {
          RouterHelper.getProductDetailsRoute(
            action: action,
            productId: productId,
            slug: body.slug,
            isNotification: true,
          );
        } else {
          RouterHelper.getNotificationRoute(action: action, fromNotification: true);
        }
        break;
      case 'notification':
      default:
        RouterHelper.getNotificationRoute(action: action, fromNotification: true);
        break;
    }
  }

  static void _openChatFromNotification(NotificationBody body, {required RouteAction action}) {
    final BuildContext? context = Get.context;
    final bool isDelivery = body.deliveryManId != null && body.deliveryManId! > 0;

    if (isDelivery) {
      if (context != null) {
        Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 0);
      }
      RouterHelper.getChatScreenRoute(
        action: action,
        id: body.deliveryManId,
        name: body.name ?? '',
        userType: 0,
        image: body.image ?? '',
        isDelivery: true,
        fromNotification: true,
      );
      return;
    }

    final int sellerId = (body.sellerId != null && body.sellerId! > 0)
        ? body.sellerId!
        : _mm8SellerId;

    if (context != null) {
      Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
    }

    final chatController = context != null
        ? Provider.of<ChatController>(context, listen: false)
        : null;
    final image = (body.image?.trim().isNotEmpty == true)
        ? body.image!
        : (chatController?.findSellerShopImage(sellerId) ?? '');
    final name = body.name?.trim().isNotEmpty == true
        ? body.name!
        : (chatController?.findSellerShopName(sellerId) ?? _mm8SellerName);

    RouterHelper.getChatScreenRoute(
      action: action,
      id: sellerId,
      name: name,
      userType: 1,
      image: image,
      isShopOnVacation: false,
      isShopTemporaryClosed: false,
      fromNotification: true,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static int? _extractOrderId(String? text) {
    if (text == null || text.isEmpty) return null;
    final hashMatch = RegExp(r'#(\d+)').firstMatch(text);
    if (hashMatch != null) {
      return int.tryParse(hashMatch.group(1)!);
    }
    final orderMatch = RegExp(r'order[^\d]*(\d+)', caseSensitive: false).firstMatch(text);
    if (orderMatch != null) {
      return int.tryParse(orderMatch.group(1)!);
    }
    return null;
  }
}
