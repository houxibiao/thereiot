import 'package:flutter/material.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'addSensorPage.dart';
import 'package:thereiot/tool/sensorManageTool.dart';
import 'modifySensorPage.dart';

class SensorManagePage extends StatefulWidget {
  @override
  _SensorManagePageState createState() => _SensorManagePageState();
}

class _SensorManagePageState extends State<SensorManagePage> {
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: ()=>loadSensorList(),
            ),
          ],
        ),

        body: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            fit: StackFit.expand,
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                top: 0,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
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
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(
                                              "sensorId:${item.sensor.sensorId}"),
                                          Text(
                                              "RoomId:${item.sensor.parentRoom}"),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text("参数数量:${item.sensor.fieldNum}"),
                                          Text(
                                              "sensorType:${item.sensor.sensorType}"),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          "参数名称:${item.sensor.fieldNames.replaceAll(",", "/")}"),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          RaisedButton(
                                            color: Colors.blue[300],
                                            child: Text("编辑"),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          new ModifySensorPage(
                                                              sensor: item
                                                                  .sensor)));
                                            },
                                          ),
                                          RaisedButton(
                                            color: Colors.blue[300],
                                            child: Text("删除"),
                                            onPressed: () {
                                              _deleteSensorById(
                                                  item.sensor.sensorId);
                                              loadSensorList();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 15),
                  child: Center(
                    child: RaisedButton(
                      child: Text("添加传感器"),
                      onPressed: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new AddSensorPage())),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  loadSensorList() async {
    SensorManageTool sensorManageTool = new SensorManageTool();
    List<SensorEntity> sensorlist = new List<SensorEntity>();
    sensorlist = await sensorManageTool.getSensorList();
    if (sensorlist.isEmpty) {
      print("传感器列表为空");
      sensorInfoList.clear();
    } else {
      print("加载到传感器列表");
      sensorInfoList.clear();
      sensorlist
          .forEach((item) => sensorInfoList.add(SensorInfoBean(item, false)));
    }
    setState(() {});
  }

  _setCurrentIndex(int index, bool isExpanded) {
    setState(() {
      currentIndex = index;
      sensorInfoList[index].expandedState = !isExpanded;
    });
  }

  _deleteSensorById(int sensorId) async {
    /*  DatabaseTool database = new DatabaseTool();
    int result = await database.deleteSensor(sensorId);
    print("删除了一个传感器,返回值:$result");
    await database.close();
    loadSensorList();    */
    SensorManageTool sensorManageTool = new SensorManageTool();
    await sensorManageTool.deleteSensor(sensorId);
  }
}

class SensorInfoBean {
  SensorEntity sensor;
  bool expandedState;
  SensorInfoBean(this.sensor, this.expandedState);
}
