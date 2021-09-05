import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'editGenerator.dart';
import 'metrictype.dart';

final random = new Random();

const deltaTime = Duration(minutes: 2);

class OffsetXvalues extends ChangeNotifier {
  int value;
  OffsetXvalues({required this.value});
  void update({required int value}) {
    this.value = value;
    this.notifyListeners();
  }
}

final offsetXvaluesProvider=ChangeNotifierProvider.autoDispose<OffsetXvalues>(
      (context) => OffsetXvalues(value: 20),
);


class PaintSettings extends ChangeNotifier {
  bool bargraph=false;

  PaintSettings();

  void updatebargraph({required bool value}) {
    this.bargraph = value;
    this.notifyListeners();
  }

}

final paintSettingsProvider=ChangeNotifierProvider.autoDispose<PaintSettings>(
      (context) => PaintSettings(),
);


final double autoscrollMargin =30;


const int deltaTimePix = 100;

const _maxtime = Duration(hours: 6);

const double bottomMargin = 0;
const double upMargin = 0;

//int offsetXvalues = 10;

final int _nbOfXvalues = _maxtime.inMinutes ~/ deltaTime.inMinutes;

TextPainter measureText(String s, TextStyle style) {
  final ts = TextSpan(text: s, style: style);
  final tp = TextPainter(
      text: ts, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
  tp.layout(maxWidth: double.maxFinite);
  return tp;
}

void paintText(Canvas canvas, Offset pos, TextPainter tp) {
  tp.paint(canvas, pos);
}

void drawText(Canvas canvas, Offset pos, String s, TextStyle style) {
  final tp = measureText(s, style);

  paintText(canvas, Offset(pos.dx, pos.dy - tp.height / 2), tp);
}

double margintooffset(double margin) {
  return min(7, margin);
}

class DrawableBoard extends StatefulWidget {
  final BoxConstraints constraints;

  const DrawableBoard({required this.constraints});

  @override
  _DrawableBoardState createState() => _DrawableBoardState();
}

//Size size = window.physicalSize / window.devicePixelRatio;

class _DrawableBoardState extends State<DrawableBoard> {
  int offsetXvalue = 100;



  Timer? autoscroll;

  bool scrolling = false;



  ScrollController _scrollController = ScrollController();
  Size size = const Size(0, 0);

  bool dragging = false;
  bool toscroll = false;
  double currentx = 0;
  double currenty = 0;
  double leap = 0;

  void updatepoints(double dx, double dy) {

    String? metricCode = context.read(currentMetricCodeProvider).metricCode;

    if (metricCode==null){
      return;
    }
    final int index = (max(0, min(dx, widget.constraints.maxWidth)) +
            _scrollController.offset.toDouble()) ~/
        offsetXvalue;
    //  print("index $index");
    if (index < _nbOfXvalues && 0 <= index) {
      //  print(dy);
      //  print(context.size?.height??0);

    GraphData graph =  context.read(graphDataProvider);

    double currentPos=max(upMargin,
        min((widget.constraints.maxHeight) - bottomMargin, dy))/ widget.constraints.maxHeight;


    if (context.read(eraseModeProvider).eraser ){
      if (graph.generator[metricCode]![index] != null &&  (currentPos-1+graph.generator[metricCode]![index]!).abs()<0.1) {
        graph.updateMetric(metricCode, index,null);
        if (graph.lastActivated==index){
          graph.updateLastActivated();
        }
      }

    } else {
      graph.updateMetric(metricCode, index,1-currentPos);
    }


    //  _streamer.add(_points);
    }
  }
  void doautoscroll(double dx, double dy) async {
    toscroll = true;
    currentx = dx;
    currenty = dy;

    //  setState(() {   _scrollController.animateTo(_scrollController.offset + 1000,duration: Duration(milliseconds: 3000), curve: Curves.linear); });
    //  return;

    if (!scrolling && //scroll existe pas déjà
        ((0 < _scrollController.offset &&
                leap < 0) || //on veut aller à gauche et il reste de la marge
            (_scrollController.offset < _nbOfXvalues * offsetXvalue &&
                leap > 0))) //on veut aller à droite et il reste de la marge
    {
      print("scroll crée!");
      scrolling = true;
      while (true) {
        if (dragging && toscroll) {
          if (leap < 0) {
            if (_scrollController.offset <= 0) {
              print("scroll mort 1");
              toscroll = false;
              break;
            } else {
              _scrollController.jumpTo(_scrollController.offset + leap);
              updatepoints(currentx, currenty);
            }
          } else {
            //       print("maj"+_scrollController.offset.toString());
            //si au bout
            if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent) {
              //si il reste de la place
              //      print(size.width);
              //      print(nbOfXvalues * offsetXvalues);

              if (size.width < _nbOfXvalues * offsetXvalue + 2 * leap) {
                size = Size(
                    widget.constraints.maxWidth +
                        _scrollController.offset +
                        2 * leap,
                    0);

                _scrollController.jumpTo(_scrollController.offset + leap);
                //         setState(() {   _scrollController.animateTo(_scrollController.offset + leap,duration: Duration(milliseconds: 100), curve: Curves.linear); });
                updatepoints(currentx, currenty);
              } else {
                //sinon stop scroll
                print("scroll mort 2");
                toscroll = false;
                break;
              }
            } else {
              //si pas au bout
              _scrollController.jumpTo(_scrollController.offset + leap);
              updatepoints(currentx, currenty);
            }
          }
        } else {
          print("scroll mort 3");
          toscroll = false;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 20), () {});
      }
      scrolling = false;
    } else {
      updatepoints(dx, dy);
    }
  }

  void updategraphpan(double dx, double dy) {
    //   print("updade");
if (context.read(currentMetricCodeProvider).metricCode==null) {
  return;
}
    double margin = dx + autoscrollMargin - widget.constraints.maxWidth;

    if (margin > 0) {
      leap = margintooffset(margin);

      doautoscroll(dx, dy);
    } else {
      margin = autoscrollMargin - dx;
      if (margin > 0) {
        leap = -margintooffset(margin);
        doautoscroll(dx, dy);
      } else {
        updatepoints(dx, dy);
        toscroll = false;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {


    return GestureDetector(
        // onTapDown: (details) {
        //   dragging = true;
        //   updategraphpan(details.localPosition.dx, details.localPosition.dy);
        // },
        // onTapUp: (details) {
        //   updategraphpan(details.localPosition.dx, details.localPosition.dy);
        //   dragging = false;
        // },
        onPanStart: (details) {
          dragging = true;
          updategraphpan(details.localPosition.dx, details.localPosition.dy);
        },
        onPanUpdate: (details) {
          updategraphpan(details.localPosition.dx, details.localPosition.dy);
        },
        onPanEnd: (details) {
          dragging = false;
        },
        child: Consumer(
            builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
              offsetXvalue=watch(offsetXvaluesProvider).value;

              if (_scrollController.hasClients) {
                double newvalue = min(_scrollController.offset,max(0,size.width-widget.constraints.maxWidth))+random.nextDouble()/10;
                _scrollController.jumpTo(newvalue);
                //    _scrollController.jumpTo(_scrollController.offset+0.1);
              }

              return Scrollbar(
            interactive: true,
            showTrackOnHover: true,
            controller: _scrollController,
            isAlwaysShown: true,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                dragStartBehavior: DragStartBehavior.down,
                physics: AlwaysScrollableScrollPhysics(),
                child:  Consumer(
                            builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
                              print('dans CONSUMER');
                              size = Size(max(widget.constraints.maxWidth,offsetXvalue * (context.read(graphDataProvider).lastActivated+1).toDouble()),0);
                              print(size);
                              print(_scrollController);
                             // _scrollController.jumpTo(_scrollController.offset+random.nextDouble()/10);


                              return CustomPaint(
                              size: size,
                              painter: Painter(
                                  graphData: watch(graphDataProvider).generator,
                      height: widget.constraints.maxHeight,
                      offsetXvalues: offsetXvalue,
                              paintSettings:watch(paintSettingsProvider),
                             metricId: watch(currentMetricCodeProvider).metricCode ,
                              color:Theme.of(context).accentColor));
                      },


                          )));


                          }));




  }


}



