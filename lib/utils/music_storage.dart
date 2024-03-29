import 'dart:math';

import 'package:chatbot_app/model/artist.dart';
import 'package:chatbot_app/utils/shared_helpers.dart';

class MusicStorage {
  static String baseUrl = "https://drive.usercontent.google.com/download?id=";
  static String exportUrl = "&export=download";

  static List<Artist> listMusic = [];
  static List<String> favouriteArtist = [];

  static Artist get randomMusic =>
      listMusic[Random().nextInt(listMusic.length)];

  static Artist getMusicByIndex(int indexImage) {
    int index =
        indexImage < listMusic.length ? indexImage : (indexImage - indexImage);

    return listMusic[index];
  }

  static Future<void> addFavourite(String id) async {
    favouriteArtist.add(id);
    await saveStorage();
  }

  static Future<void> removeFavourite(String id) async {
    favouriteArtist.remove(id);
    await saveStorage();
  }

  static Future<void> saveStorage() async {
    await setSharedListString("favouriteArtist", favouriteArtist);
  }

  static Future<void> loadStorage() async {
    favouriteArtist = await getSharedListString("favouriteArtist");
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
