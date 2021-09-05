import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'dart:html';
import 'editGenerator.dart';
import 'list_generated_playlist.dart';
import 'list_playlists.dart';


final currentUri= Uri.base;

final redirectUri=Uri(
  host:currentUri.host,
  scheme:currentUri.scheme,
  port:currentUri.port,
  path:'/',
);

final authUrl = 'https://accounts.spotify.com/authorize?client_id=448ecc40021045d99f840f245e1240fe&redirect_uri=$redirectUri&scope=user-read-private%20playlist-read-private%20playlist-modify-private&response_type=token&state=';


class Token extends ChangeNotifier {
  String? token;
  void update({required String? value}) {
    this.token = value;
    this.notifyListeners();
  }
}

final tokenProvider=ChangeNotifierProvider<Token>(
      (context) => Token(),
);



void main() {
  runApp(ProviderScope(child:MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  void _login(Uri receivedUri) {
    print(receivedUri);
    context.read(tokenProvider).update(value: receivedUri.fragment.split('&')
        .firstWhere((e) => e.startsWith('access_token='))
        .substring('access_token='.length));
  }

  @override
  void initState() {
    super.initState();


    if (currentUri.fragment.contains('access_token=')) {
      _login(currentUri);
      
    } else {
WidgetsBinding.instance!.addPostFrameCallback((_) {
  window.location.assign(
      authUrl);});
    }
  }




  Widget list = ListPlaylist();
  Widget generator = CollectionGenerator();




  @override
  Widget build(BuildContext context) {

    Widget generatedPlaylist =    Column(children:[
      Flexible(child: Consumer(
          builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
            return ListGeneratedPlaylist(
              items: watch(generatedPlaylistProvider).value,
            );
          }
      )),
      IconButton(onPressed: (){savePlaylist(context.read(tokenProvider).token!,context.read(generatedPlaylistProvider).value);}, icon: Icon(Icons.save))
    ]);


    return Scaffold(
      appBar: AppBar(
        title: Text("Moodplaner x Spotify",textAlign: TextAlign.center,),
      ),
      body: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {

    if (constraints.maxWidth > 600) {
    return Row(children: [Flexible(child:list),Flexible(child:FractionallySizedBox(child: generator,heightFactor: 0.8,),flex:4),Flexible(child:generatedPlaylist)]);
    } else {
    return Row(children: [
      IconButton(onPressed: (){
     showDialog(context: context, builder: (context)
       {
         return AlertDialog(content: SizedBox(width:constraints.maxWidth,height: constraints.maxHeight,child:list),
       actions: [
       TextButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: Text('Done'),)],
        );});


      }, icon: Icon(Icons.playlist_add_check))
      ,
   Flexible(child:   generator),

      IconButton(onPressed: (){
        showDialog(context: context, builder: (context)
        {
          return AlertDialog(content: SizedBox(width:constraints.maxWidth,height: constraints.maxHeight,child:generatedPlaylist),
            actions: [
              TextButton(onPressed: () {
                Navigator.of(context).pop();
              }, child: Text('Done'),)],
          );});


      }, icon: Icon(Icons.playlist_add_check_rounded))


    ],);
    }
    }));




  }
}





