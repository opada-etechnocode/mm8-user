import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MarqueeWidget extends StatefulWidget {
  final Widget? child;
  final Widget Function()? childBuilder;
  final Axis direction;
  final Duration animationDuration;
  final Duration backDuration;
  final Duration pauseDuration;
  final bool continuous;
  final double velocity;
  final double blankSpace;

  const MarqueeWidget({
    super.key,
    this.child,
    this.childBuilder,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 5000),
    this.backDuration = const Duration(milliseconds: 5000),
    this.pauseDuration = Duration.zero,
    this.continuous = false,
    this.velocity = 35,
    this.blankSpace = 0,
  }) : assert(
          child != null || childBuilder != null,
          'Either child or childBuilder must be provided.',
        );

  @override
  MarqueeWidgetState createState() => MarqueeWidgetState();
}

class MarqueeWidgetState extends State<MarqueeWidget> {
  ScrollController? scrollController;
  final GlobalKey _measureKey = GlobalKey();
  bool _running = false;
  double _segmentSize = 0;

  Widget _buildContent() {
    if (widget.childBuilder != null) {
      return widget.childBuilder!();
    }
    return widget.child!;
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      initialScrollOffset: widget.continuous ? 0 : 50,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.continuous) {
        _startContinuous();
      } else {
        scroll(null);
      }
    });
  }

  @override
  void didUpdateWidget(MarqueeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.continuous) {
      _segmentSize = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureSegment());
    }
  }

  @override
  void dispose() {
    _running = false;
    scrollController?.dispose();
    super.dispose();
  }

  Future<void> _measureSegment() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final size = widget.direction == Axis.horizontal
          ? box.size.width
          : box.size.height;
      _segmentSize = size + widget.blankSpace;
    }
  }

  Future<void> _startContinuous() async {
    if (_running) return;
    _running = true;
    await _measureSegment();
    while (_running && mounted && scrollController!.hasClients) {
      if (_segmentSize <= 0) {
        await _measureSegment();
        if (_segmentSize <= 0) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          continue;
        }
      }

      final start = _segmentSize * 2;
      scrollController!.jumpTo(start);

      final duration = Duration(
        milliseconds: (_segmentSize / widget.velocity * 1000).round(),
      );

      if (!_running || !scrollController!.hasClients) return;
      await scrollController!.animateTo(
        0,
        duration: duration,
        curve: Curves.linear,
      );
    }
  }

  void scroll(Duration? _) async {
    while (scrollController!.hasClients) {
      await Future.delayed(widget.pauseDuration);
      if (scrollController!.hasClients) {
        await scrollController!.animateTo(
          scrollController!.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.linear,
        );
      }
      await Future.delayed(widget.pauseDuration);
      if (scrollController!.hasClients) {
        await scrollController!.animateTo(
          0.0,
          duration: widget.backDuration,
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.continuous) {
      return Stack(
        children: [
          Offstage(
            child: KeyedSubtree(
              key: _measureKey,
              child: _buildContent(),
            ),
          ),
          ListView.builder(
            controller: scrollController,
            scrollDirection: widget.direction,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              if (index.isEven) {
                return _buildContent();
              }
              return widget.direction == Axis.horizontal
                  ? SizedBox(width: widget.blankSpace)
                  : SizedBox(height: widget.blankSpace);
            },
          ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: widget.direction,
      controller: scrollController,
      child: _buildContent(),
    );
  }
}

/// Text marquee powered by the [Marquee] package.
class TextMarquee extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double velocity;
  final double blankSpace;

  const TextMarquee({
    super.key,
    required this.text,
    this.style,
    this.velocity = 35,
    this.blankSpace = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: style,
      velocity: velocity,
      blankSpace: blankSpace,
      pauseAfterRound: Duration.zero,
      accelerationDuration: Duration.zero,
      decelerationDuration: Duration.zero,
    );
  }
}
