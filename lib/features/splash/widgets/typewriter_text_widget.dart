import 'dart:async';

import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final int step;
  final TextAlign textAlign;
  final bool showCursor;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 38),
    this.step = 1,
    this.textAlign = TextAlign.center,
    this.showCursor = true,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _visibleCount = 0;
  bool _showCursor = true;
  bool _completed = false;
  Timer? _typingTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    if (widget.text.isEmpty) {
      _completeTyping();
    } else {
      _startTyping();
    }
    if (widget.showCursor) {
      _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) {
          setState(() => _showCursor = !_showCursor);
        }
      });
    }
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _typingTimer?.cancel();
      _completed = false;
      setState(() => _visibleCount = 0);
      if (widget.text.isEmpty) {
        _completeTyping();
      } else {
        _startTyping();
      }
    }
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(widget.speed, (_) {
      if (!mounted) return;
      if (_visibleCount < widget.text.length) {
        setState(() {
          _visibleCount = (_visibleCount + widget.step).clamp(0, widget.text.length);
        });
        if (_visibleCount >= widget.text.length) {
          _typingTimer?.cancel();
          _completeTyping();
        }
      } else {
        _typingTimer?.cancel();
        _completeTyping();
      }
    });
  }

  void _completeTyping() {
    if (_completed) return;
    _completed = true;
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = widget.text.substring(
      0,
      _visibleCount.clamp(0, widget.text.length),
    );
    final isTyping = _visibleCount < widget.text.length;

    return RichText(
      textAlign: widget.textAlign,
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: visibleText),
          if (widget.showCursor && (isTyping || _showCursor))
            TextSpan(
              text: '|',
              style: widget.style?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
        ],
      ),
    );
  }
}
