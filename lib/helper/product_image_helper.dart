import 'package:flutter_sixvalley_ecommerce/data/model/image_full_url.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';

class ProductImageGroupItem {
  final int? colorIndex;
  final String? colorKey;
  final ImageFullUrl thumbnail;
  final List<ImageFullUrl> images;
  final int heroImageIndex;
  final String? videoUrl;

  const ProductImageGroupItem({
    required this.colorIndex,
    required this.colorKey,
    required this.thumbnail,
    required this.images,
    required this.heroImageIndex,
    this.videoUrl,
  });
}

class ProductImageHelper {
  static String? _colorKeyFromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    if (code.startsWith('#') && code.length >= 7) {
      return code.substring(1, 7).toUpperCase();
    }
    return code.toUpperCase();
  }

  static int? _findColorIndex(ProductDetailsModel product, String? colorKey) {
    if (colorKey == null || product.colors == null) return null;
    for (int i = 0; i < product.colors!.length; i++) {
      if (_colorKeyFromCode(product.colors![i].code) == colorKey.toUpperCase()) {
        return i;
      }
    }
    return null;
  }

  static int _indexInAllImages(List<ImageFullUrl> allImages, ImageFullUrl? image) {
    if (image?.path == null || image!.path!.isEmpty) return -1;
    return allImages.indexWhere((item) => item.path == image.path);
  }

  static List<ImageFullUrl> _uniqueImages(List<ImageFullUrl> images) {
    final seen = <String>{};
    final result = <ImageFullUrl>[];
    for (final image in images) {
      final path = image.path ?? '';
      if (path.isEmpty || seen.contains(path)) continue;
      seen.add(path);
      result.add(image);
    }
    return result;
  }

  static bool _hasColorKey(ColorImagesFullUrl entry) {
    return entry.color != null && entry.color!.trim().isNotEmpty;
  }

  static Set<String> _getAllColorMediaPaths(ProductDetailsModel product) {
    final paths = <String>{};
    for (final entry in product.colorImagesFullUrl ?? []) {
      for (final image in entry.images ?? <ImageFullUrl>[]) {
        final path = image.path ?? '';
        if (path.isNotEmpty) paths.add(path);
      }
      final imagePath = entry.imageName?.path ?? '';
      if (imagePath.isNotEmpty) paths.add(imagePath);
    }
    return paths;
  }

  static ProductImageGroupItem? _groupFromColorEntry(
    ProductDetailsModel product,
    ColorImagesFullUrl entry, {
    required bool includeColor,
  }) {
    if (includeColor && !_hasColorKey(entry)) return null;
    if (!includeColor && _hasColorKey(entry)) return null;

    final colorKey = entry.color?.toUpperCase();
    List<ImageFullUrl> groupImages = _uniqueImages(entry.images ?? <ImageFullUrl>[]);

    if (groupImages.isEmpty && (entry.imageName?.path ?? '').isNotEmpty) {
      groupImages = [entry.imageName!];
    }

    final hasVideo = entry.videoUrl != null && entry.videoUrl!.trim().isNotEmpty;
    if (groupImages.isEmpty && !hasVideo) return null;

    final thumbnail = groupImages.isNotEmpty
        ? groupImages.first
        : ImageFullUrl(path: entry.imageName?.path ?? '');

    final allImages = product.imagesFullUrl ?? [];
    final heroIndex = _indexInAllImages(allImages, thumbnail);

    return ProductImageGroupItem(
      colorIndex: includeColor ? _findColorIndex(product, colorKey) : null,
      colorKey: includeColor ? colorKey : null,
      thumbnail: thumbnail,
      images: groupImages.isNotEmpty ? groupImages : [thumbnail],
      heroImageIndex: heroIndex >= 0 ? heroIndex : 0,
      videoUrl: entry.videoUrl,
    );
  }

  static List<ProductImageGroupItem> getColorImageGroups(ProductDetailsModel product) {
    final colorEntries = product.colorImagesFullUrl ?? [];
    if (colorEntries.isEmpty) return [];

    final groups = <ProductImageGroupItem>[];
    for (final entry in colorEntries) {
      final group = _groupFromColorEntry(product, entry, includeColor: true);
      if (group != null) groups.add(group);
    }

    return groups;
  }

  static bool hasColorGroups(ProductDetailsModel product) {
    return getColorImageGroups(product).isNotEmpty;
  }

  static List<ProductImageGroupItem> getColorGalleryItems(ProductDetailsModel product) {
    final colorGroups = getColorImageGroups(product);
    if (colorGroups.isEmpty) return [];

    final colorItems = <ProductImageGroupItem>[];
    final addedGroups = <String>{};

    for (final group in colorGroups) {
      final key = group.colorKey ?? group.thumbnail.path ?? '';
      if (key.isNotEmpty && !addedGroups.contains(key)) {
        colorItems.add(group);
        addedGroups.add(key);
      }
    }

    return colorItems;
  }

  static List<ProductImageGroupItem> getAdditionalImageItems(ProductDetailsModel product) {
    final additionalItems = <ProductImageGroupItem>[];

    for (final entry in product.colorImagesFullUrl ?? []) {
      final group = _groupFromColorEntry(product, entry, includeColor: false);
      if (group != null) additionalItems.add(group);
    }

    final allImages = product.imagesFullUrl ?? [];
    if (allImages.isEmpty) return additionalItems;

    final linkedPaths = _getAllColorMediaPaths(product);
    for (int index = 0; index < allImages.length; index++) {
      final path = allImages[index].path ?? '';
      if (path.isEmpty || linkedPaths.contains(path)) continue;

      additionalItems.add(
        ProductImageGroupItem(
          colorIndex: null,
          colorKey: null,
          thumbnail: allImages[index],
          images: [allImages[index]],
          heroImageIndex: index,
        ),
      );
    }

    return additionalItems;
  }

  static List<ProductImageGroupItem> getGridItems(ProductDetailsModel product) {
    return [
      ...getColorGalleryItems(product),
      ...getAdditionalImageItems(product),
    ];
  }

  static ProductImageGroupItem? findGroupForHeroIndex(
    ProductDetailsModel product,
    int heroIndex,
  ) {
    final selectedPath = product.imagesFullUrl?[heroIndex].path;
    if (selectedPath == null || selectedPath.isEmpty) return null;

    for (final group in getGridItems(product)) {
      if (group.images.any((image) => image.path == selectedPath)) {
        return group;
      }
    }
    return null;
  }

  static List<ImageFullUrl> getAllGalleryImages(ProductDetailsModel product) {
    return _uniqueImages(product.imagesFullUrl ?? []);
  }

  static String? getColorImagePath(ProductDetailsModel product, int colorIndex) {
    for (final group in getColorGalleryItems(product)) {
      if (group.colorIndex == colorIndex) {
        return group.thumbnail.path;
      }
    }

    final colors = product.colors;
    if (colors == null || colorIndex < 0 || colorIndex >= colors.length) {
      return null;
    }

    final colorKey = _colorKeyFromCode(colors[colorIndex].code);
    final colorEntries = product.colorImagesFullUrl ?? [];
    for (final entry in colorEntries) {
      if (entry.color?.toUpperCase() == colorKey) {
        if (entry.images != null && entry.images!.isNotEmpty) {
          return entry.images!.first.path;
        }
        return entry.imageName?.path;
      }
    }

    return null;
  }
}
