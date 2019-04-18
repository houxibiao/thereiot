import 'package:flutter/material.dart';
import 'package:thereiot/tool/database.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'addSensorPage.dart';

class SensorManagePage extends StatefulWidget {
  @override
  _SensorManagePageState createState() => _SensorManagePageState();
}

class _SensorManagePageState extends State<SensorManagePage> {
  //List<SensorEntity> sensorlist = new List<SensorEntity>();
  List<SensorInfoBean> sensorInfoList = new List<SensorInfoBean>();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadSensorList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("传感器列表"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Center(
              child: FlatButton(
                color: Colors.lightBlue,
                textColor: Colors.black45,
                child: Text("添加传感器"),
                onPressed: () => Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new AddSensorPage())),
              ),
            ),
          ),
          sensorInfoList.isEmpty
              ? Container(
                  child: Center(
                    child: Text("空"),
                  ),
                )
              : ExpansionPanelList(
                  expansionCallback: (index, bol) {
                    _setCurrentIndex(index, bol);
                  },
                  children: sensorInfoList.map((item) {
                    return ExpansionPanel(
                      isExpanded: item.expandedState,
                      headerBuilder: (context, isExpanded) {
                        return new ListTile(
                          title: Text(item.sensor.sensorName),
                        );
                      },
                      body: new Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.ltr,
                          children: <Widget>[
                            Text("sensorId:${item.sensor.sensorId}"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("RoomId:${item.sensor.parentRoom}"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("sensorType:${item.sensor.sensorType}"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(item.sensor.description),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  loadSensorList() async {
    DatabaseTool database = new DatabaseTool();
    List templist = await database.getSensorList();
    sensorInfoList.clear();
    templist.forEach((item) {
      //sensorlist.add(SensorEntity.fromMap(item));
      sensorInfoList.add(SensorInfoBean(SensorEntity.fromMap(item), false));
    });
    if (templist.isEmpty) {
      print("传感器列表为空");
    }
    setState(() {});
    await database.close();
  }

  _setCurrentIndex(int index, bool isExpanded) {
    setState(() {
      currentIndex = index;
      sensorInfoList[index].expandedState = !isExpanded;
    });
  }
}

class SensorInfoBean {
  SensorEntity sensor;
  bool expandedState;
  SensorInfoBean(this.sensor, this.expandedState);
}
