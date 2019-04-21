import 'package:flutter/material.dart';
import 'package:thereiot/tool/database.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:thereiot/widget/sensorCardWidget.dart';
import 'package:thereiot/page/sensorManagePage.dart';
import 'dashBoardPage.dart';

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
      body: sensorlist.isEmpty
          ? Container(
              child: Text("空"),
            )
          : GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(10),
              childAspectRatio: 8.0 / 11.0,
              children: sensorlist.map((item) {
                return GestureDetector(
                  child: SensorCardWidget(item),
                  onTap: () => Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new DashBoardPage(sensor: item))),
                );
                //return SensorCardWidget(item);
              }).toList(),
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
}
