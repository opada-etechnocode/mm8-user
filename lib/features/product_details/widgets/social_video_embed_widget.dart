import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_media_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class SocialVideoEmbedWidget extends StatefulWidget {
  final String url;

  const SocialVideoEmbedWidget({
    super.key,
    required this.url,
  });

  @override
  State<SocialVideoEmbedWidget> createState() => _SocialVideoEmbedWidgetState();
}

class _SocialVideoEmbedWidgetState extends State<SocialVideoEmbedWidget> {
  late final WebViewController _controller;
  late final ColorMediaPlatform _platform;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _platform = ColorMediaHelper.detectPlatform(widget.url);
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
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            if (url.startsWith('intent:') ||
                url.startsWith('instagram://') ||
                url.startsWith('snssdk') ||
                url.startsWith('tiktok://')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    _loadContent(widget.url);
  }

  void _loadContent(String rawUrl) {
    final embedUrl = ColorMediaHelper.buildEmbedUrl(rawUrl, _platform) ?? rawUrl;

    if (_platform == ColorMediaPlatform.snapchat ||
        _platform == ColorMediaPlatform.genericWeb) {
      _controller.loadRequest(Uri.parse(embedUrl));
      return;
    }

    final iframeSrc = embedUrl.contains('?') ? '$embedUrl&autoplay=1' : '$embedUrl?autoplay=1';

    const htmlContentTemplate = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          html, body {
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
            background: #000;
          }
          iframe {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            border: 0;
            display: block;
            background: #000;
          }
        </style>
      </head>
      <body>
        <div class="wrap">
          <iframe
            src="IFRAME_SRC"
            allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share"
            allowfullscreen
            scrolling="no">
          </iframe>
        </div>
      </body>
      </html>
    ''';

    final htmlContent = htmlContentTemplate.replaceFirst('IFRAME_SRC', iframeSrc);

    final baseUrl = switch (_platform) {
      ColorMediaPlatform.youtube => 'https://www.youtube.com',
      ColorMediaPlatform.tiktok => 'https://www.tiktok.com',
      _ => 'https://www.google.com',
    };

    _controller.loadHtmlString(htmlContent, baseUrl: baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = size.height * 0.92;
    final isPortraitEmbed = _platform == ColorMediaPlatform.tiktok ||
        _platform == ColorMediaPlatform.snapchat ||
        (_platform == ColorMediaPlatform.youtube &&
            ColorMediaHelper.isYouTubeShorts(widget.url));

    final width = isPortraitEmbed ? height * 9 / 16 : size.width;

    return Center(
      child: ClipRect(
        child: SizedBox(
          width: width.clamp(0, size.width),
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
