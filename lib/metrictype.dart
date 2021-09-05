import 'package:flutter/material.dart';

class MetricInfo {
  late final String name;
  late final String metricCode;
  late final MaterialColor color;
  late final String binf;
  late final String bsup;
  MetricInfo(
      {required this.name,
      required this.metricCode,
      required this.color,
      required this.binf,
      required this.bsup});
}

Map<String, MetricInfo> METRICS = {
  'valence': MetricInfo(
      name: "Valence",
      metricCode: 'valence',
      color: Colors.lightGreen,
      binf: "Low",
      bsup: "High"),

  'acousticness': MetricInfo(
      name: "Acousticness",
      metricCode: 'acousticness',
      color: Colors.yellow,
      binf: "Low",
      bsup: "High"),

  'danceability': MetricInfo(
      name: "Danceability",
      metricCode: 'danceability',
      color: Colors.blue,
      binf: "Low",
      bsup: "High"),

  'instrumentalness': MetricInfo(
      name: "Instrumentalness",
      metricCode: 'instrumentalness',
      color: Colors.orange,
      binf: "Low",
      bsup: "High"),

  'liveness': MetricInfo(
      name: "Liveness",
      metricCode: 'liveness',
      color: Colors.green,
      binf: "Low",
      bsup: "High"),

//   'loudness': MetricInfo(name: "Loudness",
  //      metricCode: 'loudness', color: Colors.pink,binf: "Low" ,bsup: "High"),

  'speechiness': MetricInfo(
      name: "Speechiness",
      metricCode: 'speechiness',
      color: Colors.purple,
      binf: "Low",
      bsup: "High"),

  //  'popularity': MetricInfo(name: "Popularity",
  //      metricCode: 'popularity', color: Colors.red,binf: "Low" ,bsup: "High"),

  'energy': MetricInfo(
      name: "Energy",
      metricCode: 'energy',
      color: Colors.grey,
      binf: "Negative",
      bsup: "Positive"),

//   'tempo':MetricInfo(name: 'Tempo',
//       metricCode: 'tempo', color: Colors.brown,binf: "<50",bsup: ">180"),
};

class Measure {
  late MetricInfo metric;
  late List<double?> value;

  Map<String, dynamic> toMap() {
    return {
      'metricId': this.metric.metricCode,
      'value': this.value,
    };
  }

  Measure({required this.metric, required this.value});
}
