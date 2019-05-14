import 'package:thereiot/entity/sensorEntity.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:thereiot/widget/showOptionsWidget.dart';

import 'package:thereiot/entity/TimeSeriesValue.dart';

class OtherSensorManage extends StatefulWidget {
  SensorEntity sensor;
  OtherSensorManage({Key key, @required this.sensor}) : super(key: key);

  @override
  _OtherSensorManageState createState() => _OtherSensorManageState();
}

class _OtherSensorManageState extends State<OtherSensorManage> {
  SensorEntity sensor;
  DateTime _dashtime;
  String _lastOption = "RealTime";
  Timer periodicTimer; //用于执行定时任务
  String queryStrRealTime = ""; //用来拼凑实时查询语句中间的部分
  String queryStrMeanMode = "";
  String newestValue = "";
  bool onlineState = false;

  int fieldnum;
  List<String> fieldName = new List<String>();
  List<int> precision = new List<int>();

  List<List<TimeSeriesValue<double>>> pointList =
      new List<List<TimeSeriesValue<double>>>();
  List<List<charts.Series<TimeSeriesValue<double>, DateTime>>> graphDataList =
      new List<List<charts.Series<TimeSeriesValue<double>, DateTime>>>();

  @override
  void initState() {
    super.initState();

    _dashtime = DateTime.now().add(new Duration(hours: -8));

    sensor = widget.sensor;
    fieldnum = sensor.fieldNum;
    fieldName.addAll(sensor.fieldNames.split(","));
    for (int i = 0; i < fieldnum; i++) {
      pointList.add(new List<TimeSeriesValue<double>>());
      graphDataList
          .add(new List<charts.Series<TimeSeriesValue<double>, DateTime>>());
      queryStrRealTime += "fieldvalue$i,";
      queryStrMeanMode += "mean(\"fieldvalue$i\") AS \"mean_value$i\",";
      precision.add(int.parse(sensor.valuePrecison.split(",")[i]));
    }
    queryStrMeanMode =
        queryStrMeanMode.substring(0, queryStrMeanMode.length - 1);

    getDataPoints(_dashtime.add(Duration(minutes: -5)));
    dynamicRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  getDataPoints(DateTime startTime, {String timeperiod}) async {
    //获取指定传感器从该页面打开前2分钟到现在的数据
    DateTime time; //用于解析json数据里面的时间
    String qStr;
    String dataTempStr;
    String timeStr =
        "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}T${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')}Z";
    if (timeperiod == null) {
      qStr =
          "SELECT $queryStrRealTime sensorType FROM room34563 where time>='$timeStr' and \"sensorId\" = '${sensor.sensorId}' tz('Asia/Shanghai')";
    } else {
      qStr =
          "SELECT $queryStrMeanMode FROM room34563 where time>='$timeStr' and \"sensorId\" = '${sensor.sensorId}' group by time($timeperiod) fill(0) tz('Asia/Shanghai')";
    }
    var url = "http://123.56.20.55:8086/query?u=hou&p=Hou13734&db=yuntest";
    var response = await http.post(url, body: {'q': qStr});
    if (response.statusCode == 200) {
      for (int i = 0; i < fieldnum; i++) {
        pointList[i].clear();
      }

      Map<String, dynamic> result = json.decode(response.body);

      try {
        for (dynamic data in result['results'][0]['series'][0]['values']) {
          time = DateTime.parse(data[0].replaceAll("T", " ").substring(0, 19));

          for (int i = 0; i < fieldnum; i++) {
            if (data[i + 1].toString().contains(".")) {
              if (precision[i] != 0) {
                dataTempStr = data[i + 1].toString().split(".")[0] +
                    "." +
                    data[i + 1]
                        .toString()
                        .split(".")[1]
                        .padRight(precision[i], "0")
                        .substring(0, precision[i] - 1);
              } else {
                dataTempStr = data[i + 1].toString().split(".")[0];
              }

              pointList[i].add(TimeSeriesValue<double>(
                  new DateTime(time.year, time.month, time.day, time.hour,
                      time.minute, time.second),
                  double.parse(dataTempStr)));
            } else {
              //接受到的数恰好是整数
              pointList[i].add(TimeSeriesValue<double>(
                  new DateTime(time.year, time.month, time.day, time.hour,
                      time.minute, time.second),
                  double.parse(data[i + 1].toString())));
            }
          }
        }

        //获取最新值和在线状态
        if (timeperiod == null) {
          //该判断为真，表明现在是在获取实时数据
          newestValue = "";
          for (int i = 0; i < fieldnum; i++) {
            newestValue += "${pointList[i].last.value} ";
          }
          if (DateTime.now().difference(pointList[0].last.time) >
              Duration(minutes: 5)) {
            onlineState = false;
          } else {
            onlineState = true;
          }
        }

        createGraphData();
      } on NoSuchMethodError {
        print("设备离线，获取不到数据");
        setState(() {
          onlineState = false;
          newestValue = "";
        });
      } catch (e) {
        print("error:$e");
      } finally {
        print("一次刷新结束");
      }
    } else {
      print("获取失败,错误码为:${response.statusCode},错误信息:${response.body}");
    }
  }

  createGraphData() {
    for (int i = 0; i < fieldnum; i++) {
      graphDataList[i].clear();

      graphDataList[i].add(new charts.Series<TimeSeriesValue<double>, DateTime>(
        id: 'value$i',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesValue<double> item, _) => item.time,
        measureFn: (TimeSeriesValue<double> item, _) => item.value,
        data: pointList[i],
      ));
    }

    setState(() {
      //rebuild widget
    });
  }

