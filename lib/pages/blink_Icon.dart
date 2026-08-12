import 'package:flutter/material.dart';

// ==================== РАБОЧИЙ МЕРЦАЮЩИЙ ICON ====================
class BlinkingColorIcon extends StatefulWidget {
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final double size;
  final bool blinking;
  final Duration duration;

  const BlinkingColorIcon({
    super.key,
    required this.icon,
    this.startColor = Colors.white12,
    this.endColor = Colors.blue,
    this.size = 80.0,
    this.blinking = true,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<BlinkingColorIcon> createState() => _BlinkingColorIconState();
}

class _BlinkingColorIconState extends State<BlinkingColorIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _colorAnimation = ColorTween(begin: widget.startColor, end: widget.endColor)
        .animate(_controller);

    if (widget.blinking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingColorIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;

    if (widget.blinking != oldWidget.blinking) {
      if (widget.blinking) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Icon(
          widget.icon,
          color: widget.blinking ? _colorAnimation.value : widget.startColor,
          size: widget.size,
        );
      },
    );
  }
}
// ===========================================================
