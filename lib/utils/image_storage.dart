import 'dart:convert';
import 'dart:math';

import 'package:chatbot_app/utils/shared_helpers.dart';

class ImageStorage {
  static String baseUrl = "https://lh3.googleusercontent.com/d/";
  static String defaultImage = "${baseUrl}1H7GsjhnFneAI_6yC39cyW3CeSpikiqkm";

  static List<String> listImage = [];

  static String get randomImage =>
      listImage[Random().nextInt(listImage.length)];

  static String getImageByIndex(int indexImage) {
    int index =
        indexImage < listImage.length ? indexImage : (indexImage - indexImage);

    return "$baseUrl${listImage[index]}";
  }

  static Future<void> saveImage(List<String> images) async {
    listImage = images;
    await setSharedListString("ImageStorage", listImage);
  }

  static Future<void> loadImage() async {
    listImage = await getSharedListString("ImageStorage");
  }
}
