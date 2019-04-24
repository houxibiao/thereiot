import 'package:flutter/material.dart';
import 'package:thereiot/tool/database.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:thereiot/widget/sensorCardWidget.dart';
import 'package:thereiot/page/sensorManagePage.dart';
import 'tempHumiSensorPage.dart';
import 'tempSensorPage.dart';
import 'gyroscopeSensorPage.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SensorEntity> sensorlist = new List<SensorEntity>();

  @override
  void initState() {
    super.initState();
    _loadSensorList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("There IOT"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new SensorManagePage()));
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        backgroundColor: Color.fromRGBO(227, 242, 253, 40),
        onRefresh: _refreshSensorList,
        child: sensorlist.isEmpty
            ? ListView(
                children: <Widget>[
                  Center(
                    child: Text(
                      "空",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Center(
                    child: Text("请添加传感器"),
                  ),
                ],
              )
            : GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(10),
                childAspectRatio: 8.0 / 11.0,
                children: sensorlist.map((item) {
                  return GestureDetector(
                    child: SensorCardWidget(item),
                    onTap: () {
                      if (item.sensorType == "temp_humi") {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new TempHumiSensorPage(sensor: item),
                          ),
                        );
                      } else if (item.sensorType == "temperature") {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new TempSensorPage(sensor: item),
                          ),
                        );
                      } else if (item.sensorType == "gyroscope") {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new GyroscopeSensorPage(sensor: item),
                          ),
                        );
                      } else {
                        print("未添加类型");
                      }
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }

  _loadSensorList() async {
    DatabaseTool database = new DatabaseTool();
    List templist = await database.getSensorList();
    sensorlist.clear();
    templist.forEach((item) => sensorlist.add(SensorEntity.fromMap(item)));
    if (templist.isEmpty) {
      print("传感器列表为空");
    }
    setState(() {});
    await database.close();
  }

  Future<void> _refreshSensorList() async {
    await _loadSensorList();
  }
}
