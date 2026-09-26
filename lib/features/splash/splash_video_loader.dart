import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:video_player/video_player.dart';

/// Preloads the splash intro video before [runApp] so playback can start immediately.
class SplashVideoLoader {
  static VideoPlayerController? _controller;
  static Future<void>? _loading;

  static Future<void> preload() {
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    try {
      final controller = VideoPlayerController.asset(Images.splashIntroVideo);
      await controller.initialize();
      await controller.setLooping(false);
      await controller.setVolume(1.0);
      _controller = controller;
    } catch (_) {
      _controller = null;
    }
  }

  /// Returns the ready controller (ownership transfers to the caller).
  static VideoPlayerController? take() {
    final controller = _controller;
    _controller = null;
    _loading = null;
    return controller;
  }

  static Future<void> disposeIfUnused() async {
    final controller = _controller;
    _controller = null;
    _loading = null;
    await controller?.dispose();
  }
}
