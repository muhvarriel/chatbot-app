import 'dart:math';

import 'package:chatbot_app/model/artist.dart';

class MusicStorage {
  static String baseUrl = "https://drive.usercontent.google.com/download?id=";
  static String exportUrl = "&export=download";

  static List<Artist> listMusic = [];

  static Artist get randomMusic =>
      listMusic[Random().nextInt(listMusic.length)];

  static Artist getMusicByIndex(int indexImage) {
    int index =
        indexImage < listMusic.length ? indexImage : (indexImage - indexImage);

    return listMusic[index];
  }
}

String formatMilliseconds(int milliseconds) {
  int seconds = (milliseconds / 1000).truncate();
  int minutes = (seconds / 60).truncate();
  seconds = seconds % 60;

  String minutesStr = (minutes % 60).toString().padLeft(2, '0');
  String secondsStr = seconds.toString().padLeft(2, '0');

  return "$minutesStr minutes $secondsStr seconds";
}
