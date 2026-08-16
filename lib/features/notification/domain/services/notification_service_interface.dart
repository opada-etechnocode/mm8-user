abstract class NotificationServiceInterface{

  Future<dynamic> getList({int? offset = 1});
  Future<dynamic>  seenNotification(int id);
  Set<int> getDeletedNotificationIds();
  Future<void> cacheDeletedNotificationId(int id);
  Future<void> cacheDeletedNotificationIds(List<int> ids);

}