  dynamicRefresh() async {
    //控制动态刷新，默认只在实时显示模式下才支持动态刷新
    if (periodicTimer == null) {
      periodicTimer = Timer.periodic(Duration(seconds: 15), (as) async {
        DateTime datetime = DateTime.now();
        print("获取新的数据,现在的时间是$datetime");
        await getDataPoints(_dashtime.add(Duration(minutes: -5)));
      });
    }
  }

  onShowModeChanged(String value) {
    print("the value is $value");
    DateTime startTime;
    if (_lastOption == "RealTime") {
      periodicTimer.cancel();
      setState(() {
        _lastOption = value;
      });
      if (value == "OneHour") {
        startTime = _dashtime.add(Duration(hours: -1));
        print("获取$value 前的内容");
        getDataPoints(startTime, timeperiod: "2m");
      } else if (value == "OneDay") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -1));
        getDataPoints(startTime, timeperiod: "1h");
      } else if (value == "OneWeek") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -7));
        getDataPoints(startTime, timeperiod: "1d");
      } else {
        print("_lastOption is RealTime,now is $value");
      }
    } else {
      //上次选择的不是实时动态，不需要取消定时器，如果这次选择的是RealTime,需要重启计时器
      setState(() {
        _lastOption = value;
      });
      if (value == "RealTime") {
        print("获取$value 前的内容");
        getDataPoints(_dashtime.add(Duration(minutes: -5)));
        // dynamicRefresh();
        periodicTimer = Timer.periodic(Duration(seconds: 15), (as) async {
          DateTime datetime = DateTime.now();
          print("获取新的数据,现在的时间是$datetime");
          await getDataPoints(_dashtime.add(Duration(minutes: -5)));
        });
      } else if (value == "OneHour") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(hours: -1));
        getDataPoints(startTime, timeperiod: "2m");
      } else if (value == "OneDay") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -1));
        getDataPoints(startTime, timeperiod: "1h");
      } else if (value == "OneWeek") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -7));
        getDataPoints(startTime, timeperiod: "6h");
      } else {
        print("_lastOption is RealTime,now is $value");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> graph = new List<Widget>();
    for (int i = 0; i < fieldnum; i++) {
      graph.add(SizedBox(
        height: 300,
        width: double.infinity,
        child: Transform.scale(
          child: charts.TimeSeriesChart(
            graphDataList[i], // datalist,
            animate: false,
            dateTimeFactory: charts.LocalDateTimeFactory(),
            defaultRenderer:
                charts.LineRendererConfig(includeArea: true, stacked: true),
            domainAxis: charts.DateTimeAxisSpec(
                tickProviderSpec: charts.DateTimeEndPointsTickProviderSpec()),
            primaryMeasureAxis: new charts.NumericAxisSpec(
              tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                  zeroBound: false,
                  dataIsInWholeNumbers: false,
                  desiredTickCount: 5),
            ),
            behaviors: [
              new charts.ChartTitle(
                '${fieldName[i]}数据趋势图',
                behaviorPosition: charts.BehaviorPosition.bottom,
                titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea,
              ),
            ],
          ),
          scale: 0.85,
        ),
      ));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              "assets/background.jpg",
              fit: BoxFit.contain,
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Center(
                child: Text(sensor.sensorName,
                    style: new TextStyle(fontSize: 30, color: Colors.white54)),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("状态:"),
                  onlineState == true
                      ? Icon(
                          Icons.import_export,
                          color: Colors.green,
                        )
                      : Icon(
                          Icons.import_export,
                          color: Colors.black45,
                        )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  //显示最新的值
                  newestValue,
                  style: TextStyle(fontSize: 20, color: Colors.white54),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ShowOptionsWidget(onShowModeChanged, _lastOption),
              Column(children: graph),
              SizedBox(height: 50,)
            ],
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Center(
                child: Center(
              child: RaisedButton(
                child: Text("刷新"),
                onPressed: () {
                  setState(() {});
                },
              ),
            )),
          ),
        ],
      ),
    );
  }
}
