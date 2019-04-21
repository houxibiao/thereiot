import 'dart:core';

import 'package:thereiot/entity/sensorEntity.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DashBoardPage extends StatefulWidget {
  SensorEntity sensor;
  DashBoardPage({Key key, @required this.sensor}) : super(key: key);

  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  SensorEntity sensor;

  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    String time_noformat = "2019-04-14T15:39:49.885208141Z";
    var time =
        DateTime.parse(time_noformat.replaceAll("T", " ").substring(0, 19));
    print(time.toIso8601String());
  }

  static List<TimeSeriesValue> data = [
    new TimeSeriesValue(new DateTime(2019, 3, 20, 13, 30, 30),
        22.1), //new TimeSeriesValue(new DateTime(2019,3,20), 22.1),
    new TimeSeriesValue(new DateTime(2019, 3, 20, 13, 30, 40),
        22.5), //new TimeSeriesValue(new DateTime(2019,3,21), 22.5),
    new TimeSeriesValue(new DateTime(2019, 3, 20, 13, 30, 50),
        22.2), //new TimeSeriesValue(new DateTime(2019,3,21), 22.5),
    new TimeSeriesValue(new DateTime(2019, 3, 20, 13, 31, 0),
        22.0), //new TimeSeriesValue(new DateTime(2019,3,21), 22.5),
    new TimeSeriesValue(new DateTime(2019, 3, 20, 13, 31, 10),
        22.2) //new TimeSeriesValue(new DateTime(2019,3,21), 22.5),
  ];

  List<charts.Series<TimeSeriesValue, DateTime>> seriesList = [
    new charts.Series<TimeSeriesValue, DateTime>(
      id: 'temp',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesValue item, _) => item.time,
      measureFn: (TimeSeriesValue item, _) => item.value,
      data: data,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[

          Padding(
            padding: EdgeInsets.fromLTRB(10, 50, 10, 30),
            child: Center(
              child: Text("${sensor.sensorName}"),
            ),
          ),

            SizedBox(
              height: 300,
              width: double.infinity,
              child: Transform.scale(
                child: charts.TimeSeriesChart(
                  seriesList,
                  animate: true,
                  dateTimeFactory: charts.LocalDateTimeFactory(),
                  domainAxis: charts.DateTimeAxisSpec(
                      tickProviderSpec:
                          charts.DateTimeEndPointsTickProviderSpec()),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                      tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                          zeroBound: false,
                          dataIsInWholeNumbers: false,
                          desiredTickCount: 5)),
                  behaviors: [
                    new charts.RangeAnnotation(data.map((item) {
                      return charts.LineAnnotationSegment(
                          item.time, charts.RangeAnnotationAxisType.domain,
                          startLabel: '${item.time.minute}:${item.time.second}',
                          labelPosition: charts.AnnotationLabelPosition.inside);
                    }).toList()),
                  ],
                ),
                scale: 0.85,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSeriesValue {
  final DateTime time;
  final double value;
  TimeSeriesValue(this.time, this.value);
}
