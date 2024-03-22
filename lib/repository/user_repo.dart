import 'dart:convert';
import 'dart:developer';

import 'package:chatbot_app/model/chat_room.dart';
import 'package:chatbot_app/utils/constants.dart';
import 'package:chatbot_app/utils/image_storage.dart';
import 'package:chatbot_app/utils/video_storage.dart';
import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class UserRepo {
  static Future<GenerativeModel?> generateModel(
      {GenerationConfig? generationConfig}) async {
    try {
      final model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
          generationConfig: generationConfig);

      return model;
    } catch (e) {
      print('error $e');
      return null;
    }
  }

  static Future<String?> generateContent({String? text}) async {
    try {
      final model = await generateModel();

      if (model == null) {
        print('model is null');
        return null;
      }

      final content = [Content.text(text ?? "")];
      final response = await model.generateContent(content);

      return response.text;
    } catch (e) {
      print('error $e');
      return null;
    }
  }

  static Future<String?> sendText(
      {String? text, List<Messages>? history}) async {
    try {
      final model = await generateModel();

      if (model == null) {
        print('model is null');
        return null;
      }

      List<Content>? listContent = history
          ?.map((e) => e.sender?.id == 0
              ? Content.text(e.content ?? "")
              : Content.model([TextPart(e.content ?? "")]))
          .toList();

      log("listContent: ${jsonEncode(listContent)}");

      final chat = model.startChat(history: listContent);
      var content = Content.text(text ?? "");
      var response = await chat.sendMessage(content);

      return response.text;
    } on GenerativeAIException catch (e) {
      print('error $e');
      return e.message;
    }
  }

  static Future<void> getImageDrive() async {
    Dio dio = Dio();

    try {
      final start = DateTime.now();

      List<String> listImage = [];

      final response = await dio.get(
          "https://drive.google.com/drive/folders/1BVifYqPxqs9pcfSbwn_sgEnQun13d-SR");

      List<String> result = extractDataIds(response.data);

      for (var i = 0; i < result.length; i++) {
        final responseFolder = await dio
            .get("https://drive.google.com/drive/folders/${result[i]}");

        listImage.addAll(extractDataIds(responseFolder.data));
      }

      final end = DateTime.now();

      log(listImage.length.toString());
      log(end.difference(start).toString());

      ImageStorage.listImage = listImage;
    } catch (e) {
      print('error $e');
    }
  }

  static Future<void> getVideoDrive() async {
    Dio dio = Dio();

    try {
      final start = DateTime.now();

      List<String> listVideo = [];

      final response = await dio.get(
          "https://drive.google.com/drive/folders/1TCmV46wJuDZ4162vnhXZfqw77A3L69qE");

      List<String> result = extractDataIds(response.data);

      for (var i = 0; i < result.length; i++) {
        final responseFolder = await dio
            .get("https://drive.google.com/drive/folders/${result[i]}");

        listVideo.addAll(extractDataIds(responseFolder.data));
      }

      final end = DateTime.now();

      log(listVideo.length.toString());
      log(end.difference(start).toString());

      VideoStorage.listVideo = listVideo;
    } catch (e) {
      print('error $e');
    }
  }

  static List<String> extractDataIds(String response) {
    List<String> dataIds = [];

    RegExp regex = RegExp(r'data-id="([^"]*)"');

    Iterable<Match> matches = regex.allMatches(response);

    for (Match match in matches) {
      if (match.groupCount >= 1) {
        dataIds.add(match.group(1)!);
      }
    }

    return dataIds;
  }
}
