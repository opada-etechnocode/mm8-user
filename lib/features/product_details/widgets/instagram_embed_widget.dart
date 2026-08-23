import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_media_helper.dart';

class InstagramEmbedWidget extends StatefulWidget {
  final String url;
  /// Crops Instagram chrome (account / caption) to focus on media.
  final bool videoOnly;

  const InstagramEmbedWidget({
    super.key,
    required this.url,
    this.videoOnly = false,
  });

  @override
  State<InstagramEmbedWidget> createState() => _InstagramEmbedWidgetState();
}

class _InstagramEmbedWidgetState extends State<InstagramEmbedWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black);

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    _loadEmbed(widget.url);
  }

  void _loadEmbed(String rawUrl) {
    final embedUrl = ColorMediaHelper.instagramEmbedUrl(rawUrl) ?? rawUrl;
    final cleanEmbed = embedUrl.contains('?')
        ? '$embedUrl&hidecaption=1'
        : '$embedUrl?hidecaption=1';

    final topOffset = widget.videoOnly ? '-54px' : '0';
    final extraHeight = widget.videoOnly ? '120px' : '0px';

    final htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          html, body {
            margin: 0;
            padding: 0;
            background: #000;
            width: 100%;
            height: 100%;
            overflow: hidden;
          }
          .wrap {
            width: 100%;
            height: 100%;
            overflow: hidden;
            position: relative;
          }
          iframe {
            position: absolute;
            left: 0;
            top: $topOffset;
            width: 100%;
            height: calc(100% + $extraHeight);
            border: 0;
            display: block;
            background: #000;
          }
        </style>
      </head>
      <body>
        <div class="wrap">
          <iframe
            src="$cleanEmbed"
            allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share"
            allowfullscreen
            scrolling="no">
          </iframe>
        </div>
      </body>
      </html>
    ''';

    _controller.loadHtmlString(
      htmlContent,
      baseUrl: 'https://www.instagram.com',
    );
  }

  static const double _edgeCropSize = 50;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = widget.videoOnly ? width * 1.25 : width * 1.15;
    final cropScale = widget.videoOnly && width > _edgeCropSize * 2
        ? width / (width - (_edgeCropSize * 2))
        : 1.0;

    Widget player = WebViewWidget(controller: _controller);
    if (widget.videoOnly && cropScale > 1.0) {
      player = ClipRect(
        child: Transform.scale(
          scaleX: cropScale,
          scaleY: 1.0,
          alignment: Alignment.center,
          child: SizedBox(
            width: width,
            height: height,
            child: player,
          ),
        ),
      );
    }

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.88),
      child: SizedBox(
        width: width,
        height: height,
        child: player,
      ),
    );
  }
}
