import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/discount_tag_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/image_full_url.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/compare/controllers/compare_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/enums/preview_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/audio_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/download_preview_file.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/favourite_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/image_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/pdf_preview_flutter.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/screens/product_image_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_image_helper.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/video_preview.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/shop_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/controllers/localization_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ProductImageWidget extends StatefulWidget {
  final ProductDetailsModel? productModel;
  final bool fromFlashDeals;

  const ProductImageWidget({
    super.key,
    required this.productModel,
    required this.fromFlashDeals,
  });

  @override
  State<ProductImageWidget> createState() => _ProductImageWidgetState();
}

class _ProductImageWidgetState extends State<ProductImageWidget> {
  static const double _galleryMainSize = 80;
  static const double _galleryScrollItemSize = 72;

  late final PageController _controller;
  bool _vacationIsOn = false;
  bool _temporaryClose = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _initShopStatus();
  }

  void _initShopStatus() {
    final product = widget.productModel;
    _vacationIsOn = ShopHelper.isVacationActive(
      context,
      startDate: product?.seller?.shop?.vacationStartDate,
      endDate: product?.seller?.shop?.vacationEndDate,
      vacationDurationType: product?.seller?.shop?.vacationDurationType,
      vacationStatus: product?.seller?.shop?.vacationStatus,
      isInHouseSeller: product?.addedBy == 'admin',
    );

    if (product?.addedBy == 'admin') {
      _temporaryClose = Provider.of<SplashController>(context, listen: false)
              .configModel
              ?.inhouseTemporaryClose
              ?.status ??
          false;
    } else {
      _temporaryClose = product?.seller?.shop?.temporaryClose ?? false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ProductDetailsModel? get productModel => widget.productModel;

  void _openImageGallery(
    BuildContext context, {
    required List<ImageFullUrl> images,
    int initialIndex = 0,
  }) {
    if (images.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ProductImageScreen(
            title: getTranslated('product_image', context),
            imageList: images,
            initialIndex: initialIndex.clamp(0, images.length - 1),
          );
        },
      ),
    );
  }

  void _selectImagePath(
    ProductDetailsController productController,
    ProductImageGroupItem group,
    String? imagePath,
  ) {
    if (imagePath == null || imagePath.isEmpty) return;

    final images = productModel!.imagesFullUrl ?? [];
    final index = images.indexWhere((image) => image.path == imagePath);
    if (index < 0) return;

    productController.setImageSliderSelectedIndex(index);
    if (group.colorIndex != null) {
      if (productController.variationIndex == null || productController.variantIndex == null) {
        productController.initData(
          productModel!,
          productModel!.minimumOrderQty ?? 1,
          context,
        );
      }
      productController.setCartVariantIndex(
        productModel!.minimumOrderQty ?? 1,
        group.colorIndex!,
        context,
      );
    }
    if (_controller.hasClients) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _addToCartFromColor(BuildContext context, int colorIndex) async {
    if (_vacationIsOn || _temporaryClose) {
      showCustomSnackBarWidget(
        getTranslated('this_shop_is_close_now', context),
        context,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    await Provider.of<ProductDetailsController>(context, listen: false)
        .addToCartFromColorIndex(context, productModel!, colorIndex);
  }

  Widget _buildCartOverlay(BuildContext context, int colorIndex) {
    return Consumer<ProductDetailsController>(
      builder: (context, productController, _) {
        final isLoading = productController.isAddingToCartForColor(colorIndex);

        return Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isLoading ? null : () => _addToCartFromColor(context, colorIndex),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Align(
                alignment: Alignment.topRight,
                child: Material(
                  color: Theme.of(context).cardColor,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: isLoading
                        ? SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : Image.asset(
                            Images.cartArrowDownImage,
                            height: 14,
                            width: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageCell({
    required BuildContext context,
    required ProductDetailsController productController,
    required ProductImageGroupItem group,
    required ImageFullUrl image,
    required double size,
    required bool isSelected,
    int? colorIndex,
  }) {
    final imagePath = image.path ?? '';

    return GestureDetector(
      onTap: () => _selectImagePath(productController, group, imagePath),
      onLongPress: () {
        final galleryIndex = group.images.indexWhere((item) => item.path == imagePath);
        _openImageGallery(
          context,
          images: group.images,
          initialIndex: galleryIndex >= 0 ? galleryIndex : 0,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            width: isSelected ? 2 : 1,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor.withValues(alpha: 0.2),
          ),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              child: CustomImageWidget(
                height: size,
                width: size,
                maxCacheSize: 256,
                image: imagePath,
              ),
            ),
            if (colorIndex != null) _buildCartOverlay(context, colorIndex),
          ],
        ),
      ),
    );
  }

  bool _isImageSelected(ProductDetailsController productController, String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return false;
    final selectedIndex = productController.imageSliderIndex ?? 0;
    return productModel!.imagesFullUrl?[selectedIndex].path == imagePath;
  }

  Widget _buildColorGallery(BuildContext context, ProductDetailsController productController) {
    final galleryGroups = ProductImageHelper.getColorGalleryItems(productModel!);
    if (galleryGroups.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        left: Provider.of<LocalizationController>(context, listen: false).isLtr
            ? Dimensions.homePagePadding
            : 0,
        right: Provider.of<LocalizationController>(context, listen: false).isLtr
            ? 0
            : Dimensions.homePagePadding,
        bottom: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        children: [
          for (final group in galleryGroups) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImageCell(
                  context: context,
                  productController: productController,
                  group: group,
                  image: group.thumbnail,
                  size: _galleryMainSize,
                  isSelected: _isImageSelected(productController, group.thumbnail.path),
                  colorIndex: group.colorIndex,
                ),
                if (group.images.length > 1) ...[
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: SizedBox(
                      height: _galleryScrollItemSize,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: group.images.length - 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                        itemBuilder: (context, index) {
                          final image = group.images[index + 1];
                          return _buildImageCell(
                            context: context,
                            productController: productController,
                            group: group,
                            image: image,
                            size: _galleryScrollItemSize,
                            isSelected: _isImageSelected(productController, image.path),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
        ],
      ),
    );
  }

  Widget _buildMoreImagesSection(
    BuildContext context,
    ProductDetailsController productController,
  ) {
    final extraImages = ProductImageHelper.getAdditionalImageItems(productModel!);
    if (extraImages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        left: Provider.of<LocalizationController>(context, listen: false).isLtr
            ? Dimensions.homePagePadding
            : 0,
        right: Provider.of<LocalizationController>(context, listen: false).isLtr
            ? 0
            : Dimensions.homePagePadding,
        bottom: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated('more_images', context) ?? 'More images',
            style: titilliumSemiBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SizedBox(
            height: _galleryScrollItemSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: extraImages.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                final group = extraImages[index];
                return _buildImageCell(
                  context: context,
                  productController: productController,
                  group: group,
                  image: group.thumbnail,
                  size: _galleryScrollItemSize,
                  isSelected: _isImageSelected(productController, group.thumbnail.path),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final splashController = Provider.of<SplashController>(context, listen: false);
    final bool isDarkTheme = Provider.of<ThemeController>(context).darkTheme;
    final imageWidth = MediaQuery.sizeOf(context).width;
    final imageHeight = imageWidth;

    if (productModel == null) {
      return const SizedBox.shrink();
    }

    return Consumer<ProductDetailsController>(
      builder: (context, productController, _) {
        final selectedIndex = productController.imageSliderIndex ?? 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.homePagePadding,
                top: Dimensions.homePagePadding,
                right: Dimensions.homePagePadding,
                bottom: Dimensions.paddingSizeEight,
              ),
              child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                              color: isDarkTheme
                                  ? Theme.of(context).hintColor.withValues(alpha: .25)
                                  : Theme.of(context).primaryColor.withValues(alpha: .25),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            onTap: () {
                              final selected = productController.imageSliderIndex ?? 0;
                              final allImages = ProductImageHelper.getAllGalleryImages(productModel!);
                              final group = ProductImageHelper.findGroupForHeroIndex(
                                productModel!,
                                selected,
                              );
                              var initialIndex = selected;
                              if (group != null) {
                                final matchedIndex = allImages.indexWhere(
                                  (image) => image.path == productModel!.imagesFullUrl![selected].path,
                                );
                                if (matchedIndex >= 0) initialIndex = matchedIndex;
                              }
                              _openImageGallery(
                                context,
                                images: allImages,
                                initialIndex: initialIndex,
                              );
                            },
                            child: Stack(
                            children: [
                              SizedBox(
                                height: imageHeight,
                                child: productModel!.imagesFullUrl != null &&
                                        productModel!.imagesFullUrl!.isNotEmpty
                                    ? PageView.builder(
                                        controller: _controller,
                                        itemCount: productModel!.imagesFullUrl!.length,
                                        allowImplicitScrolling: false,
                                        itemBuilder: (context, index) {
                                          final isVisible = selectedIndex == index;
                                          return RepaintBoundary(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(15),
                                              child: CustomImageWidget(
                                                height: imageHeight,
                                                width: imageWidth,
                                                maxCacheSize: isVisible ? 1024 : 640,
                                                image: productModel!.imagesFullUrl![index].path ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                        onPageChanged: (index) =>
                                            productController.setImageSliderSelectedIndex(index),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 10,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    if (productModel!.imagesFullUrl != null &&
                                        productModel!.imagesFullUrl!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsetsGeometry.directional(
                                          end: Dimensions.paddingSizeDefault,
                                          bottom: Dimensions.paddingSizeDefault,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Dimensions.paddingSizeSmall,
                                            vertical: Dimensions.paddingSizeExtraSmall,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor.withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${selectedIndex + 1}/${productModel!.imagesFullUrl!.length}',
                                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Column(
                                  children: [
                                    FavouriteButtonWidget(
                                      backgroundColor: isDarkTheme
                                          ? Theme.of(context).cardColor
                                          : Theme.of(context).primaryColor,
                                      productId: productModel?.id,
                                      fromProductDetails: true,
                                    ),
                                    if ((splashController.configModel?.activeTheme ?? 'default') != 'default') ...[
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      InkWell(
                                        onTap: () {
                                          if (Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                                            Provider.of<CompareController>(context, listen: false)
                                                .addCompareList(productModel!.id!);
                                          } else {
                                            showModalBottomSheet(
                                              backgroundColor: const Color(0x00FFFFFF),
                                              context: context,
                                              builder: (_) => const NotLoggedInBottomSheetWidget(),
                                            );
                                          }
                                        },
                                        child: Consumer<CompareController>(
                                          builder: (context, compare, _) {
                                            return Card(
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: compare.compIds.contains(productModel!.id)
                                                      ? Theme.of(context).primaryColor
                                                      : Theme.of(context).cardColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                  child: Image.asset(
                                                    Images.compare,
                                                    color: compare.compIds.contains(productModel!.id)
                                                        ? Theme.of(context).cardColor
                                                        : Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                    InkWell(
                                      onTap: () {
                                        if (productController.sharableLink != null) {
                                          SharePlus.instance.share(
                                            ShareParams(text: productController.sharableLink!),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color!
                                                  .withValues(alpha: 0.10),
                                              spreadRadius: 0,
                                              blurRadius: 15,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                          child: Image.asset(
                                            Images.share,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (productModel?.productType == 'digital' &&
                                  productModel?.previewFileFullUrl != null &&
                                  (productModel?.previewFileFullUrl?.path ?? '').isNotEmpty)
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: InkWell(
                                    onTap: () => _showPreview(
                                      productModel?.previewFileFullUrl?.path ?? '',
                                      productModel?.name ?? '',
                                      productModel?.previewFileFullUrl?.key ?? '',
                                      context,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      height: 35,
                                      width: 81,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(Images.previewEyeIcon, width: 15),
                                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                          Text(
                                            getTranslated('preview', context) ?? '',
                                            style: titilliumRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.fromFlashDeals)
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Image.asset(Images.flashDeal, scale: 2),
                                ),
                              if ((productModel?.discount ?? 0) > 0 || productModel?.clearanceSale != null)
                                DiscountTagDetailsWidget(
                                  productModel: productModel!,
                                  positionedTop: 0,
                                  topLeftBorderRadius: Dimensions.radiusDefault,
                                  bottomRightBorderRadius: Dimensions.radiusDefault,
                                ),
                            ],
                          ),
                          ),
                        ),
                      ),
            ),
            if (ProductImageHelper.getColorGalleryItems(productModel!).isNotEmpty)
              _buildColorGallery(context, productController),
            if (ProductImageHelper.getAdditionalImageItems(productModel!).isNotEmpty)
              _buildMoreImagesSection(context, productController),
          ],
        );
      },
    );
  }

  void _showPreview(String url, String productName, String fileName, BuildContext context) {
    final type = Provider.of<ProductDetailsController>(context, listen: false).getFileType(url);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
          insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: switch (type) {
            PreviewType.pdf => PdfPreview(url: url, fileName: productName),
            PreviewType.image => ImagePreview(url: url, fileName: productName),
            PreviewType.video => VideoPreview(url: url, fileName: productName),
            PreviewType.audio => AudioPreview(url: url, fileName: productName),
            PreviewType.others => DownloadPreview(url: url, fileName: fileName),
          },
        );
      },
    );
  }
}
