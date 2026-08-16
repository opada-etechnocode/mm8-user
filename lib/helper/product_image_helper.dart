import 'package:flutter_sixvalley_ecommerce/data/model/image_full_url.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';

class ProductImageGroupItem {
  final int? colorIndex;
  final String? colorKey;
  final ImageFullUrl thumbnail;
  final List<ImageFullUrl> images;
  final int heroImageIndex;

  const ProductImageGroupItem({
    required this.colorIndex,
    required this.colorKey,
    required this.thumbnail,
    required this.images,
    required this.heroImageIndex,
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

  static List<ProductImageGroupItem> getColorImageGroups(ProductDetailsModel product) {
    final allImages = product.imagesFullUrl ?? [];
    final colorEntries = product.colorImagesFullUrl ?? [];
    if (colorEntries.isEmpty) return [];

    final anchors = <MapEntry<int, ColorImagesFullUrl>>[];
    for (final entry in colorEntries) {
      final index = _indexInAllImages(allImages, entry.imageName);
      anchors.add(MapEntry(index >= 0 ? index : 999999, entry));
    }

    anchors.sort((a, b) => a.key.compareTo(b.key));

    final groups = <ProductImageGroupItem>[];
    for (int i = 0; i < anchors.length; i++) {
      final entry = anchors[i].value;
      final colorKey = entry.color?.toUpperCase();

      List<ImageFullUrl> groupImages;
      int heroIndex;

      if (entry.images != null && entry.images!.isNotEmpty) {
        groupImages = _uniqueImages(entry.images!);
        if (groupImages.isEmpty) continue;
        heroIndex = _indexInAllImages(allImages, groupImages.first);
      } else {
        final startIndex = anchors[i].key;
        final endIndex = i < anchors.length - 1 ? anchors[i + 1].key : allImages.length;

        if (startIndex >= 0 && startIndex < allImages.length && endIndex > startIndex) {
          groupImages = allImages.sublist(startIndex, endIndex);
        } else if (entry.imageName != null && (entry.imageName!.path ?? '').isNotEmpty) {
          groupImages = [entry.imageName!];
        } else {
          continue;
        }

        groupImages = _uniqueImages(groupImages);
        if (groupImages.isEmpty) continue;

        heroIndex = startIndex >= 0 && startIndex < allImages.length
            ? startIndex
            : _indexInAllImages(allImages, groupImages.first);
      }

      groups.add(
        ProductImageGroupItem(
          colorIndex: _findColorIndex(product, colorKey),
          colorKey: colorKey,
          thumbnail: groupImages.first,
          images: groupImages,
          heroImageIndex: heroIndex >= 0 ? heroIndex : 0,
        ),
      );
    }

    return groups;
  }

  static bool hasColorGroups(ProductDetailsModel product) {
    return getColorImageGroups(product).isNotEmpty;
  }

  static Set<String> _getAttributeLinkedPaths(List<ProductImageGroupItem> colorGroups) {
    final paths = <String>{};
    for (final group in colorGroups) {
      for (final image in group.images) {
        final path = image.path ?? '';
        if (path.isNotEmpty) {
          paths.add(path);
        }
      }
    }
    return paths;
  }

  static List<ProductImageGroupItem> getGridItems(ProductDetailsModel product) {
    final allImages = product.imagesFullUrl ?? [];
    if (allImages.isEmpty) return [];

    final colorGroups = getColorImageGroups(product);
    if (colorGroups.isEmpty) {
      return List.generate(allImages.length, (index) {
        return ProductImageGroupItem(
          colorIndex: null,
          colorKey: null,
          thumbnail: allImages[index],
          images: [allImages[index]],
          heroImageIndex: index,
        );
      });
    }

    final attributePaths = _getAttributeLinkedPaths(colorGroups);
    final colorItems = <ProductImageGroupItem>[];
    final addedGroups = <String>{};

    for (final group in colorGroups) {
      final key = group.colorKey ?? group.thumbnail.path ?? '';
      if (key.isNotEmpty && !addedGroups.contains(key)) {
        colorItems.add(group);
        addedGroups.add(key);
      }
    }

    final additionalItems = <ProductImageGroupItem>[];
    for (int index = 0; index < allImages.length; index++) {
      final path = allImages[index].path ?? '';
      if (path.isEmpty || attributePaths.contains(path)) continue;

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

    return [...colorItems, ...additionalItems];
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
}