//color: Colors.black,
class Painter extends CustomPainter {
  static final stroke = Paint()
    //  ..color = Colors.grey
    ..style = PaintingStyle.stroke..strokeWidth = 2
    ..strokeCap = StrokeCap.round;

  final Map<String,List<double?>> graphData;
  final double height;
  final int offsetXvalues;

  final PaintSettings paintSettings;

  final String? metricId;
  final Color color;

  const Painter(
      {required this.graphData,
      required this.height,
      required this.offsetXvalues,
      required this.paintSettings,
      required this.metricId,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
   // if (graphData.isEmpty) return;
    // for (final point in points) canvas.drawCircle(point, radius, fill);
    TextStyle dateStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color:color );
    double textoffset = 0;
    double? point;
  int i;
    String metric;

    String toprint;

    if (metricId!=null){
      toprint= METRICS[metricId!]!.bsup;
      double textHeight=measureText(toprint, dateStyle).height;

      drawText(
          canvas,
          Offset(0, upMargin+  textHeight),
     toprint   ,
          dateStyle );

      drawText(
          canvas,
          Offset(0,size.height - bottomMargin-textHeight),
         METRICS[metricId!]!.binf   ,
          dateStyle );
    }

    if (paintSettings.bargraph) {

      for (metric in graphData.keys) {
        print("METRIC "+metric.toString());
        i=0;


        stroke.color=METRICS[metric]!.color;
        for (point in graphData[metric]!) {
          if (point != null) {
            canvas.drawLine(
                Offset(i * offsetXvalues.toDouble(), height * (1-point)),
                Offset((i * offsetXvalues + offsetXvalues).toDouble(),
                    height * (1-point)),
                stroke); //TODO;set color
          }
          i++;
        }

      }
    } else {
      textoffset = offsetXvalues.toDouble() / 2;
     List<double?> points;
      for (metric in graphData.keys) {
        print("METRIC2 "+metric.toString());
        points=graphData[metric]!;

        stroke.color=METRICS[metric]!.color;

        for (int i = 0; i < points.length - 1; i++) {
          if (points[i]!=null) {
            if (points[i + 1]!=null) {
              canvas.drawLine(
                  Offset(i * offsetXvalues + offsetXvalues / 2,
                      height * (1-points[i]!)),
                  Offset((i + 1) * offsetXvalues + offsetXvalues / 2,
                      height * (1-points[i + 1]!)),
                  stroke);
            }
            canvas.drawCircle(
                Offset(i * offsetXvalues + offsetXvalues / 2,
                    height * (1-points[i]!)),
                2,
                stroke);
          }
        }
        if (points.last !=null) {
          canvas.drawCircle(
              Offset(offsetXvalues * _nbOfXvalues - offsetXvalues / 2,
                  height * (1-points.last!)),
              2,
              stroke);
        }
      }
    }

    Duration minutes = const Duration(minutes: 0);

    //TODO afficher que autour de la fenêtre visible
    //TODO ajouter légende
    int nbTraits = deltaTimePix ~/ offsetXvalues;
    for (int i = 0;
        i <= offsetXvalues * _nbOfXvalues;
        i += offsetXvalues * nbTraits) {
      drawText(
          canvas,
          Offset(textoffset + i.toDouble(),
              (size.height + upMargin - bottomMargin) / 2),
          _printDuration(minutes),
          dateStyle );

      minutes += deltaTime * nbTraits;
      //   canvas.drawParagraph("d", Offset(size.height-10, i.toDouble()));
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) => true;
}


String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  // String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
}


