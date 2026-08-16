import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/services/notification_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class NotificationController extends ChangeNotifier {
  final NotificationServiceInterface notificationServiceInterface;

  NotificationController({required this.notificationServiceInterface});

  NotificationItemModel? notificationModel;
  Set<int> _deletedNotificationIds = {};

  int get notificationBadgeCount =>
      notificationModel?.newNotificationItem ?? 0;

  bool get hasVisibleNotifications =>
      notificationModel?.notification?.isNotEmpty ?? false;

  void _loadDeletedIds() {
    _deletedNotificationIds =
        notificationServiceInterface.getDeletedNotificationIds();
  }

  void _applyDeletedFilter() {
    if (notificationModel?.notification == null) return;
    notificationModel!.notification!.removeWhere(
      (item) => _deletedNotificationIds.contains(item.id),
    );
    _recalculateBadgeCount();
  }

  void _recalculateBadgeCount() {
    if (notificationModel == null) return;
    notificationModel!.newNotificationItem = notificationModel!.notification
            ?.where((item) => item.seen == null)
            .length ??
        0;
  }

  Future<void> getNotificationList(int offset) async {
    _loadDeletedIds();
    ApiResponseModel apiResponse =
        await notificationServiceInterface.getList(offset: offset);
    if (apiResponse.response != null &&
        apiResponse.response?.statusCode == 200) {
      final parsed =
          NotificationItemModel.fromJson(apiResponse.response?.data);
      if (offset == 1) {
        notificationModel = parsed;
      } else {
        notificationModel?.notification
            ?.addAll(parsed.notification ?? []);
        notificationModel?.offset = parsed.offset;
        notificationModel?.totalSize = parsed.totalSize;
      }
      _applyDeletedFilter();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> seenNotification(int id) async {
    ApiResponseModel apiResponse =
        await notificationServiceInterface.seenNotification(id);
    if (apiResponse.response != null &&
        apiResponse.response?.statusCode == 200) {
      getNotificationList(1);
    }
    notifyListeners();
  }

  Future<void> deleteNotification(int id) async {
    await notificationServiceInterface.cacheDeletedNotificationId(id);
    _deletedNotificationIds.add(id);
    notificationModel?.notification?.removeWhere((item) => item.id == id);
    _recalculateBadgeCount();
    if (notificationModel?.notification?.isEmpty ?? false) {
      notificationModel?.totalSize = 0;
    }
    notifyListeners();
  }

  Future<void> deleteAllNotifications() async {
    final ids = notificationModel?.notification
            ?.where((item) => item.id != null)
            .map((item) => item.id!)
            .toList() ??
        [];
    if (ids.isEmpty) return;
    await notificationServiceInterface.cacheDeletedNotificationIds(ids);
    _deletedNotificationIds.addAll(ids);
    notificationModel?.notification?.clear();
    notificationModel?.newNotificationItem = 0;
    notificationModel?.totalSize = 0;
    notifyListeners();
  }
}
