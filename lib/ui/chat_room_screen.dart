
import 'package:chatbot_app/model/chat_room.dart';
import 'package:chatbot_app/repository/user_repo.dart';
import 'package:chatbot_app/ui/widgets/custom_cached_image.dart';
import 'package:chatbot_app/ui/widgets/custom_text.dart';
import 'package:chatbot_app/utils/app_navigators.dart';
import 'package:chatbot_app/repository/chat_provider.dart';
import 'package:chatbot_app/utils/image_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final String id;
  final bool? preview;

  const ChatRoomScreen({super.key, required this.id, this.preview});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  bool isTyping = false;

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late ChatRoom chatRoom;

  late ChatProvider chatProvider;

  @override
  void initState() {
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    chatRoom = chatProvider.chats.firstWhereOrNull((e) => e.id == widget.id) ??
        ChatRoom(messages: []);

    List<String> listDate = (chatRoom.messages ?? [])
        .map((e) => formatDate("yyyy-MM-dd", date: e.timestamp ?? ""))
        .toSet()
        .toList();

    String today = formatDate("yyyy-MM-dd", date: DateTime.now().toString());
    String yesterday = formatDate("yyyy-MM-dd",
        date: DateTime.now().subtract(const Duration(days: 1)).toString());

    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            customCachedImage(
              width: 35,
              height: 35,
              url: chatRoom.image != null
                  ? (ImageStorage.baseUrl + (chatRoom.image ?? ""))
                  : ImageStorage.defaultImage,
            ),
            const SizedBox(width: 12),
            CustomText(
              text: chatRoom.name ?? "ChatBot Room",
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      opacity: isDark ? 0.05 : 0.1,
                      image: NetworkImage(
                          "${ImageStorage.baseUrl}1oCZVK8nyNTW7pr6-c4oi799OM74nXSN1"),
                      fit: BoxFit.cover)),
              child: (chatRoom.messages?.isEmpty ?? false)
                  ? const Center(
                      child: CustomText(
                      text: "Start a message",
                      fontWeight: FontWeight.bold,
                    ))
                  : ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: listDate.length,
                      itemBuilder: (context, index) {
                        var listMessage = chatRoom.messages
                                ?.where((e) =>
                                    listDate[index] ==
                                    formatDate("yyyy-MM-dd",
                                        date: e.timestamp ?? ""))
                                .toList() ??
                            [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin:
                                    EdgeInsets.only(top: index == 0 ? 16 : 0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CustomText(
                                  text: listDate[index] == today
                                      ? "Today"
                                      : (listDate[index] == yesterday
                                          ? "Yesterday"
                                          : formatDate("d MMM yyyy",
                                              date: listDate[index])),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                )),
                            for (var messages in listMessage)
                              Container(
                                padding: const EdgeInsets.only(top: 16),
                                alignment: messages.sender?.id == 0
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: messages.sender?.id == 0
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    CupertinoContextMenu.builder(
                                      enableHapticFeedback: true,
                                      actions: <Widget>[
                                        CupertinoContextMenuAction(
                                          onPressed: () async {
                                            HapticFeedback.lightImpact();
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: messages.content ??
                                                        ""));

                                            pageBack();
                                          },
                                          trailingIcon: CupertinoIcons
                                              .doc_on_clipboard_fill,
                                          child: const CustomText(text: 'Copy'),
                                        ),
                                        CupertinoContextMenuAction(
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            pageBack();
                                          },
                                          trailingIcon: CupertinoIcons.share,
                                          child:
                                              const CustomText(text: 'Share'),
                                        ),
                                      ],
                                      builder: (context, animation) {
                                        return Container(
                                          constraints: BoxConstraints(
                                              maxWidth: screenWidth *
                                                  (screenWidth > 600
                                                      ? 0.3
                                                      : screenWidth > 1024
                                                          ? 0.5
                                                          : 0.7)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16),
                                          decoration: BoxDecoration(
                                              color: messages.sender?.id == 0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .tertiary,
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      const Radius.circular(20),
                                                  bottomLeft: Radius.circular(
                                                      messages.sender?.id == 0
                                                          ? 20
                                                          : 5),
                                                  bottomRight: Radius.circular(
                                                      messages.sender?.id == 0
                                                          ? 5
                                                          : 20),
                                                  topRight:
                                                      const Radius.circular(
                                                          20))),
                                          child: CustomText(
                                            text: messages.content ?? "",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            overflow: TextOverflow.clip,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    CustomText(
                                      text: formatDate("HH.mm",
                                          date: messages.timestamp ?? ""),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
            ),
          ),
          if (widget.preview != true)
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.2)))),
              padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8 +
                      (MediaQuery.viewInsetsOf(context).bottom > 0
                          ? 8
                          : (MediaQuery.viewPaddingOf(context).bottom == 0
                              ? 8
                              : MediaQuery.viewPaddingOf(context).bottom))),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(50)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _textEditingController,
                        placeholder: isTyping ? "Typing..." : "Send message",
                        placeholderStyle: GoogleFonts.mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700),
                        decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                        style: GoogleFonts.mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade900),
                        maxLines: 3,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) async {
                          await _sendMessage();
                        },
                        readOnly: isTyping,
                      ),
                    ),
                    isTyping
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator())
                        : InkWell(
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              await _sendMessage();
                            },
                            child: const Icon(
                              Icons.send_rounded,
                              size: 24,
                            ),
                          )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textEditingController.text.isNotEmpty && !isTyping) {
      String text = _textEditingController.text;
      int idText = chatRoom.messages?.length ?? 0;

      setState(() {
        _textEditingController.clear();
        chatRoom.messages?.add(Messages(
          id: chatRoom.messages?.length,
          sender: Sender(
            id: 0,
            username: "varriel_nzr",
          ),
          timestamp: DateTime.now().toString(),
          content: text,
        ));
        isTyping = true;
      });

      if ((chatRoom.messages?.length ?? 0) > 1) {
        Future.delayed(const Duration(milliseconds: 100)).then((value) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent -
                  MediaQuery.of(context).viewInsets.bottom,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
        });
      }

      await UserRepo.sendText(
              text: text,
              history: chatRoom.messages?.where((e) => e.id != idText).toList())
          .then((value) async {
        if (value != null) {
          setState(() {
            chatRoom.messages?.add(Messages(
              id: chatRoom.messages?.length,
              sender: Sender(
                id: 1,
                username: chatRoom.name ?? "ChatBot",
              ),
              timestamp: DateTime.now().toString(),
              content: value,
            ));
            isTyping = false;
          });

          Future.delayed(const Duration(milliseconds: 100)).then((value) {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          });

          await chatProvider.updateChat(chatRoom);
        }
      });
    }
  }
}
