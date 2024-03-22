import 'dart:math';

class VideoStorage {
  static String baseUrl = "https://drive.usercontent.google.com/download?id=";
  static String exportUrl = "&export=download";

  static List<String> listVideo = [];

  static String get randomImage =>
      listVideo[Random().nextInt(listVideo.length)];

  static String getVideoByIndex(int indexImage) {
    int index =
        indexImage < listVideo.length ? indexImage : (indexImage - indexImage);

    return "$baseUrl${listVideo[index]}$exportUrl";
  }
}
