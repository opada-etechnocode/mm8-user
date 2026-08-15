import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  final int maxCacheSize;

  const CustomImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder = Images.placeholder,
    this.maxCacheSize = 1024,
  });

  int? _cacheDimension(double? size, double devicePixelRatio) {
    if (size == null || !size.isFinite || size <= 0) {
      return null;
    }
    return (size * devicePixelRatio).round().clamp(1, maxCacheSize);
  }
  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return Image.asset(
        placeholder ?? Images.placeholder,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
      );
    }

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    // استخدم فقط البعد الأكبر نسبياً لتفادي تشويه نسبة الأبعاد أثناء decode
    final memCacheWidth = _cacheDimension(width, devicePixelRatio);

    return CachedNetworkImage(
      imageUrl: image,
      fit: fit ?? BoxFit.cover,
      height: height,
      width: width,
      memCacheWidth: memCacheWidth, // بعد واحد فقط
      maxWidthDiskCache: memCacheWidth,
      placeholder: (context, url) => Image.asset(
        placeholder ?? Images.placeholder,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
      errorWidget: (c, o, s) => Image.asset(
        placeholder ?? Images.placeholder,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
    );
  }}