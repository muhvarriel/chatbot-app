import 'dart:developer';
import 'dart:ui';

import 'package:chatbot_app/model/artist.dart';
import 'package:chatbot_app/model/artist_album.dart';
import 'package:chatbot_app/model/track.dart';
import 'package:chatbot_app/repository/music_repo.dart';
import 'package:chatbot_app/repository/user_repo.dart';
import 'package:chatbot_app/ui/widgets/custom_back_button.dart';
import 'package:chatbot_app/ui/widgets/custom_cached_image.dart';
import 'package:chatbot_app/ui/widgets/custom_text.dart';
import 'package:chatbot_app/utils/app_navigators.dart';
import 'package:chatbot_app/utils/music_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

class ChatMusicScreen extends StatefulWidget {
  final Artist artist;
  const ChatMusicScreen({super.key, required this.artist});

  @override
  State<ChatMusicScreen> createState() => _ChatMusicScreenState();
}

class _ChatMusicScreenState extends State<ChatMusicScreen> {
  bool isLoading = false;
  ArtistAlbumResponse? _artistAlbumResponse;
  List<Tracks> listTrack = [];

  final ScrollController _scrollController = ScrollController();

  String? description;

  final player = AudioPlayer();
  String? idPlayer;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });

    await MusicRepo.getArtistAlbum(widget.artist.id ?? "").then((value) {
      if (value[0] == 200) {
        _artistAlbumResponse = value[1];
      }
    });

    await MusicRepo.getArtistTopTrack(widget.artist.id ?? "").then((value) {
      if (value[0] == 200) {
        listTrack = value[1];
      }
    });

    await UserRepo.generateContent(
            text:
                "Tell me about ${widget.artist.name ?? ""} ${widget.artist.genres?.join(", ") ?? ""} in one paragraph")
        .then((value) {
      description = value;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar dummyAppBar = AppBar(
      title: const CustomText(
        text: "-",
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );

    double offset = _scrollController.hasClients ? _scrollController.offset : 0;

    double opacityBorder = (offset /
            (300 -
                (dummyAppBar.preferredSize.height +
                    MediaQuery.viewPaddingOf(context).top)))
        .clamp(0, 1);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor
            .withOpacity(opacityBorder),
        title: Opacity(
          opacity: opacityBorder,
          child: CustomText(
            text: widget.artist.name ?? "-",
            fontSize: 18,
            fontWeight: FontWeight.w700,
            padding: EdgeInsets.only(top: 16 - (16 * opacityBorder)),
          ),
        ),
        leading: const CustomBackButton(color: Colors.white),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Hero(
            tag: widget.artist.images?.firstOrNull?.url ?? "",
            child: customCachedImage(
              width: double.infinity,
              height: (300 - (offset > 0 ? offset : 0)).clamp(
                      dummyAppBar.preferredSize.height +
                          MediaQuery.viewPaddingOf(context).top,
                      300) +
                  (offset < 0 ? (offset * -1) : 0),
              isRectangle: true,
              url: widget.artist.images?.firstOrNull?.url ?? "",
              isDrive: false,
              isBlack: true,
            ),
          ),
          NotificationListener(
            onNotification: (notification) {
              setState(() {});
              return true;
            },
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(10),
                  child: CustomText(
                    text: widget.artist.name ?? "",
                    fontSize: 40 +
                        (_scrollController.hasClients
                            ? ((-1 * _scrollController.offset) / 40)
                                .clamp(0, 20)
                            : 0),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: "Popular Album",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          padding: EdgeInsets.only(left: 16),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                              itemCount: _artistAlbumResponse?.items?.length,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                var album = _artistAlbumResponse?.items?[index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: index == 0 ? 16 : 0, right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                    },
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        customCachedImage(
                                          width: 175,
                                          height: 200,
                                          radius: 20,
                                          isRectangle: true,
                                          url:
                                              album?.images?.firstOrNull?.url ??
                                                  "",
                                          isDrive: false,
                                        ),
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20)),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 10.0, sigmaY: 10.0),
                                            child: Container(
                                              width: 175,
                                              height: 57,
                                              padding: const EdgeInsets.all(10),
                                              color: Colors.grey.shade800
                                                  .withOpacity(0.5),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomText(
                                                    text: album?.name ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                  CustomText(
                                                    text: formatDate("d MMMM y",
                                                        date:
                                                            album?.releaseDate),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                );
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          text: "Top Track",
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          padding: EdgeInsets.only(left: 16),
                        ),
                        const SizedBox(height: 4),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: listTrack.length,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              var track = listTrack[index];

                              return TrackPreview(
                                tracks: track,
                                player: player,
                                idPlayer: idPlayer,
                                isAlbum: true,
                                onTap: () {
                                  setState(() {
                                    idPlayer = track.id;
                                  });
                                },
                                onEnd: () {
                                  setState(() {
                                    idPlayer = null;
                                  });
                                },
                              );
                            }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (description != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "About ${widget.artist.name ?? "-"}",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            const SizedBox(height: 10),
                            CustomText(
                              text:
                                  "${NumberFormat("#,##0", "en_US").format(widget.artist.followers?.total ?? 0)} monthly listeners",
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 10),
                            CustomText(
                              text: description ?? "-",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                        height: 16 + MediaQuery.viewPaddingOf(context).bottom),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrackPreview extends StatefulWidget {
  final Tracks tracks;
  final AudioPlayer player;
  final String? idPlayer;
  final Function() onTap;
  final Function() onEnd;
  final EdgeInsets? padding;
  final bool? isAlbum;

  const TrackPreview(
      {super.key,
      required this.tracks,
      required this.player,
      this.idPlayer,
      required this.onTap,
      required this.onEnd,
      this.padding,
      this.isAlbum});

  @override
  State<TrackPreview> createState() => _TrackPreviewState();
}

class _TrackPreviewState extends State<TrackPreview> {
  @override
  Widget build(BuildContext context) {
    widget.player.playerStateStream.listen((event) async {
      if (event.playing && mounted) {
        setState(() {});

        if (event.processingState == ProcessingState.completed) {
          await widget.player.stop();
          widget.onEnd();
        }
      }
    });

    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();

        if (widget.tracks.previewUrl != null) {
          if (widget.idPlayer == widget.tracks.id) {
            if (widget.player.playing) {
              await widget.player.pause();
            } else {
              await widget.player.play();
            }
          } else {
            widget.onTap();

            await widget.player
                .setUrl(widget.tracks.previewUrl ?? 'https://foo.com/bar.mp3');
            await widget.player.play();
          }
        }
      },
      child: Padding(
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                customCachedImage(
                  width: 50,
                  height: 50,
                  radius: 10,
                  isRectangle: true,
                  url: widget.tracks.album?.images?.firstOrNull?.url ?? "",
                  isDrive: false,
                  isBlack: widget.idPlayer == widget.tracks.id,
                ),
                if (widget.idPlayer == widget.tracks.id)
                  Center(
                      child: Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: widget.player.playerState.processingState ==
                                    ProcessingState.buffering
                                ? null
                                : (widget.player.position.inMilliseconds /
                                        (widget.player.duration
                                                ?.inMilliseconds ??
                                            1))
                                    .clamp(0, 1),
                          )))
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: widget.tracks.name ?? "",
                    overflow: TextOverflow.clip,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  CustomText(
                    text: (widget.isAlbum ?? false)
                        ? (widget.tracks.album?.name ?? "-")
                        : (widget.tracks.artists
                                ?.map((e) => e.name ?? "")
                                .toList()
                                .join(", ") ??
                            "-"),
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
