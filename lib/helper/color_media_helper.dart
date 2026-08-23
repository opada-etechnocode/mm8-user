enum ColorMediaPlatform {
  directVideo,
  instagram,
  youtube,
  tiktok,
  snapchat,
  genericWeb,
  unsupported,
}

class ColorMediaHelper {
  static bool _hasDirectVideoExtension(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.webm') ||
        lower.contains('.mp4') ||
        lower.contains('.mov') ||
        lower.contains('.m3u8');
  }

  static ColorMediaPlatform detectPlatform(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme.isEmpty) return ColorMediaPlatform.unsupported;

    final host = uri.host.toLowerCase();
    if (host.contains('instagram.com')) return ColorMediaPlatform.instagram;
    if (host.contains('youtube.com') ||
        host.contains('youtu.be') ||
        host.contains('youtube-nocookie.com')) {
      return ColorMediaPlatform.youtube;
    }
    if (host.contains('tiktok.com') || host.contains('vm.tiktok.com')) {
      return ColorMediaPlatform.tiktok;
    }
    if (host.contains('snapchat.com') || host.contains('story.snapchat.com')) {
      return ColorMediaPlatform.snapchat;
    }
    if (_hasDirectVideoExtension(url)) return ColorMediaPlatform.directVideo;
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return ColorMediaPlatform.genericWeb;
    }
    return ColorMediaPlatform.unsupported;
  }

  static bool isInstagramUrl(String url) =>
      detectPlatform(url) == ColorMediaPlatform.instagram;

  static bool isEmbeddableSocialUrl(String url) {
    switch (detectPlatform(url)) {
      case ColorMediaPlatform.instagram:
      case ColorMediaPlatform.youtube:
      case ColorMediaPlatform.tiktok:
      case ColorMediaPlatform.snapchat:
      case ColorMediaPlatform.genericWeb:
        return true;
      default:
        return false;
    }
  }

  static bool isDirectVideoUrl(String url) =>
      detectPlatform(url) == ColorMediaPlatform.directVideo;

  static String? instagramEmbedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.contains('instagram.com')) return null;

    final segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.length >= 2) {
      final type = segments[0];
      if (type == 'reel' || type == 'reels' || type == 'p' || type == 'tv') {
        final mediaType = type == 'reels' ? 'reel' : type;
        return 'https://www.instagram.com/$mediaType/${segments[1]}/embed';
      }
    }
    return null;
  }

  static String? instagramVideoEmbedUrl(String url) {
    final embed = instagramEmbedUrl(url);
    if (embed == null) return null;
    return embed.contains('?') ? '$embed&hidecaption=1' : '$embed?hidecaption=1';
  }

  static bool isInstagramReel(String url) {
    try {
      final path = Uri.parse(url).path.toLowerCase();
      return path.contains('/reel/') || path.contains('/reels/');
    } catch (_) {
      return false;
    }
  }

  static bool isInstagramPost(String url) {
    try {
      return Uri.parse(url).pathSegments.contains('p');
    } catch (_) {
      return false;
    }
  }

  static bool isYouTubeShorts(String url) {
    try {
      return Uri.parse(url).pathSegments.contains('shorts');
    } catch (_) {
      return false;
    }
  }

  static String? youtubeVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
      if (uri.pathSegments.contains('embed') && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
      if (uri.pathSegments.contains('shorts') && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (_) {}
    return null;
  }

  static String? tiktokVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      final segments =
          uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
      final videoIndex = segments.indexOf('video');
      if (videoIndex >= 0 && videoIndex + 1 < segments.length) {
        return segments[videoIndex + 1];
      }
    } catch (_) {}
    return null;
  }

  static String? buildEmbedUrl(String url, ColorMediaPlatform platform) {
    switch (platform) {
      case ColorMediaPlatform.instagram:
        return instagramEmbedUrl(url) ?? url;
      case ColorMediaPlatform.youtube:
        final id = youtubeVideoId(url);
        return id == null
            ? url
            : 'https://www.youtube-nocookie.com/embed/$id?autoplay=1&rel=0&modestbranding=1&playsinline=1&controls=1';
      case ColorMediaPlatform.tiktok:
        final id = tiktokVideoId(url);
        return id == null ? url : 'https://www.tiktok.com/embed/v2/$id';
      case ColorMediaPlatform.snapchat:
      case ColorMediaPlatform.genericWeb:
        return url;
      default:
        return null;
    }
  }
}
