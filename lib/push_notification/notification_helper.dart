import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/demo_reset_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/restock/controllers/restock_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/restock/widgets/restock_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/notification_route_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NotificationHelper {


  // {is_read: 0, image: , body: new-messages.demo_data_is_being_reset_to_default., type: demo_reset, title: Demo reset alert, order_id: }

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    flutterLocalNotificationsPlugin.initialize(settings: initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse load) async {
      try{
        if(load.payload == null || load.payload!.isEmpty) return;
        final payload = NotificationBody.fromJson(jsonDecode(load.payload!));
        await NotificationRouteHelper.navigateFromNotification(
          payload,
          action: RouteAction.pushReplacement,
        );
      }catch (e) {
        if (kDebugMode) {
          debugPrint('Notification tap error: $e');
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("-----------onMessage: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
        print("---------onMessage type: ${message.data['type']}/${message.data}");
        if(message.data['type'] == "block") {
          Provider.of<AuthController>(Get.context!,listen: false).clearSharedData();
          Provider.of<AddressController>(Get.context!, listen: false).getAddressList();
          RouterHelper.getLoginRoute(action: RouteAction.pushNamedAndRemoveUntil);
        }
      }

      if(message.data['type'] == 'referral_code_used'){
        await Provider.of<WalletController>(Get.context!, listen: false).getTransactionList(1);
      }

      if(message.data['type'] == 'maintenance_mode') {
        final SplashController splashProvider = Provider.of<SplashController>(Get.context!,listen: false);
        await splashProvider.initConfig(Get.context!, null, null);

        ConfigModel? config = Provider.of<SplashController>(Get.context!,listen: false).configModel;

        bool isMaintenanceRoute = Provider.of<SplashController>(Get.context!,listen: false).isMaintenanceModeScreen();

        if(config?.maintenanceModeData?.maintenanceStatus == 1 && (config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1)) {
          RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
        }else if (config?.maintenanceModeData?.maintenanceStatus == 0 && isMaintenanceRoute) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
        }
      }

      if(message.data['type'] != 'maintenance_mode' && message.data['type'] != 'product_restock_update') {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
      }

      if(message.data['type'] == 'product_restock_update' && !Provider.of<RestockController>(Get.context!, listen: false).isBottomSheetOpen){
        NotificationBody notificationBody = convertNotification(message.data);
        Provider.of<RestockController>(Get.context!, listen: false).setBottomSheetOpen(true);
        final result = await showModalBottomSheet(context: Get.context!, isScrollControlled: true,
          backgroundColor: Theme.of(Get.context!).primaryColor.withValues(alpha:0),
          builder: (con) => RestockSheetWidget(notificationBody: notificationBody),
        );

        if (result == null) {
          Provider.of<RestockController>(Get.context!, listen: false).setBottomSheetOpen(false);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print("onOpenApp: ${message.notification!.title}/${message.data}/${message.notification!.titleLocKey}");
      }
      if(message.data['type'] == 'demo_reset') {
        showDialog(context: Get.context!, builder: (context) => const Dialog(
          backgroundColor: Colors.transparent,
          child: DemoResetDialogWidget()));
      }
      try{
        if(message.data.isNotEmpty) {
          final notificationBody = convertNotification(message.data);
          await NotificationRouteHelper.navigateFromNotification(
            notificationBody,
            action: RouteAction.pushReplacement,
          );
        }
      }catch (e) {
        if (kDebugMode) {
          debugPrint('onMessageOpenedApp navigation error: $e');
        }
      }

      if(message.data['type'] == 'maintenance_mode') {
        final SplashController splashProvider = Provider.of<SplashController>(Get.context!,listen: false);
        await splashProvider.initConfig(Get.context!, null, null);

        ConfigModel? config = Provider.of<SplashController>(Get.context!,listen: false).configModel;

        bool isMaintenanceRoute = Provider.of<SplashController>(Get.context!,listen: false).isMaintenanceModeScreen();

        if(config?.maintenanceModeData?.maintenanceStatus == 1 && (config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1)) {
          RouterHelper.getMaintenanceRoute(action: RouteAction.pushReplacement);
        }else if (config?.maintenanceModeData?.maintenanceStatus == 0 && isMaintenanceRoute) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement);
        }
      }

    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    String? title;
    String? body;
    String? orderID;
    String? image;
    NotificationBody notificationBody = convertNotification(message.data);

    if(data) {
      title = message.data['title']?.toString();
      body = message.data['body']?.toString();
      orderID = message.data['order_id']?.toString();
      image = (message.data['image'] != null && message.data['image'].toString().isNotEmpty)
          ? message.data['image'].toString().startsWith('http') ? message.data['image'].toString()
          : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;
    } else {
      title = message.notification?.title ?? message.data['title']?.toString();
      body = message.notification?.body ?? message.data['body']?.toString();
      orderID = message.notification?.titleLocKey ?? message.data['order_id']?.toString();
      if(Platform.isAndroid) {
        image = (message.notification?.android?.imageUrl != null && message.notification!.android!.imageUrl!.isNotEmpty)
            ? message.notification!.android!.imageUrl!.startsWith('http') ? message.notification!.android!.imageUrl
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification?.android?.imageUrl}' : null;
      } else if(Platform.isIOS) {
        image = (message.notification?.apple?.imageUrl != null && message.notification!.apple!.imageUrl!.isNotEmpty)
            ? message.notification!.apple!.imageUrl!.startsWith('http') ? message.notification?.apple?.imageUrl
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.apple!.imageUrl}' : null;
      }
    }

    if (title == null || title.isEmpty) return;
    body ??= title;

    if (Platform.isIOS) {
      await showIOSNotification(title, body, notificationBody, fln);
      return;
    }

    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, orderID, notificationBody, image, fln);
      }catch(e) {
        await showBigTextNotification(title, body, orderID, notificationBody, fln);
      }
    }else {
      await showBigTextNotification(title, body, orderID, notificationBody, fln);
    }
  }

  static Future<void> showIOSNotification(
    String title,
    String body,
    NotificationBody? notificationBody,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    await fln.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null,
    );
  }

  static Future<void> showTextNotification(String title, String body, String orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6valley', '6valley', playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0, title: title, body:  body, notificationDetails: platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String? title, String body, String? orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6valley', '6valley', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0, title: title, body:  body, notificationDetails: platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, String? orderID, NotificationBody? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6valley', '6valley',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: 0, title : title, body: body, notificationDetails: platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBody convertNotification(Map<String, dynamic> data){
    return NotificationRouteHelper.parseNotificationData(data);
  }

}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("onBackground: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
  }
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}