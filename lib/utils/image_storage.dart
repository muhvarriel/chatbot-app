import 'dart:math';

class ImageStorage {
  static String baseUrl = "https://lh3.googleusercontent.com/d/";
  static String defaultImage = "${baseUrl}1H7GsjhnFneAI_6yC39cyW3CeSpikiqkm";

  static List<String> listImage = [];

  static String get randomImage =>
      listImage[Random().nextInt(listImage.length)];

  static String getImageByIndex(int indexImage, {double? size}) {
    int index =
        indexImage < listImage.length ? indexImage : (indexImage - indexImage);

    return "$baseUrl${listImage[index]}${size != null ? "=w$size-h$size-p-k-rw-v1-nu-iv1" : ""}";
  }
}