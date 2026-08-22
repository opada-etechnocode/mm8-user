import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/instagram_embed_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/video_preview.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_media_helper.dart';

class ColorMediaVideoDialog extends StatelessWidget {
  final String videoUrl;
  final String? title;
  final String? thumbnailPath;

  const ColorMediaVideoDialog({
    super.key,
    required this.videoUrl,
    this.title,
    this.thumbnailPath,
  });

  static Future<void> show(
    BuildContext context, {
    required String videoUrl,
    String? title,
    String? thumbnailPath,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'video-dialog',
      barrierColor: Colors.black.withValues(alpha: 0.88),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => ColorMediaVideoDialog(
        videoUrl: videoUrl,
        title: title,
        thumbnailPath: thumbnailPath,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInstagram = ColorMediaHelper.isInstagramUrl(videoUrl);
    final size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width,
                  maxHeight: size.height * 0.9,
                ),
                child: isInstagram
                    ? InstagramEmbedWidget(url: videoUrl, videoOnly: true)
                    : VideoPreview(
                        url: videoUrl,
                        fileName: title ?? 'Video',
                        minimal: true,
                      ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
