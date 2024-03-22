import 'package:chatbot_app/ui/widgets/custom_back_button.dart';
import 'package:chatbot_app/ui/widgets/custom_text.dart';
import 'package:chatbot_app/ui/widgets/slider_video.dart';
import 'package:chatbot_app/utils/app_navigators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;

  const VideoWidget({super.key, required this.url});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool isInit = true;
  bool onSeek = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          isInit = false;
          _controller.play();
        });
      });

    _controller.setLooping(true);
    _controller.setVolume(0);
  }

  @override
  Widget build(BuildContext context) {
    return isInit
        ? const CupertinoActivityIndicator()
        : GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();

              _controller.setVolume(1);

              await pageOpenWithResult(FullScreenVideo(
                  controller: _controller,
                  videoWidget: _buildVideo(fullScreen: false)));

              _controller.setVolume(0);
            },
            child: _buildVideo(),
          );
  }

  Widget _buildVideo({bool fullScreen = true}) {
    double width = _controller.value.size.width;
    double height = _controller.value.size.height;

    return Hero(
      tag: widget.url,
      child: FittedBox(
        fit: ((height / width) >= (16 / 9) || fullScreen)
            ? BoxFit.cover
            : BoxFit.fitWidth,
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          height: height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class FullScreenVideo extends StatefulWidget {
  final VideoPlayerController controller;
  final Widget videoWidget;

  const FullScreenVideo(
      {super.key, required this.controller, required this.videoWidget});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  bool onSeek = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const CustomText(
          text: "Short Video",
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        leading: const CustomBackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                setState(() {
                  widget.controller.pause();
                });
              },
              onLongPressEnd: (details) {
                setState(() {
                  widget.controller.play();
                });
              },
              onHorizontalDragEnd: (details) {
                pageBack();
              },
              child: widget.videoWidget,
            ),
          ),
          SliderVideo(
              controller: widget.controller,
              builder: (context, position, duration, child) {
                if (position == duration && !onSeek) {
                  widget.controller.play();
                }

                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    inactiveTrackColor: Colors.grey.shade900,
                    trackShape: const RectangularSliderTrackShape(),
                    trackHeight: onSeek ? 7 : 3,
                    thumbColor: Theme.of(context).colorScheme.primary,
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: onSeek ? 7 : 2),
                    overlayColor:
                        Theme.of(context).colorScheme.primary.withAlpha(32),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 0),
                  ),
                  child: Slider(
                    onChangeStart: (_) {
                      setState(() {
                        onSeek = true;
                        widget.controller.pause();
                      });
                    },
                    onChangeEnd: (_) {
                      setState(() {
                        onSeek = false;
                        widget.controller.play();
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.controller
                            .seekTo(Duration(milliseconds: value.toInt()));
                      });
                    },
                    value: position.inMilliseconds.toDouble(),
                    min: 0,
                    max: duration.inMilliseconds.toDouble(),
                  ),
                );
              }),
          SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );
  }
}
