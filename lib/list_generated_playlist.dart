import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'editGenerator.dart';
import 'metrictype.dart';

import 'main.dart';

class GeneratedPlaylist extends ChangeNotifier {
  List<dynamic> value = [];
  void update({required List<dynamic> value}) {
    this.value = value;
    this.notifyListeners();
  }
}

final generatedPlaylistProvider = ChangeNotifierProvider<GeneratedPlaylist>(
  (context) => GeneratedPlaylist(),
);

class ListGeneratedPlaylist extends StatelessWidget {
  final List<dynamic> items;

  const ListGeneratedPlaylist({Key? key, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Long List';
    print(items);
    return Column(children: [
      Text('Playlist generated'),
      Flexible(
          child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]['title']),
            subtitle: Text(items[index]['artist']),
          );
        },
      ))
    ]);
  }
}

Future<String?> getCurrentUserId(token) async {
  var url = "https://api.spotify.com/v1/me";
  print(url);
  final response = await http.get(Uri.parse(url), headers: {
    HttpHeaders.authorizationHeader: 'Bearer $token',
    HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    HttpHeaders.acceptHeader: ContentType.json.mimeType
  });
  if (response.statusCode != 200) {
    return null;
  }
  final jsonResponse = json.decode(response.body)['id'];
  //response.body
  print(jsonResponse);
  return jsonResponse;
}

Future<String?> buildNewPlaylist(
    String token, String userId, String name) async {
  var url = "https://api.spotify.com/v1/users/$userId/playlists";
  print(url);
  final response = await http.post(Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.acceptHeader: ContentType.json.mimeType
      },
      body: json.encode({
        "name": name,
        "description": "Generated at " + DateTime.now().toIso8601String(),
        "public": false
      }));
  print(response.statusCode);
  if (response.statusCode != 201) {
    return null;
  }
  final jsonResponse = json.decode(response.body)['id'];
  //response.body
  print(jsonResponse);
  return jsonResponse;
}

List tracksToList(List tracks, int begin, int end) {
  List result = [];
  for (int i = begin; i < end; i++) {
    result.add('spotify:track:' + tracks[i]['id']);
  }
  return result;
}

Future<bool> saveInPlaylist(
    String token, String playlistId, List playlist) async {
  print("in saveInPlaylist");
  print('tosave length ' + playlist.length.toString());
  for (int i = 0; i < playlist.length; i += 100) {
    var url = "https://api.spotify.com/v1/playlists/$playlistId/tracks";
    print(url);
    print(HttpHeaders.acceptHeader + ' ' + ContentType.json.mimeType);
    final response = await http.post(Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          HttpHeaders.acceptHeader: ContentType.json.mimeType
        },
        body: json.encode({
          "uris": tracksToList(playlist, i, min(playlist.length, i + 100)),
          "position": i
        }));
    if (response.statusCode != 201) {
      return false;
    }
  }
  return true;
}

void savePlaylist(String token, List playlist) async {
  String? userId = await getCurrentUserId(token);
  if (userId == null) {
    return;
  }
  String name = "New Moodplaner playlist";
  String? playlistId = await buildNewPlaylist(token, userId, name);
  if (playlistId == null) {
    return;
  }
  saveInPlaylist(token, playlistId, playlist);

  //create new playlist
  //add with loop
}
