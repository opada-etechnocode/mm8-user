import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';

abstract class NotificationRepositoryInterface implements RepositoryInterface{
  Future<dynamic>  seenNotification(int id);
  Set<int> getDeletedNotificationIds();
  Future<void> cacheDeletedNotificationId(int id);
  Future<void> cacheDeletedNotificationIds(List<int> ids);

}