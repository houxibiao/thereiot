import 'package:flutter/material.dart';
import 'package:thereiot/tool/database.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:thereiot/widget/sensorCardWidget.dart';

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
                return SensorCardWidget(item);
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
