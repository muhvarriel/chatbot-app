import 'dart:ui';

import 'package:chatbot_app/model/chat_room.dart';
import 'package:chatbot_app/repository/music_repo.dart';
import 'package:chatbot_app/repository/user_repo.dart';
import 'package:chatbot_app/ui/chat_music_screen.dart';
import 'package:chatbot_app/ui/chat_room_screen.dart';
import 'package:chatbot_app/ui/chat_story_screen.dart';
import 'package:chatbot_app/ui/chat_video_screen.dart';
import 'package:chatbot_app/ui/widgets/custom_cached_image.dart';
import 'package:chatbot_app/ui/widgets/custom_text.dart';
import 'package:chatbot_app/utils/app_navigators.dart';
import 'package:chatbot_app/repository/chat_provider.dart';
import 'package:chatbot_app/utils/image_storage.dart';
import 'package:chatbot_app/utils/music_storage.dart';
import 'package:chatbot_app/utils/video_storage.dart';
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
  List<int> listVideo = [];
  List<int> listMusic = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);

    await chatProvider.loadChatsFromString();

    await ImageStorage.loadImage();
    setState(() {
      list = generateUniqueRandomNumbers(8, 0, ImageStorage.listImage.length);
    });

    await MusicRepo.musicLoaded();
    setState(() {
      listMusic =
          generateUniqueRandomNumbers(4, 0, MusicStorage.listMusic.length);
    });

    /*
    await UserRepo.getVideoDrive();
    setState(() {
      listVideo =
          generateUniqueRandomNumbers(4, 0, VideoStorage.listVideo.length);
    });
    */

    await UserRepo.getImageDrive();
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
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

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
                    _storiesSection(),
                    //_videoSection(),
                    _musicSection(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: "Messages",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          padding: EdgeInsets.only(left: 16),
                        ),
                        const SizedBox(height: 6),
                        filteredChatRoom.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.sizeOf(context).height / 6),
                                child: Center(
                                    child: _searchEditingController
                                            .text.isNotEmpty
                                        ? const CustomText(
                                            text: "No results found",
                                            fontWeight: FontWeight.bold,
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                                    width:
                                                        isStart ? 47.5 : 117.5,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10,
                                                        horizontal: 14),
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepPurple,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
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
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey.shade100,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
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

                                  return _buildChat(chats);
                                },
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _storiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Stories",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          padding: EdgeInsets.only(left: 16),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 72,
          child: ListView.builder(
              itemCount: list.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.only(left: index == 0 ? 16 : 0, right: 16),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();

                      pageOpen(ChatStoryScreen(index: index, listImage: list));
                    },
                    child: _buildStory(index),
                  ),
                );
              }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStory(int index) {
    return Hero(
      tag: ImageStorage.getImageByIndex(list[index]),
      child: customCachedImage(
        width: 72,
        height: 72,
        withBorder: true,
        url: ImageStorage.getImageByIndex(list[index]),
      ),
    );
  }

  Widget _videoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Short Videos",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          padding: EdgeInsets.only(left: 16),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 192,
          child: ListView.builder(
              itemCount: listVideo.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.only(left: index == 0 ? 16 : 0, right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                        width: 108,
                        height: 192,
                        color: Theme.of(context).cardColor,
                        child: VideoWidget(
                            url: VideoStorage.getVideoByIndex(
                                listVideo[index]))),
                  ),
                );
              }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChat(ChatRoom chats) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoContextMenu.builder(
        enableHapticFeedback: true,
        actions: <Widget>[
          CupertinoContextMenuAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              pageBack();
            },
            trailingIcon: CupertinoIcons.share,
            child: const CustomText(text: 'Share'),
          ),
          CupertinoContextMenuAction(
            onPressed: () async {
              HapticFeedback.lightImpact();
              await chatProvider.deleteChat(chats.id ?? "");
              pageBack();

              setState(() {});
            },
            isDestructiveAction: true,
            trailingIcon: CupertinoIcons.delete,
            child: const CustomText(text: 'Delete'),
          ),
        ],
        builder: (context, animation) {
          return animation.isCompleted
              ? GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();

                    if (animation.isCompleted) {
                      pageBack();
                    }

                    if (screenWidth > 600) {
                      widget.onWeb!(chats.id ?? "");
                    } else {
                      await pageOpenWithResult(
                          ChatRoomScreen(id: chats.id ?? ""));

                      setState(() {});
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
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
                    HapticFeedback.lightImpact();

                    if (animation.isCompleted) {
                      pageBack();
                    }

                    if (screenWidth > 600) {
                      widget.onWeb!(chats.id ?? "");
                    } else {
                      await pageOpenWithResult(
                          ChatRoomScreen(id: chats.id ?? ""));

                      setState(() {});
                    }
                  },
                  child: Container(
                    width: screenWidth * (animation.isCompleted ? 0.8 : 1),
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(
                            animation.isCompleted ? 20 : 0)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Row(
                      children: [
                        customCachedImage(
                          width: 45,
                          height: 45,
                          url: chats.image != null
                              ? (ImageStorage.baseUrl + (chats.image ?? ""))
                              : ImageStorage.defaultImage,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      text: chats.name ?? "-",
                                      fontWeight: FontWeight.w700,
                                      overflow: TextOverflow.clip,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  CustomText(
                                    text: DateFormat("HH.mm").format(
                                        DateTime.tryParse(
                                                (chats.messages?.isNotEmpty ??
                                                        false)
                                                    ? (chats
                                                            .messages
                                                            ?.lastOrNull
                                                            ?.timestamp ??
                                                        "")
                                                    : (chats.created ?? "")) ??
                                            DateTime.now()),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              CustomText(
                                text: chats.messages?.lastOrNull?.content ??
                                    "Start a message",
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        });
  }

  Widget _musicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Music",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          padding: EdgeInsets.only(left: 16),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 200,
          child: ListView.builder(
              itemCount: listMusic.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var artist = MusicStorage.getMusicByIndex(listMusic[index]);

                return Padding(
                  padding:
                      EdgeInsets.only(left: index == 0 ? 16 : 0, right: 16),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();

                      pageOpen(ChatMusicScreen(artist: artist));
                    },
                    child: Hero(
                      tag: artist.images?.firstOrNull?.url ?? "",
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          customCachedImage(
                            width: 175,
                            height: 200,
                            radius: 20,
                            isRectangle: true,
                            url: artist.images?.firstOrNull?.url ?? "",
                            isDrive: false,
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                width: 175,
                                height: 60,
                                padding: const EdgeInsets.all(10),
                                color: Colors.grey.shade800.withOpacity(0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomText(
                                      text: artist.name ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    CustomText(
                                      text:
                                          "${NumberFormat("#,##0", "en_US").format(artist.followers?.total ?? 0)} monthly listeners",
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
