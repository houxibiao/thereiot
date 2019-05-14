import 'package:thereiot/entity/sensorEntity.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:thereiot/entity/TimeSeriesDoubleValue.dart';
import 'package:thereiot/widget/showOptionsWidget.dart';

class TempSensorPage extends StatefulWidget {
  SensorEntity sensor;

  TempSensorPage({Key key, @required this.sensor}) : super(key: key);

  @override
  _TempSensorPageState createState() => _TempSensorPageState();
}

class _TempSensorPageState extends State<TempSensorPage> {
  SensorEntity sensor;
  DateTime _dashtime;
  Timer periodicTimer; //用于执行定时任务
  String _lastOption = "RealTime";
  var mapTemp = {'time': " ", "temp": 0};
  String newestValue = "";
  bool onlineState = false;

  List<TimeSeriesDoubleValue> pointList0 = new List<TimeSeriesDoubleValue>();
  List<TimeSeriesDoubleValue> tempList0 = new List<TimeSeriesDoubleValue>();

  List<charts.Series<TimeSeriesDoubleValue, DateTime>> graphData0 =
      new List<charts.Series<TimeSeriesDoubleValue, DateTime>>();

  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    _dashtime = DateTime.now().add(new Duration(hours: -8));
    getDataPoints(_dashtime.add(Duration(minutes: -5)));
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
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    onlineState? newestValue : "__",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ),
              ),
              ShowOptionsWidget(onChangedFunction, _lastOption),
              SizedBox(
                //放置第一个曲线图  以后考虑把曲线图分离出去
                height: 300,
                width: 300,
                child: Transform.scale(
                  child: charts.TimeSeriesChart(
                          graphData0, // datalist,
                          animate: false,
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
                  scale: 0.9,
                ),
              ),
                
             graphData0.isEmpty
                  ? Container(
                      child: Center(
                        child: Text("设备离线，请检测网络连接"),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("时间:${mapTemp['time']}"),
                       mapTemp['temp'].toString().length>5? Text("温度:${mapTemp['temp'].toString().substring(0,5)}"):
                        Text("温度:${mapTemp['temp']}"),
                      ],
                    ), 
              Center(
                child: RaisedButton(
                  child: Text("刷新"),
                  onPressed: (){
                    setState(() {
                      
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
    
  }

  getDataPoints(DateTime startTime,{String timeperiod}) async {
    //获取指定传感器从该页面打开前2分钟到现在的数据

    DateTime time; //用于解析json数据里面的时间
    String qStr;

   // DateTime startTime = dashtime.add(Duration(minutes: -5));
    String timeStr =
        "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}T${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')}Z";
    if(timeperiod==null){
      qStr = "SELECT fieldvalue0,fieldvalue1,fieldvalue2,sensorType FROM room34563 where time>='$timeStr' and \"sensorId\" = '${sensor.sensorId}' tz('Asia/Shanghai')";
    }else{
      qStr = "SELECT mean(\"fieldvalue0\") AS \"mean_value0\",mean(\"fieldvalue1\") AS \"mean_value1\",mean(\"fieldvalue2\") AS \"mean_value2\" FROM room34563 where time>='$timeStr' and \"sensorId\" = '${sensor.sensorId}' group by time($timeperiod) fill(0) tz('Asia/Shanghai')";
    }

    var url = "http://123.56.20.55:8086/query?u=hou&p=Hou13734&db=yuntest";
    var response = await http.post(url, body: {
      'q':
          qStr
    });

    if (response.statusCode == 200) {
      tempList0.clear();
      Map<String, dynamic> result = json.decode(response.body);

      try {

        for (dynamic data in result['results'][0]['series'][0]['values']) {
          print("传感器类型:temperature,更新时间: ${data[0]},温度:${data[1]}");
          time = DateTime.parse(data[0].replaceAll("T", " ").substring(0, 19));
          tempList0.add(TimeSeriesDoubleValue(
              new DateTime(time.year, time.month, time.day, time.hour,
                  time.minute, time.second),
              double.parse(data[1].toString())));
        }
        pointList0.clear();
        pointList0.addAll(tempList0);
           //获取最新值和在线状态
        if (timeperiod == null) {
          //该判断为真，表明现在是在获取实时数据
          newestValue = pointList0.last.value.toString();
          if (DateTime.now().difference(pointList0.last.time) >
              Duration(minutes: 5)) {
            onlineState = false;
          } else {
            onlineState = true;
          }
        }
        createGraphData();
      } on NoSuchMethodError {
        print("设备离线，获取不到数据");
        pointList0.clear();
        createGraphData();
      } catch (e) {
        print("error:$e");
      } finally {
        print("一次刷新结束");
      }
    } else {
      print("获取失败,错误码为:${response.statusCode}");
    }
  }

  createGraphData() {

    graphData0.clear();

    graphData0.add(new charts.Series<TimeSeriesDoubleValue, DateTime>(
      id: 'temperature',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesDoubleValue item, _) => item.time,
      measureFn: (TimeSeriesDoubleValue item, _) => item.value,
      data: pointList0,
    ));

    setState(() {
      //rebuild widget
    });
  }

  dynamicRefresh() async {
    if (periodicTimer == null) {
      periodicTimer = Timer.periodic(Duration(seconds: 15), (as) async {
        DateTime datetime = DateTime.now();
        print("获取新的数据,现在的时间是$datetime");
        await getDataPoints(_dashtime.add(Duration(minutes: -5)));
      });
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
        getDataPoints(startTime,timeperiod: "2m");
      } else if (value == "OneDay") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -1));
        getDataPoints(startTime,timeperiod: "1h");
      } else if (value == "OneWeek") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -7));
        getDataPoints(startTime,timeperiod: "1d");
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
        dynamicRefresh();
      } else if (value == "OneHour") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(hours: -1));
        getDataPoints(startTime,timeperiod: "2m");
      } else if (value == "OneDay") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -1));
        getDataPoints(startTime,timeperiod: "1h");
      } else if (value == "OneWeek") {
        print("获取$value 前的内容");
        startTime = _dashtime.add(Duration(days: -7));
        getDataPoints(startTime,timeperiod: "1d");
      } else {
        print("_lastOption is RealTime,now is $value");
      }
    }
  }
}
