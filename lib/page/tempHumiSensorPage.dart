import 'package:thereiot/entity/sensorEntity.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:thereiot/widget/showOptionsWidget.dart';
import 'package:thereiot/entity/TimeSeriesValue.dart';

class TempHumiSensorPage extends StatefulWidget {
  SensorEntity sensor;

  TempHumiSensorPage({Key key, @required this.sensor}) : super(key: key);

  @override
  _TempHumiSensorPageState createState() => _TempHumiSensorPageState();
}

class _TempHumiSensorPageState extends State<TempHumiSensorPage> {
  SensorEntity sensor;
  DateTime _dashtime;
  String _lastOption = "RealTime";
  Timer periodicTimer; //用于执行定时任务
  String newestValue = "";
  bool onlineState = false;
  List<String> fieldName = new List<String>();
  List<int> precision = new List<int>();

  var mapTemp = {'time': " ", "temp": 0};
  var mapHumi = {'time': " ", "humi": 0};

  List<List<TimeSeriesValue<double>>> pointList =
      new List<List<TimeSeriesValue<double>>>();
  List<List<charts.Series<TimeSeriesValue<double>, DateTime>>> graphDataList =
      new List<List<charts.Series<TimeSeriesValue<double>, DateTime>>>();

  int fieldnum;

  @override
  void initState() {
    super.initState();

    _dashtime = DateTime.now().add(new Duration(hours: -8));

    sensor = widget.sensor;
    fieldnum = sensor.fieldNum;

    for (int i = 0; i < fieldnum; i++) {
      pointList.add(new List<TimeSeriesValue<double>>());
      graphDataList
          .add(new List<charts.Series<TimeSeriesValue<double>, DateTime>>());
      precision.add(int.parse(sensor.valuePrecison.split(",")[i]));
    }

    getDataPoints(_dashtime.add(new Duration(minutes: -5)));
    dynamicRefresh();
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
              Padding(
                padding: EdgeInsets.fromLTRB(10, 25, 10, 20),
                child: Center(
                  child: Text(
                    "${sensor.sensorName}",
                    style: TextStyle(fontSize: 30, color: Colors.white70),
                  ),
                ),
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
              ShowOptionsWidget(onChangedFunction, _lastOption),
              SizedBox(
                //放置第一个曲线图  以后考虑把曲线图分离出去
                height: 300,
                width: double.infinity,
                child: Transform.scale(
                  child: charts.TimeSeriesChart(
                    graphDataList[0], // datalist,
                    animate: false,
                    dateTimeFactory: charts.LocalDateTimeFactory(),
                    defaultRenderer: charts.LineRendererConfig(
                        includeArea: true, stacked: true),
                    domainAxis: charts.DateTimeAxisSpec(
                        tickProviderSpec:
                            charts.DateTimeEndPointsTickProviderSpec()),
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                      tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                          zeroBound: true,
                          dataIsInWholeNumbers: false,
                          desiredTickCount: 5),
                    ),
                    selectionModels: [
                      new charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: _onSelectedTempChanged,
                      ),
                    ],
                    behaviors: [
                      new charts.ChartTitle(
                        '温度趋势图',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea,
                      ),
                    ],
                  ),
                  scale: 0.85,
                ),
              ),
              pointList[0].isEmpty
                  ? SizedBox(
                      height: 20,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("时间:${mapTemp['time']}"),
                        Text("温度:${mapTemp['temp']}"),
                      ],
                    ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Transform.scale(
                  child: charts.TimeSeriesChart(
                    graphDataList[1],
                    animate: false,
                    dateTimeFactory: charts.LocalDateTimeFactory(),
                    defaultRenderer: charts.LineRendererConfig(
                        includeArea: true, stacked: true),
                    domainAxis: charts.DateTimeAxisSpec(
                        tickProviderSpec:
                            charts.DateTimeEndPointsTickProviderSpec()),
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                      tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                          zeroBound: true,
                          dataIsInWholeNumbers: false,
                          desiredTickCount: 5),
                    ),
                    selectionModels: [
                      new charts.SelectionModelConfig(
                        type: charts.SelectionModelType.info,
                        changedListener: _onSelectedHumiChanged,
                      ),
                    ],
                    behaviors: [
                      new charts.ChartTitle(
                        '湿度趋势图',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea,
                      ),
                    ],
                  ),
                  scale: 0.85,
                ),
              ),
              pointList[1].isEmpty
                  ? SizedBox(
                      height: 20,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("时间:${mapHumi['time']}"),
                        Text("湿度:${mapHumi['humi']}%")
                      ],
                    ),
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

  getDataPoints(DateTime startTime, {String timeperiod}) async {
    DateTime time; //用于解析json数据里面的时间
    String qStr; //查询语句
    String dataTempStr;
    String timeStr =
        "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}T${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')}Z";
    if (timeperiod == null) {
      qStr =
          "SELECT fieldvalue0,fieldvalue1,fieldvalue2,sensorType FROM room34563 where time>='$timeStr' and \"sensorId\" = '${sensor.sensorId}' tz('Asia/Shanghai')";
    } else {
      qStr =
          "SELECT mean(\"fieldvalue0\") AS \"mean_value0\",mean(\"fieldvalue1\") AS \"mean_value1\",mean(\"fieldvalue2\") AS \"mean_value2\" FROM room34563 where time>='$timeStr' and \"sensorId\" = '${sensor.sensorId}' group by time($timeperiod) fill(0) tz('Asia/Shanghai')";
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

          for (dynamic data in result['results'][0]['series'][0]['values']) {
            time =
                DateTime.parse(data[0].replaceAll("T", " ").substring(0, 19));

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
        }

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
        print("undefined error: $e");
      } finally {
        print("一次刷新结束");
      }
    } else {
      print("获取失败,错误码为:${response.statusCode}");
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
    if (periodicTimer == null) {
      print("建立定时器");
      periodicTimer = Timer.periodic(Duration(seconds: 15), (as) async {
        DateTime datetime = DateTime.now();
        print("获取新的数据,现在的时间是$datetime");
        await getDataPoints(_dashtime.add(Duration(minutes: -5)));
      });
    } else {
      print("计数器已存在");
    }
  }

  _onSelectedTempChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      mapTemp['time'] = selectedDatum.first.datum.time.toString();
      mapTemp['temp'] = selectedDatum.first.datum.value;
    }

    setState(() {});
  }

  _onSelectedHumiChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    if (selectedDatum.isNotEmpty) {
      mapHumi['time'] = selectedDatum.first.datum.time.toString();
      mapHumi['humi'] = selectedDatum.first.datum.value;
    }
    setState(() {});
  }

  onChangedFunction(String value) {
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
}
