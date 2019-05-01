import 'package:flutter/material.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:thereiot/widget/sensorCardWidget.dart';
import 'package:thereiot/page/sensorManagePage.dart';
import 'tempHumiSensorPage.dart';
import 'tempSensorPage.dart';
import 'gyroscopeSensorPage.dart';
import 'enumSensorPage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thereiot/tool/sensorManageTool.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SensorEntity> sensorlist = new List<SensorEntity>();
  RefreshController _refreshController = new RefreshController();

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
      body: SmartRefresher(
        // backgroundColor: Color.fromRGBO(227, 242, 253, 40),
        controller: _refreshController,
        onRefresh: _refreshSensorList,
        enablePullDown: true,
        enablePullUp: false,
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
                      } else if (item.sensorType == "light") {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new EnumSensorPage(sensor: item),
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
   /* DatabaseTool database = new DatabaseTool();
    List templist = await database.getSensorList();
    sensorlist.clear();
    templist.forEach((item) => sensorlist.add(SensorEntity.fromMap(item)));
    if (templist.isEmpty) {
      print("传感器列表为空");
    }
    setState(() {});
    await database.close();  */

    SensorManageTool sensorManageTool = new SensorManageTool();
    sensorlist = await sensorManageTool.getSensorList();
    setState(() {
      
    });

  }

  _refreshSensorList(bool up) async {
    _loadSensorList();
    if (up) {
      new Future.delayed(Duration(microseconds: 2000)).then((val) {
        _refreshController.sendBack(true, RefreshStatus.completed);
      });
    } else {
      _refreshController.sendBack(true, RefreshStatus.noMore);
    }
  }
}
