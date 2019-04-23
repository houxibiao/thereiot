import 'dart:core';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

class DashBoardPage extends StatefulWidget {
  SensorEntity sensor;
  DashBoardPage({Key key, @required this.sensor}) : super(key: key);

  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  SensorEntity sensor;
  String _dashtimeStr;
  Timer periodicTimer; //用于执行定时任务
  List<TimeSeriesValue> fieldvalue0list = new List<TimeSeriesValue>();
  List<TimeSeriesValue> fieldvalue1list = new List<TimeSeriesValue>();

  List<charts.Series<TimeSeriesValue, DateTime>> datalist =
      new List<charts.Series<TimeSeriesValue, DateTime>>();

  List<charts.Series<TimeSeriesValue, DateTime>> datalist2 =
      new List<charts.Series<TimeSeriesValue, DateTime>>();

  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    _getData();
    _dynamicRefresh();
    //_getData();
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            "assets/background.jpg",
            fit: BoxFit.contain,
          ),
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 50, 10, 30),
                child: Center(
                  child: Text("${sensor.sensorName}"),
                ),
              ),
              SizedBox(//放置第一个曲线图
                height: 300,
                width: double.infinity,
                child: Transform.scale(
                  child: fieldvalue0list.isEmpty
                      ? Container(
                          child: Center(
                            child: Loading(
                              indicator: BallPulseIndicator(),
                              size: 100.0,
                            ),
                          ),
                        )
                      : charts.TimeSeriesChart(
                          datalist,
                          animate: true,
                          dateTimeFactory: charts.LocalDateTimeFactory(),
                          defaultRenderer: charts.LineRendererConfig(
                              includeArea: true, stacked: true),
                          domainAxis: charts.DateTimeAxisSpec(
                              tickProviderSpec:
                                  charts.DateTimeEndPointsTickProviderSpec()),
                          primaryMeasureAxis: new charts.NumericAxisSpec(
                            tickProviderSpec:
                                new charts.BasicNumericTickProviderSpec(
                                    zeroBound: false,
                                    dataIsInWholeNumbers: false,
                                    desiredTickCount: 5),
                          ),
                        ),
                  scale: 0.85,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Transform.scale(
                  child: fieldvalue1list.isEmpty
                      ? Container(
                          child: Center(
                            child: Loading(
                              indicator: BallPulseIndicator(),
                              size: 100.0,
                            ),
                          ),
                        )
                      : charts.TimeSeriesChart(
                          datalist2,
                          animate: true,
                          dateTimeFactory: charts.LocalDateTimeFactory(),
                          defaultRenderer: charts.LineRendererConfig(
                              includeArea: true, stacked: true),
                          domainAxis: charts.DateTimeAxisSpec(
                              tickProviderSpec:
                                  charts.DateTimeEndPointsTickProviderSpec()),
                          primaryMeasureAxis: new charts.NumericAxisSpec(
                            tickProviderSpec:
                                new charts.BasicNumericTickProviderSpec(
                                    zeroBound: true,
                                    dataIsInWholeNumbers: false,
                                    desiredTickCount: 5),
                          ),
                        ),
                  scale: 0.85,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _getData() async {
    //获取指定传感器从该页面打开前2分钟到现在的数据
    DateTime time; //用于解析json数据里面的时间
    DateTime _dashtime =
        DateTime.now().add(new Duration(minutes: -2, hours: -8));
    _dashtimeStr =
        "${_dashtime.year}-${_dashtime.month.toString().padLeft(2, '0')}-${_dashtime.day.toString().padLeft(2, '0')}T${_dashtime.hour.toString().padLeft(2, '0')}:${_dashtime.minute.toString().padLeft(2, '0')}:${_dashtime.second.toString().padLeft(2, '0')}Z";

    var url = "http://123.56.20.55:8086/query?u=hou&p=Hou13734&db=yuntest";
    var response = await http.post(url, body: {
      'q':
          "SELECT fieldvalue0,fieldvalue1,fieldvalue2,sensorType FROM room34563 where time>='$_dashtimeStr' and \"sensorId\" = '${sensor.sensorId}' tz('Asia/Shanghai')"
    });

    if (response.statusCode == 200) {
      fieldvalue0list.clear();
      fieldvalue1list.clear(); //清空之前的列表

      Map<String, dynamic> result = json.decode(response.body);

      for (dynamic data in result['results'][0]['series'][0]['values']) {
        if (data[4] == "temperature") {
          print("传感器类型:temperature,更新时间: ${data[0]},温度: ${data[1]}");
        } else if (data[4] == 'temp_humi') {
          print(
              "传感器类型:temp_humi,更新时间: ${data[0]},温度:${data[1]},湿度:${data[2]}%");
          time = DateTime.parse(data[0].replaceAll("T", " ").substring(0, 19));
          fieldvalue0list.add(TimeSeriesValue(
              new DateTime(time.year, time.month, time.day, time.hour,
                  time.minute, time.second),
              data[1]));
          fieldvalue1list.add(TimeSeriesValue(
              new DateTime(time.year, time.month, time.day, time.hour,
                  time.minute, time.second),
              data[2]));
        } else if (data[4] == 'gyroscope') {
          print(
              "传感器类型:mpu6050,更新时间: ${data[0]},x轴:${data[1]},y轴:${data[2]},z轴:${data[3]}");
        } else {
          print(
              "传感器类型:${data[4]}(未知类型),更新时间: ${data[0]},fieldvalue0:${data[1]},fieldvalue1:${data[2]},fieldvalue2:${data[3]}");
        }
      }
      _createDataSeries();
    } else {
      print("获取失败,错误码为:${response.statusCode}");
    }
  }

  _createDataSeries() {
    datalist.clear();
    datalist2.clear();
    datalist.add(new charts.Series<TimeSeriesValue, DateTime>(
      id: 'temp',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesValue item, _) => item.time,
      measureFn: (TimeSeriesValue item, _) => item.value,
      data: fieldvalue0list,
    ));
    datalist2.add(new charts.Series<TimeSeriesValue, DateTime>(
      id: 'humi',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      domainFn: (TimeSeriesValue item, _) => item.time,
      measureFn: (TimeSeriesValue item, _) => item.value,
      data: fieldvalue1list,
    ));
    setState(() {});
  }

  _dynamicRefresh() async {
    if (periodicTimer == null) {
      periodicTimer = Timer.periodic(Duration(seconds: 15), (as) async {
        DateTime datetime = DateTime.now();
        print("获取新的数据,现在的时间是$datetime");
        await _getData();
      });
    }
  }
}

class TimeSeriesValue {
  final DateTime time;
  final int value;
  TimeSeriesValue(this.time, this.value);
}
