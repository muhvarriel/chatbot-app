import 'dart:developer';

import 'package:chatbot_app/model/artist.dart';
import 'package:chatbot_app/model/artist_album.dart';
import 'package:chatbot_app/model/track.dart';
import 'package:chatbot_app/services/network_service.dart';
import 'package:chatbot_app/utils/music_storage.dart';
import 'package:chatbot_app/utils/shared_helpers.dart';
import 'package:dio/dio.dart';

class MusicRepo {
  static final _dio = NetworkService.initDio();
  static Future<void> generateToken() async {
    try {
      final options = BaseOptions(
          baseUrl: "https://accounts.spotify.com/api/",
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          });

      final data = {
        "grant_type": "client_credentials",
        "client_id": "f2e888211f5a43cf9a0e8de013ed7ce5",
        "client_secret": "f0a2c596ad3440ef8e543f16111ff05d"
      };

      final response = await Dio(options).post("token", data: data);

      log("Response: $response");

      await setSharedString(
          "spofityToken", response.data['access_token'].toString());
    } on DioException catch (e) {
      print('error generateToken $e');
    }
  }

  static Future<void> musicLoaded() async {
    List<Artist> listArtist = [];
    do {
      await getArtists("41MozSoPIsD1dJM0CLPjZF").then((value) async {
        if (value[0] == 200) {
          listArtist = value[1];
        } else {
          await generateToken();
        }
      });
    } while (listArtist.isEmpty);

    MusicStorage.listMusic = listArtist;
  }

  static Future<dynamic> getArtists(String id) async {
    try {
      final response = await _dio.get("artists/$id/related-artists");

      List<Artist> artists =
          List.from(response.data['artists'].map((e) => Artist.fromJson(e)));

      return [response.statusCode, artists];
    } on DioException catch (e) {
      print('error $e');
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getArtistAlbum(String id) async {
    try {
      final response = await _dio.get("artists/$id/albums?limit=5");

      ArtistAlbumResponse artists = ArtistAlbumResponse.fromJson(response.data);

      return [response.statusCode, artists];
    } on DioException catch (e) {
      print('error $e');
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getArtistTopTrack(String id) async {
    try {
      final response = await _dio.get("artists/$id/top-tracks");

      List<Tracks> tracks =
          List.from(response.data['tracks'].map((e) => Tracks.fromJson(e)));

      return [response.statusCode, tracks];
    } on DioException catch (e) {
      print('error $e');
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> searchTrack(String content) async {
    try {
      String query = content.replaceAll(" ", "+");

      final response = await _dio.get("search?q=$query&type=track&limit=1");

      log("searchTrack: $response");

      TracksResponse tracks = TracksResponse.fromJson(response.data['tracks']);

      return [response.statusCode, tracks];
    } on DioException catch (e) {
      print('error $e');
      return [e.response?.statusCode ?? 500, null];
    }
  }

  static Future<dynamic> getAlbumTrack(String id) async {
    try {
      final response = await _dio.get("albums/$id/tracks");

      TracksResponse tracks = TracksResponse.fromJson(response.data);

      return [response.statusCode, tracks];
    } on DioException catch (e) {
      print('error $e');
      return [e.response?.statusCode ?? 500, null];
    }
  }
}
