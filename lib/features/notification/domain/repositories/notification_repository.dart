import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/repositories/notification_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository implements NotificationRepositoryInterface{
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  NotificationRepository({required this.dioClient, this.sharedPreferences});

  @override
  Future<ApiResponseModel>  getList({int? offset}) async {
    try {
      Response response = await dioClient!.get('${AppConstants.notificationUri}?limit=10&guest_id=1&offset=$offset');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel>  seenNotification(int id) async {
    try {
      Response response = await dioClient!.get('${AppConstants.seenNotificationUri}?id=$id&guest_id=1');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Set<int> getDeletedNotificationIds() {
    final ids = sharedPreferences?.getStringList(AppConstants.deletedNotificationIds) ?? [];
    return ids.map(int.parse).toSet();
  }

  @override
  Future<void> cacheDeletedNotificationId(int id) async {
    final deletedIds = getDeletedNotificationIds()..add(id);
    await sharedPreferences?.setStringList(
      AppConstants.deletedNotificationIds,
      deletedIds.map((e) => e.toString()).toList(),
    );
  }

  @override
  Future<void> cacheDeletedNotificationIds(List<int> ids) async {
    if (ids.isEmpty) return;
    final deletedIds = getDeletedNotificationIds()..addAll(ids);
    await sharedPreferences?.setStringList(
      AppConstants.deletedNotificationIds,
      deletedIds.map((e) => e.toString()).toList(),
    );
  }

  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }


  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }
}