final graphDataProvider=ChangeNotifierProvider.autoDispose<GraphData>(
      (context) => GraphData(),
);


class GraphData extends ChangeNotifier{
//late Map<int,List<double?>> data;
 Map<String,List<double?>> generator={};
  int lastActivated =0;

  useCustomData(Map<String,List<double?>>  newData){

    generator=newData;
   // generator.measures= {};

    updateLastActivated();
  }


  //dans le menu deroulant
  addMetric(String id){
    generator.putIfAbsent(id, () => List.generate(_nbOfXvalues, (i) => null));
}

 updateLastActivated(){
   lastActivated=0;
  for (String key in generator.keys.toSet()){
    for (int i=_nbOfXvalues-1;i>=0;--i){
      if (generator[key]![i]!=null){
        lastActivated=max(lastActivated,i);
      }
    }
}
   }

  //chips
  delMetric(String id){
    print("requested");
    print(id);
    generator.remove(id);
    print("generator.measures");
    print(generator);
    updateLastActivated();

    notifyListeners();
}
  //
  updateMetric(String id, int idx, double? value){
    generator[id]?[idx]=value;
    if (idx>lastActivated){
      lastActivated=idx;
    }
    notifyListeners();
}

  updateMetricid(List<dynamic> newMetrics) {
    print("newMetrics");
    print(newMetrics);
    print( generator.keys);

    for (String metricCode in generator.keys.toSet()) {
      if (!newMetrics.contains(metricCode)) {
        generator.remove(metricCode);
      }
    }

    for (Object? metricCode in newMetrics) {
      if (metricCode is String) {
        if (!generator.keys.contains(metricCode)) {
          addMetric(metricCode);
        }
      }
    }
    notifyListeners();
  }
}

final currentMetricCodeProvider=ChangeNotifierProvider.autoDispose<CurrentMetricCode>(
      (context) => CurrentMetricCode(),
);


class CurrentMetricCode extends ChangeNotifier {
  String? metricCode;

  void update({required String? metricCode}) {
    this.metricCode = metricCode;
    this.notifyListeners();
  }
}