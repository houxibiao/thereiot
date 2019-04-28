import 'package:thereiot/entity/sensorEntity.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:thereiot/entity/TimeSeriesDoubleValue.dart';

class GyroscopeSensorPage extends StatefulWidget {
  SensorEntity sensor;

  GyroscopeSensorPage({Key key, @required this.sensor}) : super(key: key);

  @override
  _GyroscopeSensorPageState createState() => _GyroscopeSensorPageState();
}

class _GyroscopeSensorPageState extends State<GyroscopeSensorPage> {
  SensorEntity sensor;
  String _dashtimeStr;
  Timer periodicTimer; //用于执行定时任务

  DateTime _selectedPointTime; //用于指示选择的时刻

  Map<String, num> _measure;

  List<TimeSeriesDoubleValue> pointList0 = new List<TimeSeriesDoubleValue>();
  List<TimeSeriesDoubleValue> pointList1 = new List<TimeSeriesDoubleValue>();
  List<TimeSeriesDoubleValue> pointList2 = new List<TimeSeriesDoubleValue>();

  List<charts.Series<TimeSeriesDoubleValue, DateTime>> graphData0 =
      new List<charts.Series<TimeSeriesDoubleValue, DateTime>>();

  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    getDataPoints();
    dynamicRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    periodicTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final selectShowChildren = <Widget>[];
    if (_selectedPointTime != null) {
      selectShowChildren.add(Text("时间:$_selectedPointTime"));
    }

    _measure?.forEach((String name, num value) {
      selectShowChildren.add(new Text('$name : $value'));
    });

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
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    pointList0.isEmpty
                        ? "__"
                        : "${pointList0.last.value} ${pointList1.last.value} ${pointList2.last.value}",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ),
              ),
              SizedBox(
                //放置第一个曲线图  以后考虑把曲线图分离出去
                height: 300,
                width: double.infinity,
                child: Transform.scale(
                  child: pointList0.isEmpty
                      ? Container(
                          child: Center(
                            child: Text(
                              "离线",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      : charts.TimeSeriesChart(
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
                                    zeroBound: false,
                                    dataIsInWholeNumbers: false,
                                    desiredTickCount: 5),
                          ),
                          selectionModels: [
                            new charts.SelectionModelConfig(
                              type: charts.SelectionModelType.info,
                              changedListener: _onSelectedChanged,
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
              graphData0.isEmpty
                  ? Container(
                      child: Center(
                        child: Text("设备离线，请检测网络连接"),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: selectShowChildren),
            ],
          ),
        ],
      ),
    );
  }

  getDataPoints() async {
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
      pointList0.clear();
      pointList1.clear();
      pointList2.clear();

      Map<String, dynamic> result = json.decode(response.body);

      try {
        for (dynamic data in result['results'][0]['series'][0]['values']) {
          print(
              "传感器类型:gyroscope,更新时间: ${data[0]},x轴:${data[1]},y轴:${data[2]},z轴:${data[3]}");
          time = DateTime.parse(data[0].replaceAll("T", " ").substring(0, 19));
          pointList0.add(TimeSeriesDoubleValue(
              new DateTime(time.year, time.month, time.day, time.hour,
                  time.minute, time.second),
             double.parse(data[1].toString())));
          pointList1.add(TimeSeriesDoubleValue(
              new DateTime(time.year, time.month, time.day, time.hour,
                  time.minute, time.second),
              double.parse(data[2].toString())));
          pointList2.add(TimeSeriesDoubleValue(
              new DateTime(time.year, time.month, time.day, time.hour,
                  time.minute, time.second),
              double.parse(data[3].toString())));
        }
        createGraphData();
      } on NoSuchMethodError {
        print("设备离线，获取不到数据");
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
      id: 'x_axis',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesDoubleValue item, _) => item.time,
      measureFn: (TimeSeriesDoubleValue item, _) => item.value,
      data: pointList0,
    ));

    graphData0.add(new charts.Series<TimeSeriesDoubleValue, DateTime>(
      id: 'y_aix',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (TimeSeriesDoubleValue item, _) => item.time,
      measureFn: (TimeSeriesDoubleValue item, _) => item.value,
      data: pointList1,
    ));

    graphData0.add(new charts.Series<TimeSeriesDoubleValue, DateTime>(
      id: 'z_axis',
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      domainFn: (TimeSeriesDoubleValue item, _) => item.time,
      measureFn: (TimeSeriesDoubleValue item, _) => item.value,
      data: pointList2,
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
        await getDataPoints();
      });
    }
  }

    _onSelectedChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    DateTime time;
    final measures = <String, num>{};
    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.time;

      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum.value;
      });
    }

    setState(() {
      _selectedPointTime = time;
      _measure = measures;
    });
  }


}
