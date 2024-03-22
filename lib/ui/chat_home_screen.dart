import 'package:chatbot_app/model/chat_room.dart';
import 'package:chatbot_app/ui/chat_room_screen.dart';
import 'package:chatbot_app/ui/widgets/custom_cached_image.dart';
import 'package:chatbot_app/ui/widgets/custom_scrollbar.dart';
import 'package:chatbot_app/ui/widgets/custom_text.dart';
import 'package:chatbot_app/utils/app_navigators.dart';
import 'package:chatbot_app/repository/chat_provider.dart';
import 'package:chatbot_app/utils/image_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ChatHomeScreen extends StatefulWidget {
  final Function(String)? onWeb;

  const ChatHomeScreen({super.key, this.onWeb});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  late ChatProvider chatProvider;
  bool isCreate = false;
  bool isStart = false;
  final TextEditingController _searchEditingController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<int> list = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);

    await chatProvider.loadChatsFromString();

    setState(() {
      list = generateUniqueRandomNumbers(8, 0);
    });
  }

  Future<void> createMessage(double screenWidth) async {
    String idChat = const Uuid().v4();

    await chatProvider.addChat(ChatRoom(
        id: idChat,
        name: chatProvider.getName(),
        image: ImageStorage.randomImage,
        created: DateTime.now().toString(),
        messages: []));

    if (screenWidth > 600) {
      widget.onWeb!(idChat);
    } else {
      await pageOpenWithResult(ChatRoomScreen(id: idChat));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    List<ChatRoom> filteredChatRoom = chatProvider.chats
        .where((e) =>
            _searchEditingController.text.isEmpty ||
            (e.name
                    ?.toLowerCase()
                    .contains(_searchEditingController.text.toLowerCase()) ??
                false) ||
            (e.messages?.any((r) =>
                    r.content?.toLowerCase().contains(
                        _searchEditingController.text.toLowerCase()) ??
                    false) ??
                false))
        .toList();

    filteredChatRoom.sort((a, b) =>
        ((b.messages?.isNotEmpty ?? false)
                ? b.messages?.lastOrNull?.timestamp
                : b.created)
            ?.compareTo(((a.messages?.isNotEmpty ?? false)
                ? (a.messages?.lastOrNull?.timestamp ?? "")
                : (a.created ?? ""))) ??
        0);

    double opacityBorder = _scrollController.hasClients
        ? (_scrollController.position.maxScrollExtent != 0
            ? ((_scrollController.offset -
                        _scrollController.position.minScrollExtent) /
                    (_scrollController.position.maxScrollExtent -
                        _scrollController.position.minScrollExtent))
                .clamp(0, 1)
            : 0)
        : 0;

    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
        floatingActionButton:
            _scrollController.hasClients && _scrollController.offset > 20
                ? FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      HapticFeedback.lightImpact();

                      _scrollController.animateTo(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    },
                    child: const Icon(Icons.expand_less_rounded))
                : null,
        body: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: (isDark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade100)
                                .withOpacity(opacityBorder)))),
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.viewPaddingOf(context).top + 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: "ChatAI Messenger",
                              fontSize: 20 +
                                  (_scrollController.hasClients
                                      ? ((-1 * _scrollController.offset) / 50)
                                          .clamp(0, 10)
                                      : 0),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (chatProvider.chats.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();

                                if (isStart) {
                                  return;
                                }

                                setState(() {
                                  isCreate = true;
                                });

                                await createMessage(screenWidth);

                                setState(() {
                                  isCreate = false;
                                });
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: isCreate
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator())
                                      : const Icon(
                                          Icons.edit_square,
                                          size: 18,
                                        )),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                )),
            Expanded(
              child: NotificationListener(
                onNotification: (notification) {
                  setState(() {});
                  return true;
                },
                child: scrollBar(
                  child: ListView(
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: CupertinoTextField(
                                controller: _searchEditingController,
                                placeholderStyle: GoogleFonts.mulish(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700),
                                placeholder: "Search for name or message",
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                ),
                                style: GoogleFonts.mulish(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade900),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.search,
                                onChanged: (value) async {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const CustomText(
                        text: "Stories",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        padding: EdgeInsets.only(left: 16),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                            itemCount: list.length,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: index == 0 ? 16 : 0, right: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();

                                    pageOpen(StoryPreviewScreen(
                                        index: index, listImage: list));
                                  },
                                  child: Hero(
                                    tag: ImageStorage.getImageByIndex(
                                        list[index]),
                                    child: customCachedImage(
                                      width: 72,
                                      height: 72,
                                      withBorder: true,
                                      url: ImageStorage.getImageByIndex(
                                          list[index],
                                          size: 72),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const CustomText(
                            text: "Messages",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            padding: EdgeInsets.only(left: 16),
                          ),
                          const SizedBox(height: 6),
                          filteredChatRoom.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.sizeOf(context).height /
                                          6),
                                  child: Center(
                                      child: _searchEditingController
                                              .text.isNotEmpty
                                          ? const CustomText(
                                              text: "No results found",
                                              fontWeight: FontWeight.bold,
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const CustomText(
                                                    text:
                                                        "Looks like you haven't sent any messages yet",
                                                    fontWeight: FontWeight.w800,
                                                    textAlign: TextAlign.center,
                                                    fontSize: 22,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const CustomText(
                                                    text:
                                                        "We can suggest conversation starters based on your interests and preferences. Just let us know if you need some inspiration!",
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 30),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      HapticFeedback
                                                          .lightImpact();

                                                      if (isCreate) {
                                                        return;
                                                      }

                                                      setState(() {
                                                        isStart = true;
                                                      });

                                                      await Future.delayed(
                                                          const Duration(
                                                              seconds: 2));

                                                      await createMessage(
                                                          screenWidth);

                                                      setState(() {
                                                        isStart = false;
                                                      });
                                                    },
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 1000),
                                                      curve: Curves.elasticOut,
                                                      width: isStart
                                                          ? 47.5
                                                          : 117.5,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 14),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.deepPurple,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                      ),
                                                      child: isStart
                                                          ? SizedBox(
                                                              width: 20,
                                                              height: 20,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                              ))
                                                          : CustomText(
                                                              text:
                                                                  "Start a chat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                              color: Colors.grey
                                                                  .shade100,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8),
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: filteredChatRoom.length,
                                  separatorBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Divider(
                                        height: 0,
                                        indent: 0,
                                        thickness: 1,
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    var chats = filteredChatRoom[index];

                                    return CupertinoContextMenu.builder(
                                        enableHapticFeedback: true,
                                        actions: <Widget>[
                                          CupertinoContextMenuAction(
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              pageBack();
                                            },
                                            trailingIcon: CupertinoIcons.share,
                                            child:
                                                const CustomText(text: 'Share'),
                                          ),
                                          CupertinoContextMenuAction(
                                            onPressed: () async {
                                              HapticFeedback.lightImpact();
                                              await chatProvider
                                                  .deleteChat(chats.id ?? "");
                                              pageBack();

                                              setState(() {});
                                            },
                                            isDestructiveAction: true,
                                            trailingIcon: CupertinoIcons.delete,
                                            child: const CustomText(
                                                text: 'Delete'),
                                          ),
                                        ],
                                        builder: (context, animation) {
                                          return animation.isCompleted
                                              ? GestureDetector(
                                                  onTap: () async {
                                                    HapticFeedback
                                                        .lightImpact();

                                                    if (animation.isCompleted) {
                                                      pageBack();
                                                    }

                                                    if (screenWidth > 600) {
                                                      widget.onWeb!(
                                                          chats.id ?? "");
                                                    } else {
                                                      await pageOpenWithResult(
                                                          ChatRoomScreen(
                                                              id: chats.id ??
                                                                  ""));

                                                      setState(() {});
                                                    }
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: SizedBox(
                                                      width: screenWidth * 0.9,
                                                      child: ChatRoomScreen(
                                                        id: chats.id ?? "",
                                                        preview: true,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: () async {
                                                    HapticFeedback
                                                        .lightImpact();

                                                    if (animation.isCompleted) {
                                                      pageBack();
                                                    }

                                                    if (screenWidth > 600) {
                                                      widget.onWeb!(
                                                          chats.id ?? "");
                                                    } else {
                                                      await pageOpenWithResult(
                                                          ChatRoomScreen(
                                                              id: chats.id ??
                                                                  ""));

                                                      setState(() {});
                                                    }
                                                  },
                                                  child: Container(
                                                    width: screenWidth *
                                                        (animation.isCompleted
                                                            ? 0.8
                                                            : 1),
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor,
                                                        borderRadius: BorderRadius
                                                            .circular(animation
                                                                    .isCompleted
                                                                ? 20
                                                                : 0)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 16),
                                                    child: Row(
                                                      children: [
                                                        customCachedImage(
                                                          width: 45,
                                                          height: 45,
                                                          url: chats.image !=
                                                                  null
                                                              ? (ImageStorage
                                                                      .baseUrl +
                                                                  (chats.image ??
                                                                      ""))
                                                              : ImageStorage
                                                                  .defaultImage,
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        CustomText(
                                                                      text: chats
                                                                              .name ??
                                                                          "-",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                      color: isDark
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                    ),
                                                                  ),
                                                                  CustomText(
                                                                    text: DateFormat("HH.mm").format(DateTime.tryParse((chats.messages?.isNotEmpty ?? false)
                                                                            ? (chats.messages?.lastOrNull?.timestamp ??
                                                                                "")
                                                                            : (chats.created ??
                                                                                "")) ??
                                                                        DateTime
                                                                            .now()),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        12,
                                                                    color: isDark
                                                                        ? Colors
                                                                            .grey
                                                                            .shade400
                                                                        : Colors
                                                                            .grey
                                                                            .shade700,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 3),
                                                              CustomText(
                                                                text: chats
                                                                        .messages
                                                                        ?.lastOrNull
                                                                        ?.content ??
                                                                    "Start a message",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                color: isDark
                                                                    ? Colors
                                                                        .grey
                                                                        .shade400
                                                                    : Colors
                                                                        .grey
                                                                        .shade700,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                        });
                                  },
                                ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class StoryPreviewScreen extends StatefulWidget {
  final int index;
  final List<int> listImage;

  const StoryPreviewScreen(
      {super.key, required this.index, required this.listImage});

  @override
  State<StoryPreviewScreen> createState() => _StoryPreviewScreenState();
}

class _StoryPreviewScreenState extends State<StoryPreviewScreen> {
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
