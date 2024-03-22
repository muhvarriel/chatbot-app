import 'package:chatbot_app/ui/widgets/custom_cached_image.dart';
import 'package:chatbot_app/ui/widgets/custom_text.dart';
import 'package:chatbot_app/utils/app_navigators.dart';
import 'package:chatbot_app/utils/image_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatStoryScreen extends StatefulWidget {
  final int index;
  final List<int> listImage;

  const ChatStoryScreen(
      {super.key, required this.index, required this.listImage});

  @override
  State<ChatStoryScreen> createState() => _ChatStoryScreenState();
}

class _ChatStoryScreenState extends State<ChatStoryScreen> {
  int index = 0;

  @override
  void initState() {
    index = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int lastIndex = widget.listImage.length - 1;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        padding: screenWidth > 600
            ? EdgeInsets.symmetric(
                horizontal: screenWidth / ((screenWidth > 1028) ? 3 : 4),
                vertical: 30)
            : EdgeInsets.zero,
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: ClipRRect(
          borderRadius:
              screenWidth > 600 ? BorderRadius.circular(20) : BorderRadius.zero,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.viewPaddingOf(context).top),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 4,
                          child: Row(
                            children: [
                              for (var i = 0; i < widget.listImage.length; i++)
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (i != 0) const SizedBox(width: 3),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween(
                                                begin: 0,
                                                end: i == index ? 1 : 0),
                                            duration: Duration(
                                                seconds: i == index ? 5 : 0),
                                            curve: Curves.linear,
                                            onEnd: () {
                                              if (i == lastIndex &&
                                                  index == lastIndex) {
                                                pageBack();
                                              } else if (i == index &&
                                                  i != lastIndex) {
                                                setState(() {
                                                  index++;
                                                });
                                              }
                                            },
                                            builder: (BuildContext context,
                                                double value, Widget? child) {
                                              return LinearProgressIndicator(
                                                minHeight: 3,
                                                value: index > i ? 1 : value,
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CustomText(
                              text: "Story ChatAI",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();

                                pageBack();
                              },
                              child: const Icon(
                                Icons.close,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GestureDetector(
                      onTapUp: (details) {
                        HapticFeedback.lightImpact();

                        if (details.localPosition.dx <
                            ((screenWidth > 600
                                    ? (screenWidth /
                                        ((screenWidth > 1028) ? 3 : 4))
                                    : screenWidth) /
                                2)) {
                          if (index > 0) {
                            setState(() {
                              index--;
                            });
                          }
                        } else {
                          if (index < lastIndex) {
                            setState(() {
                              index++;
                            });
                          } else if (index == lastIndex) {
                            pageBack();
                          }
                        }
                      },
                      onVerticalDragEnd: (details) {
                        pageBack();
                      },
                      child: Hero(
                        tag: ImageStorage.getImageByIndex(
                            widget.listImage[index]),
                        child: customCachedImage(
                            width: screenWidth,
                            url: ImageStorage.getImageByIndex(
                                widget.listImage[index]),
                            radius:
                                20 + MediaQuery.viewPaddingOf(context).bottom,
                            isRectangle: true),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.viewPaddingOf(context).bottom + 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
