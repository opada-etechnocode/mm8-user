import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/local/cache_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';

class DataSyncHelper {
  /// Generic method to fetch data from local and remote sources
 static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<CacheResponseData>> Function() fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic, DataSourceEnum source) onResponse,
    bool skipRemoteWhenLocalExists = false,
  }) async {

    // Step 1: Try to load from the local source
    final localResponse = await fetchFromLocal();
    final hasLocalData = localResponse.isSuccess;

    if (hasLocalData) {
      onResponse(jsonDecode(localResponse.response!.response), DataSourceEnum.local);
    }

    if (skipRemoteWhenLocalExists && hasLocalData) {
      return;
    }

    // Step 2: Try to load from the client (remote) source and update if successful
    final clientResponse = await fetchFromClient();
    if (clientResponse.isSuccess) {
      onResponse(clientResponse.response?.data, DataSourceEnum.client);
    } else {

      ApiChecker.checkApi(clientResponse);
    }

  }
}
