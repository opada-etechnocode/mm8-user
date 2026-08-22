class ColorMediaHelper {
  static bool isInstagramUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.contains('instagram.com');
  }

  static bool isDirectVideoUrl(String url) {
    if (isInstagramUrl(url)) return false;
    final lower = url.toLowerCase();
    return lower.contains('.webm') ||
        lower.contains('.mp4') ||
        lower.contains('.mov') ||
        lower.contains('.m3u8') ||
        lower.contains('/video/');
  }

  static String? instagramEmbedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.contains('instagram.com')) return null;

    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.length >= 2) {
      final type = segments[0];
      if (type == 'reel' || type == 'p' || type == 'tv') {
        return 'https://www.instagram.com/$type/${segments[1]}/embed';
      }
    }
    return null;
  }
}
