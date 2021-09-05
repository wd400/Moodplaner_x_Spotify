import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moodplaner_x_spotify/list_playlists.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;

import 'chips_widget.dart';
import 'graph_widget.dart';
import 'list_generated_playlist.dart';
import 'main.dart';
import 'metrictype.dart';

final int _offsetXvaluesMin = 6;
final int _offsetXvaluesMax = 40;

class CollectionGenerator extends StatefulWidget {
  CollectionGenerator({Key? key}) : super(key: key);

  @override
  _CollectionGeneratorState createState() => _CollectionGeneratorState();
}

class _CollectionGeneratorState extends State<CollectionGenerator> {
  Future<List> downloadPlaylistData() async {
    List newData = [];
    List result = [];
    int offset = 0;
    while (true) {
      var url =
          "https://api.spotify.com/v1/playlists/${context.read(currentPlaylistIdProvider).value}/tracks?fields=items.track(name%2Cid%2Cartists.name)&limit=100&offset=$offset";
      final response = await http.get(Uri.parse(url), headers: {
        HttpHeaders.authorizationHeader:
            'Bearer ${context.read(tokenProvider).token}',
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.acceptHeader: ContentType.json.mimeType
      });
      if (response.statusCode != 200) {
        return Future.error(Error);
      }

      newData = json.decode(response.body)['items'];

      if (newData.length == 0) {
        break;
      }
      result += newData;
      offset += 100;
    }
    //response.body
    return result;
  }

  @override
  void initState() {
    super.initState();
    // context.read(graphDataProvider).useCustomData(generator);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SafeArea(
              child:

                  //   Text(this.widget.generator.generatorName??"Unamed",textAlign: TextAlign.center,),

                  Text(
            'Generator',
            textAlign: TextAlign.center,
          )),
          Flexible(
              child: Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                SizedBox(
                    width: 35,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Icon(Icons.zoom_in),
                          Flexible(
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Consumer(
                                builder: (BuildContext context,
                                    T Function<T>(ProviderBase<Object?, T>)
                                        watch,
                                    Widget? child) {
                                  var value =
                                      watch(offsetXvaluesProvider).value;
                                  return Slider(
                                    value: (value - _offsetXvaluesMin) /
                                        (_offsetXvaluesMax - _offsetXvaluesMin),
                                    onChanged: (newValue) {
                                      context.read(offsetXvaluesProvider).update(
                                          value: (newValue *
                                                      (_offsetXvaluesMax -
                                                          _offsetXvaluesMin) +
                                                  _offsetXvaluesMin)
                                              .toInt());
                                    },
                                    onChangeEnd: (newValue) {
                                      //TODO: code redondant
                                      context.read(offsetXvaluesProvider).update(
                                          value: (newValue *
                                                      (_offsetXvaluesMax -
                                                          _offsetXvaluesMin) +
                                                  _offsetXvaluesMin)
                                              .toInt());
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          const Icon(Icons.zoom_out),
                        ])),
                Flexible(
                    child: Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)),
                        child: Stack(fit: StackFit.expand, children: <Widget>[
                          ClipRect(
                              //  borderRadius: BorderRadius.circular(10),
                              child: Container(
//     color: Colors.tealAccent,
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                            return DrawableBoard(constraints: constraints);
                          }))),
                          Align(
                            alignment: Alignment.topRight,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: ToggleSwitch(
                                minHeight: 30,
                                minWidth: 40.0,
//       cornerRadius: 20.0,
//   activeBgColors: [[Colors.cyan], [Colors.redAccent]],
//   activeFgColor: Colors.white,
//  inactiveBgColor: Colors.grey,
//   inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                icons: const [
                                  FontAwesomeIcons.chartLine,
                                  FontAwesomeIcons.chartBar
                                ],

                                onToggle: (index) {
                                  context
                                      .read(paintSettingsProvider)
                                      .updatebargraph(value: index == 1);
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: ToggleSwitch(
//     minWidth: 90.0,
//       cornerRadius: 20.0,
//   activeBgColors: [[Colors.cyan], [Colors.redAccent]],
//   activeFgColor: Colors.white,
//  inactiveBgColor: Colors.grey,
//   inactiveFgColor: Colors.white,
                                initialLabelIndex: 1,
                                totalSwitches: 2,
                                icons: const [
                                  FontAwesomeIcons.eraser,
                                  FontAwesomeIcons.pen
                                ],
                                onToggle: (index) {
                                  context
                                      .read(eraseModeProvider)
                                      .setEraser(value: index == 0);
                                },
                              ),
                            ),
                          ),
                        ]))),
              ])),

          SizedBox(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => MultiSelectDialog(
                          initialValue: context
                              .read(graphDataProvider)
                              .generator
                              .keys
                              .toList(),
                          items: METRICS.keys
                              .map((value) => MultiSelectItem<String?>(
                                  METRICS[value]!.metricCode,
                                  METRICS[value]!.name))
                              .toList(),
                          listType: MultiSelectListType.CHIP,
                          onConfirm: (values) {
                            //  if (values.isNotEmpty) {
                            //  context.read(currentMetricIdProvider).update(metricId: values[0] as int);
                            //  }
                            context
                                .read(graphDataProvider)
                                .updateMetricid(values);
                          },
                        ),
                      );
                    },
                  ),

                  Flexible(child: ChipWidget()),
