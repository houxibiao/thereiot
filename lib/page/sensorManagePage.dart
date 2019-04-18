import 'package:flutter/material.dart';
import 'package:thereiot/tool/database.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'addSensorPage.dart';

class SensorManagePage extends StatefulWidget {
  @override
  _SensorManagePageState createState() => _SensorManagePageState();
}

class _SensorManagePageState extends State<SensorManagePage> {
  List<SensorEntity> sensorlist = new List<SensorEntity>();
  bool isExpanded;

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
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Center(
              child: FlatButton(
                color: Colors.white30,
                textColor: Colors.black45,
                child: Text("添加传感器"),
                onPressed: ()=>Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context)=>new AddSensorPage()
                )),
              ),
            ),
          ),
          sensorlist.isEmpty
              ? Container(
                  child: Center(
                    child: Text("空"),
                  ),
                )
              : ExpansionPanelList(
                  children: sensorlist.map((item) {
                    return ExpansionPanel(
                      isExpanded: true,
                      headerBuilder: (context,isExpanded){
                        return new ListTile(
                          title: Text(item.sensorName),
                        );
                      },
                      body:  new Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("sensorId:${item.sensorId}"),
                                Text("RoomId:${item.parentRoom}"),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text("sensorType:${item.sensorType}"),
                            SizedBox(height: 10,),
                            Text(item.description),
                            SizedBox(height: 10,),
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
    sensorlist.clear();
    templist.forEach((item) => sensorlist.add(SensorEntity.fromMap(item)));
    if (templist.isEmpty) {
      print("传感器列表为空");
    }
    setState(() {});
    await database.close();
  }

  _expandedCallback(int index,bool isExpanded){
    setState(() {
     if(this.isExpanded==isExpanded){
       this.isExpanded=!isExpanded;
     } 
    });
  }

}
