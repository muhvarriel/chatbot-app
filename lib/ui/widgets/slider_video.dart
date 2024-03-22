import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class SliderVideo extends StatefulWidget {
  const SliderVideo({
    super.key,
    required this.controller,
    required this.builder,
    this.child,
  });

  final VideoPlayerController controller;
  final Widget Function(BuildContext context, Duration progress,
      Duration duration, Widget? child) builder;
  final Widget? child;

  @override
  State<SliderVideo> createState() => _SliderVideoState();
}

class _SliderVideoState extends State<SliderVideo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.controller.value.duration,
    );
    _initializeListeners();
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _initializeListeners() {
    widget.controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    final value = widget.controller.value;
    final targetRelativePosition =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final currentPosition = Duration(
      milliseconds:
          (_animationController.value * value.duration.inMilliseconds).round(),
    );
    final offset = value.position - currentPosition;

    final correct = value.isPlaying &&
        offset.inMilliseconds > -500 &&
        offset.inMilliseconds < -50;
    final correction = const Duration(milliseconds: 500) - offset;
    final targetPos =
        correct ? _animationController.value : targetRelativePosition;
    final duration = correct ? value.duration + correction : value.duration;

    _animationController.duration = duration;
    if (value.isPlaying) {
      _animationController.forward(from: targetPos);
    } else {
      _animationController.value = targetRelativePosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = widget.controller.value;
        final millis =
            _animationController.value * value.duration.inMilliseconds;
        return widget.builder(
          context,
          Duration(milliseconds: millis.round()),
          value.duration,
          child,
        );
      },
      child: widget.child,
    );
  }
}
