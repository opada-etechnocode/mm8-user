import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String url;
  final String fileName;
  final bool minimal;
  const VideoPreview({
    super.key,
    required this.url,
    required this.fileName,
    this.minimal = false,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _toggleFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FullScreenVideoPlayer(controller: _controller)),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (widget.minimal) {
      return _buildMinimalPlayer(context);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha:0.50),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.fileName,
                    style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              SizedBox(
                  height: 20, width: 20,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: ()=> Navigator.of(context, rootNavigator: true).pop(),
                      icon: Icon(Icons.close, color: Theme.of(context).hintColor, size: 20,)
                  )
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Expanded(child: _buildPlayerStack(context)),
        ],
      ),
    );
  }

  Widget _buildMinimalPlayer(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final boxHeight = size.height * 0.92;
    final boxWidth = size.width;

    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: ColoredBox(
        color: Colors.black,
        child: _buildPlayerStack(context, lightControls: true, fillCover: true),
      ),
    );
  }

  Widget _buildPlayerStack(
    BuildContext context, {
    bool lightControls = false,
    bool fillCover = false,
  }) {
    final controlColor = lightControls ? Colors.white : Theme.of(context).primaryColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_controller.value.isInitialized)
          fillCover
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio == 0
                        ? 16 / 9
                        : _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        Center(
          child: IconButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: controlColor,
              size: 56,
            ),
          ),
        ),
        if (!widget.minimal)
          Positioned(
            bottom: 5,
            right: 5,
            child: IconButton(
              onPressed: () => _toggleFullScreen(context),
              icon: Icon(Icons.fullscreen, color: controlColor),
            ),
          ),
        if (_controller.value.isInitialized)
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                backgroundColor: Colors.white24,
                playedColor: lightControls ? Colors.white : Theme.of(context).primaryColor,
                bufferedColor: Colors.white38,
              ),
            ),
          ),
      ],
    );
  }
}



class FullScreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),

      floatingActionButton: FloatingActionButton (
        backgroundColor: Theme.of(context).cardColor,
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.fullscreen_exit, color: Theme.of(context).primaryColor),
      ),

    );
  }
}