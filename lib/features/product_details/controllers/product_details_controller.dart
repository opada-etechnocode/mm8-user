import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/seller_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/services/product_details_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/enums/preview_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ProductDetailsController extends ChangeNotifier {
  final ProductDetailsServiceInterface productDetailsServiceInterface;
  ProductDetailsController({required this.productDetailsServiceInterface});


  int? _imageSliderIndex = 0;
  int? _quantity = 0;
  int? _variantIndex;
  List<int>? _variationIndex;
  int? _orderCount;
  int? _wishCount;
  String? _sharableLink;
  int? _digitalVariationIndex = 0;
  int? _digitalVariationSubindex = 0;
  bool _isDownloadLoading = false;

  bool _isDetails = false;
  bool get isDetails =>_isDetails;
  int? get imageSliderIndex => _imageSliderIndex;
  int? get quantity => _quantity;
  int? get variantIndex => _variantIndex;
  List<int>? get variationIndex => _variationIndex;
  int? get orderCount => _orderCount;
  int? get wishCount => _wishCount;
  String? get sharableLink => _sharableLink;
  ProductDetailsModel? _productDetailsModel;
  ProductDetailsModel? get productDetailsModel => _productDetailsModel;
  int? get digitalVariationIndex => _digitalVariationIndex;
  int? get digitalVariationSubindex => _digitalVariationSubindex;
  bool get isDownloadLoading => _isDownloadLoading;



  Future<void> getProductDetails(BuildContext context, String productId, String slug) async {
    _isDetails = true;
    log("=====slug===>$slug/ $productId");
    ApiResponseModel apiResponse = await productDetailsServiceInterface.get(slug);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isDetails = false;
      _productDetailsModel = ProductDetailsModel.fromJson(apiResponse.response!.data);
      if(_productDetailsModel != null){
        log("=====slug===>$slug/ $productId");
        final sellerProductController =
            Provider.of<SellerProductController>(Get.context!, listen: false);
        final splashController =
            Provider.of<SplashController>(Get.context!, listen: false);

        String? sellerSlug;
        if (_productDetailsModel?.addedBy == 'admin') {
          sellerSlug = splashController.configModel?.inHouseShop?.slug;
        } else {
          sellerSlug = _productDetailsModel?.seller?.shop?.slug?.toString();
        }

        if (sellerSlug != null && sellerSlug.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 700), () {
            if (Get.context == null) return;
            sellerProductController.getSellerMoreProductList(
              sellerSlug!,
              1,
              productId,
            );
          });
        }
      }
    } else {
      _isDetails = false;
      showCustomSnackBarWidget(apiResponse.error.toString(), Get.context!, snackBarType: SnackBarType.error);
    }
    _isDetails = false;
    notifyListeners();
  }




  void initData(ProductDetailsModel product, int? minimumOrderQuantity, BuildContext context) {
    _variantIndex = 0;
    _quantity = minimumOrderQuantity;
    _variationIndex = [];
    final choiceCount = product.choiceOptions?.length ?? 0;
    for (int i = 0; i <= choiceCount; i++) {
      _variationIndex!.add(0);
    }
  }

  bool isReviewSelected = false;
  void selectReviewSection(bool review, {bool isUpdate = true}){
    isReviewSelected = review;

    if(isUpdate) {
      notifyListeners();

    }
  }



  void getCount(String productID, BuildContext context) async {
    ApiResponseModel apiResponse = await productDetailsServiceInterface.getCount(productID);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _orderCount = apiResponse.response!.data['order_count'];
      _wishCount = apiResponse.response!.data['wishlist_count'];
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }


  void getSharableLink(String productID, BuildContext context) async {
    ApiResponseModel apiResponse = await productDetailsServiceInterface.getSharableLink(productID);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _sharableLink = apiResponse.response!.data;
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }



  void setImageSliderSelectedIndex(int selectedIndex, {bool isUpdate = true}) {
    _imageSliderIndex = selectedIndex;
    if(isUpdate) {
      notifyListeners();
    }
  }

  int? findColorIndexForImage(ProductDetailsModel product, String? imagePath, {int? imageIndex}) {
    if (imagePath == null || imagePath.isEmpty) return null;

    if (product.colorImagesFullUrl != null &&
        product.colorImagesFullUrl!.isNotEmpty &&
        product.colors != null) {
      for (final colorImage in product.colorImagesFullUrl!) {
        if (colorImage.imageName?.path == imagePath) {
          final colorKey = colorImage.color;
          for (int i = 0; i < product.colors!.length; i++) {
            final code = product.colors![i].code;
            if (code != null && code.length >= 7 && code.substring(1, 7) == colorKey) {
              return i;
            }
          }
        }
      }
    }

    if (imageIndex != null &&
        product.colors != null &&
        product.colors!.isNotEmpty &&
        product.imagesFullUrl != null &&
        product.colors!.length == product.imagesFullUrl!.length) {
      return imageIndex;
    }

    return null;
  }

  Variation? _resolveVariation(ProductDetailsModel product, int colorIndex) {
    if (product.variation == null || product.variation!.isEmpty) return null;

    String? variantName = (product.colors != null && product.colors!.isNotEmpty)
        ? product.colors![colorIndex].name
        : null;

    final variationList = <String>[];
    final choiceCount = product.choiceOptions?.length ?? 0;
    for (int index = 0; index < choiceCount; index++) {
      final optionIndex = (_variationIndex != null && _variationIndex!.length > index)
          ? _variationIndex![index]
          : 0;
      variationList.add(product.choiceOptions![index].options![optionIndex].trim());
    }

    String variationType = '';
    if (variantName != null) {
      variationType = variantName;
      for (final variation in variationList) {
        variationType = '$variationType-$variation';
      }
    } else {
      bool isFirst = true;
      for (final variation in variationList) {
        if (isFirst) {
          variationType = variation;
          isFirst = false;
        } else {
          variationType = '$variationType-$variation';
        }
      }
    }

    variationType = variationType.replaceAll(' ', '');
    for (final variation in product.variation!) {
      if (variation.type == variationType) {
        return variation;
      }
    }
    return null;
  }

  int? _resolveStock(ProductDetailsModel product, int colorIndex) {
    final variation = _resolveVariation(product, colorIndex);
    return variation?.qty ?? product.currentStock;
  }

  Future<void> addToCartFromColorIndex(BuildContext context, ProductDetailsModel product, int colorIndex) async {
    final splashController = Provider.of<SplashController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);

    if (splashController.configModel?.guestCheckOut == 0 && !authController.isLoggedIn()) {
      showCustomSnackBarWidget(getTranslated('please_login', context), context, snackBarType: SnackBarType.warning);
      return;
    }

    if (_variationIndex == null || _variantIndex == null) {
      initData(product, product.minimumOrderQty ?? 1, context);
    }

    setCartVariantIndex(product.minimumOrderQty ?? 1, colorIndex, context);

    final stock = _resolveStock(product, colorIndex);
    final minQty = product.minimumOrderQty ?? 1;

    if (product.productType == 'physical' && (stock ?? 0) < minQty) {
      showCustomSnackBarWidget(getTranslated('out_of_stock', context), context, snackBarType: SnackBarType.warning);
      return;
    }

    final variation = _resolveVariation(product, colorIndex);
    final cart = CartModelBody(
      productId: product.id,
      variant: (product.colors != null && product.colors!.isNotEmpty)
          ? product.colors![colorIndex].name
          : '',
      color: (product.colors != null && product.colors!.isNotEmpty)
          ? product.colors![colorIndex].code
          : '',
      variation: variation,
      quantity: _quantity ?? minQty,
    );

    await Provider.of<CartController>(context, listen: false).addToCartAPI(
      cart,
      context,
      product.choiceOptions ?? [],
      _variationIndex,
      popOnSuccess: false,
      showFloatingCartSummary: true,
    );
  }


  void setQuantity(int value) {
    _quantity = value;
    notifyListeners();
  }

  void setCartVariantIndex(int? minimumOrderQuantity,int index, BuildContext context) {
    _variantIndex = index;
    _quantity = minimumOrderQuantity;
    notifyListeners();
  }

  void setCartVariationIndex(int? minimumOrderQuantity, int index, int i, BuildContext context) {
    _variationIndex![index] = i;
    _quantity = minimumOrderQuantity;
    notifyListeners();
  }


  void removePrevLink() {
    _sharableLink = null;
  }

  bool isValidYouTubeUrl(String url) {
    RegExp regex = RegExp(
      r'^https?:\/\/(?:www\.)?(youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );

    return regex.hasMatch(url);
  }

  void setDigitalVariationIndex(int? minimumOrderQuantity, int index, int subIndex, BuildContext context) {
    _quantity = minimumOrderQuantity;
    _digitalVariationIndex = index;
    _digitalVariationSubindex = subIndex;
    notifyListeners();
  }

  void initDigitalVariationIndex() {
    _digitalVariationIndex = 0;
    _digitalVariationSubindex = 0;
  }


  PreviewType getFileType(String url) {
    if(url.contains('.pdf')) {
      return PreviewType.pdf;
    } else if(url.contains('.jpg') || url.contains('.jpeg') || url.contains('.png')) {
      return  PreviewType.image;
    } else if(url.contains('.mp4') || url.contains('.mkv') || url.contains('.avi') || url.contains('.flv') || url.contains('.mov') || url.contains('.wmv') || url.contains('.webm')) {
      return PreviewType.video;
    } else if ( url.contains('.mp3') || url.contains('.wav') || url.contains('.aac') || url.contains('.wma') || url.contains('.amr')) {
      return PreviewType.audio;
    }else {
      return PreviewType.others;
    }
  }



  void previewDownload({required String url, required String fileName, bool isIos = false}) async {
    _isDownloadLoading = true;
    notifyListeners();

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var selectedFolderType = AndroidFolderType.download;
    final subFolderPathCtrl = TextEditingController();


    List<String> fileTypes = [ '.txt', '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.mp3', '.wav', '.ogg', '.m4a', '.aac',
      '.mp4', '.avi', '.mkv', '.webm', '.3gp', '.pdf', '.doc'];

    if(isIos) {
      HttpClientResponse apiResponse = await productDetailsServiceInterface.previewDownload(url);
      if (apiResponse.statusCode == 200) {

        List<int> downloadData = [];
        Directory downloadDirectory;

        if (Platform.isIOS) {
          downloadDirectory = await getApplicationDocumentsDirectory();
        } else {
          downloadDirectory = Directory('/storage/emulated/0/Download');
          if (!await downloadDirectory.exists()) downloadDirectory = (await getExternalStorageDirectory())!;
        }

        String filePathName = "${downloadDirectory.path}/$fileName";
        File savedFile = File(filePathName);
        bool fileExists = await savedFile.exists();

        if (fileExists) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(content: Text("File already downloaded")));
          _isDownloadLoading = false;
        } else {
          apiResponse.listen((d) => downloadData.addAll(d), onDone: () {
            savedFile.writeAsBytes(downloadData);
          });
          showCustomSnackBarWidget(getTranslated('product_downloaded_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.success);

          _isDownloadLoading = false;
          Navigator.of(Get.context!).pop();
        }
      } else {
        _isDownloadLoading = false;

        showCustomSnackBarWidget(getTranslated('product_download_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
        Navigator.of(Get.context!).pop();
      }
    } else {
      String? task;
      Directory downloadDirectory = Directory('/storage/emulated/0/Download');
      String filePathName = "${downloadDirectory.path}/$fileName";
      File savedFile = File(filePathName);
      bool fileExists = await savedFile.exists();

      if(fileExists) {
        showCustomSnackBarWidget(getTranslated('file_already_downloaded', Get.context!), Get.context!, snackBarType: SnackBarType.warning);
      } else{
        task  = await FlutterDownloader.enqueue(
          url: url,
          savedDir: downloadDirectory.path,
          fileName: fileName,
          showNotification: true,
          saveInPublicStorage: true,
          openFileFromNotification: true,
        );

        if(task != null) {
          if(!fileTypes.contains(getFileExtension(fileName))) {
            showCustomSnackBarWidget(getTranslated('product_downloaded_successfully', Get.context!), Get.context!, snackBarType: SnackBarType.error);
            await openFileManager(
              androidConfig: AndroidConfig(
                folderType: selectedFolderType,
              ),
              iosConfig: IosConfig(
                folderPath: subFolderPathCtrl.text.trim(),
              ),
            );
          }else {
            Navigator.of(Get.context!).pop();
          }
        } else {
          showCustomSnackBarWidget(getTranslated('product_download_failed', Get.context!), Get.context!, snackBarType: SnackBarType.error);
          Navigator.of(Get.context!).pop();
        }
      }
      _isDownloadLoading = false;
    }
    notifyListeners();
  }


  String getFileExtension(String fileName) {
    if (fileName.contains('.')) {
      return '.${fileName.split('.').last}';
    }
    return '';
  }


  void updateProductRestock({String? variantKey}) {
    if(_productDetailsModel != null){
      _productDetailsModel?.isRestockRequested = 1;
      if(variantKey != null && variantKey.isNotEmpty) {
        _productDetailsModel?.restockRequestedList?.add(variantKey);
      }
    }
    notifyListeners();
  }


}
