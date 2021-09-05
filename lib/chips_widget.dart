import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'graph_widget.dart';
import 'metrictype.dart';



class ChipWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ChipDemoState();
}

class _ChipDemoState extends State<ChipWidget> {


  int? _choiceIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
     GraphData graphData = watch(graphDataProvider);
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: graphData.generator.length,
        itemBuilder: (BuildContext context, int index) {

          String key = graphData.generator.keys.elementAt(index);
          if (graphData.generator.length==1){
            _choiceIndex=0;
            context.read(currentMetricCodeProvider).metricCode=key;
          }
          return InputChip(
            selected: _choiceIndex == index,
            padding: EdgeInsets.all(2.0),
            label: Text(METRICS[key]!.name),
            backgroundColor: METRICS[key]!.color,
            selectedColor: METRICS[key]!.color,



            onSelected: (bool selected) {
              setState(() {
                _choiceIndex = selected ? index : null;
                context.read(currentMetricCodeProvider).update(metricCode: selected?key:null);
              });
            },
            onDeleted: () {
              context.read(graphDataProvider).delMetric(key);
              if (index==_choiceIndex){
    setState(() {
      _choiceIndex = null;
    });
                context.read(currentMetricCodeProvider).update(metricCode: null);
              }
            },
          );
        },
      );
    });
  }
}

class CompanyWidget {
  const CompanyWidget(this.name);
  final String name;
}