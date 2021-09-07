import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class ListPlaylist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new ListPlaylistState();
}

class CurrentPlaylistId extends ChangeNotifier {
  late String value;
  void update({required String value}) {
    this.value = value;
    this.notifyListeners();
  }
}

final currentPlaylistIdProvider = ChangeNotifierProvider<CurrentPlaylistId>(
  (context) => CurrentPlaylistId(),
);

List users = [];

class ListPlaylistState extends State<ListPlaylist> {
  static int page = 0;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  int selected = -1;

  @override
  void initState() {
    this._getMoreData(page);
    super.initState();
    _sc.addListener(() {
      if (_sc.hasClients) {
        if (_sc.position.pixels == _sc.position.maxScrollExtent) {
          _getMoreData(page);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("Select musics to use",textAlign: TextAlign.center,style:TextStyle(
          fontWeight: FontWeight.bold,),),
      Flexible(
          child: Container(
        child: _buildList(),
      ))
    ]);
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: users.length + 1, // Add one more item for progress indicator
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (BuildContext context, int index) {
        if (index == users.length) {
          return _buildProgressIndicator();
        } else {
          return new ListTile(
            selected: index == selected,
            title: Text((users[index]['name'])),
            onTap: () {
              setState(() {
                selected = index;
                context
                    .read(currentPlaylistIdProvider)
                    .update(value: users[index]['id']);
              });
            },
          );
        }
      },
      controller: _sc,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          indent: 40,
          endIndent: 40,
          color: Colors.black,
        );
      },
    );
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = "https://api.spotify.com/v1/me/playlists?offset=" +
          (50 * index).toString() +
          "&limit=50";
      final response = await http.get(Uri.parse(url), headers: {
        HttpHeaders.authorizationHeader:
            'Bearer ${context.read(tokenProvider).token}',
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.acceptHeader: ContentType.json.mimeType
      });
      if (response.statusCode != 200) {
        return;
      }
      final jsonResponse = json.decode(response.body);
      //response.body
      for (int i = 0; i < jsonResponse['items'].length; i++) {
        users.add(jsonResponse['items'][i]);
      }
      isLoading = false;
      setState(() {
        //        users.addAll(tList);
        if (jsonResponse['items'].length > 0) {
          page++;
        }
      });
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }
}