//graphDataProvider
//currentPlaylistIdProvider

                  IconButton(
                      onPressed: () {
                        downloadPlaylistData().then((value) =>
                            extractTrackMetrics(value)
                                .then((value) => buildPlaylist(value)));
                      },
                      icon: Icon(Icons.play_arrow))
//          ElevatedButton(onPressed: null,child: Icon(Icons.delete)),

                  /*    IconButton(

                        icon: Icon(Icons.save),
             onPressed: () {
                          widget.generator.measures= context.read(graphDataProvider).data;
                          widget.generator.lastModif=DateTime.now();
                          widget.generator.save();
             },
           )

                 ,  */
                ],
              )),
          //  Flexible(child:Container())
        ]);
  }

  double L1(List<double?> genValues, double musicValue, double musicDuration,
      double startTime) {
    double result = 0;

    int genIdx = (startTime / deltaTime.inMilliseconds).floor();
    double offset = startTime - genIdx * deltaTime.inMilliseconds;
    double window = 0;
    double nextStep = 0;
    while (genIdx < genValues.length) {
      if (musicDuration - window < deltaTime.inMilliseconds - offset) {
        nextStep = musicDuration - window;

        if (genValues[genIdx] != null) {
          result += nextStep * (musicValue - genValues[genIdx]!).abs();
        }
        return result / musicDuration;
      } else {
        nextStep = deltaTime.inMilliseconds - offset;
        if (genValues[genIdx] != null) {
          result += nextStep * (musicValue - genValues[genIdx]!).abs();
        }
        window += nextStep;
        offset = 0;
        genIdx += 1;
      }
    }
    return result / window;
  }

  double dist(Map<String, List<double?>> generator, Map<String, dynamic> music,
      double startTime) {
    int dims = 0;
    double result = 0;
    for (String metric in generator.keys) {
      dims += 1;
      result += L1(
          generator[metric]!, music[metric], music['duration_ms'], startTime);
    }
    return result / dims;
  }

  int bestMatch(
      Map<String, List<double?>> generator, List musics, double startTime) {
    double smallestDist = double.maxFinite;
    double tmp;
    int bestMatch = -1;
    for (int i = 0; i < musics.length; i++) {
      tmp = dist(generator, musics[i], startTime);
      if (tmp < smallestDist) {
        smallestDist = tmp;
        bestMatch = i;
      }
    }

    return bestMatch;
  }

  buildPlaylist(List value) {
    List result = [];
    //TODO:normalize
    //TODO: check if playlist empty before download
    double playlistDuration = 0;
    Map<String, List<double?>> generator =
        context.read(graphDataProvider).generator;
    int lastActivated = context.read(graphDataProvider).lastActivated;

    int tmp;
    while (playlistDuration < lastActivated * deltaTime.inMilliseconds &&
        value.length > 0) {
      tmp = bestMatch(generator, value, playlistDuration);
      playlistDuration += value[tmp]['duration_ms'];
      result.add(value[tmp]);
      value.removeAt(tmp);
    }

    context.read(generatedPlaylistProvider).update(value: result);
  }

  String buildIdsRequest(List value, int begin, int end) {
    String result = value[begin]['track']['id'];

    for (int i = begin + 1; i < end; i++) {
      result += ',' + value[i]['track']['id'];
    }

    return result;
  }

  String artistsToString(List artists) {
    String result = artists[0]['name'];

    for (int i = 1; i < artists.length; i++) {
      result += ', ' + artists[i]['name'];
    }

    return result;
  }

  Future<List> extractTrackMetrics(List value) async {
    List trackMetrics = [];
    for (int i = 0; i < value.length; i += 100) {
      var url = "https://api.spotify.com/v1/audio-features?ids=" +
          buildIdsRequest(value, i, min(i + 100, value.length));

      final response = await http.get(Uri.parse(url), headers: {
        HttpHeaders.authorizationHeader:
            'Bearer ${context.read(tokenProvider).token}',
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.acceptHeader: ContentType.json.mimeType
      });
      if (response.statusCode != 200) {
        return Future.error(Error);
      }
      List features = json.decode(response.body)['audio_features'];
      for (int j = 0; j < features.length; j++) {
        features[j]['artist'] =
            artistsToString(value[j + i]['track']['artists']);
        features[j]['title'] = value[j + i]['track']['name'];
      }
      trackMetrics += features;
    }
    return trackMetrics;
  }
}

class EraseMode extends ChangeNotifier {
  bool eraser = false;

  void setEraser({required bool value}) {
    this.eraser = value;
  }
}

final eraseModeProvider = ChangeNotifierProvider<EraseMode>(
  (context) => EraseMode(),
);
