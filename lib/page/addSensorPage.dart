import 'package:flutter/material.dart';
import 'package:thereiot/tool/database.dart';
import 'package:thereiot/entity/sensorEntity.dart';

class AddSensorPage extends StatefulWidget {
  @override
  _AddSensorPageState createState() => _AddSensorPageState();
}

class _AddSensorPageState extends State<AddSensorPage> {
  int _sensorId;
  int _roomid;
  String _sensorName;
  String _sensorType;
  int _fieldNum;
  String _description;

  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("添加传感器"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            initTitle(),
            SizedBox(
              height: 20,
            ),
            initSensorId(),
            SizedBox(
              height: 20,
            ),
            initSensorName(),
            SizedBox(
              height: 20,
            ),
            initSensorType(),
            SizedBox(
              height: 20,
            ),
            initRoomId(),
            SizedBox(
              height: 20,
            ),
            initFieldNum(),
            SizedBox(
              height: 20,
            ),
            initDescription(),
            SizedBox(height: 30,),
            initSubmitButton(),
          ],
        ),
      ),
    );
  }

  Padding initTitle() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        "添加传感器",
        style: TextStyle(
          fontSize: 20,
          color: Colors.blueAccent,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TextFormField initSensorId() {
    return TextFormField(
      onSaved: (String value) => _sensorId = int.parse(value),
      decoration: InputDecoration(
        labelText: 'sensorId',
      ),
      keyboardType: TextInputType.numberWithOptions(),
      validator: (String value) {
        if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'id必须为数字';
        }
      },
    );
  }

  TextFormField initSensorName() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'sensorName',
      ),
      onSaved: (String value) => _sensorName = value,
      validator: (String value) {
        if (value.isEmpty) {
          return 'sensorName cannot be null';
        }
      },
    );
  }

  TextFormField initRoomId() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Room',
      ),
      onSaved: (String value) => _roomid = int.parse(value),
      validator: (String value) {
        if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'roomId必须为数字';
        }
      },
    );
  }

  TextFormField initFieldNum(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'fieldNum',
      ),
      onSaved: (String value)=>_fieldNum = int.parse(value),
      validator: (String value){
        if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'fieldNum必须为数字';
        }
      },
    );
  }

  TextFormField initSensorType() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'sensorType',
      ),
      onSaved: (String value) => _sensorType = value,
      validator: (String value) {
        if (value.isEmpty) {
          return "非空";
        }
      },
    );
  }

  TextFormField initDescription() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'description'),
      onSaved: (String value) => _description = value,
    );
  }

  Center initSubmitButton() {
    return Center(
      child: SizedBox(
        width: 100,
        height: 40,
        child: RaisedButton(
          child: Text('确定', style: TextStyle(color: Colors.white)),
          color: Colors.blueAccent,
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              SensorEntity sensor = new SensorEntity(
                  _sensorId, _sensorName, _sensorType, _roomid,_fieldNum,
                  description: _description);
              DatabaseTool database = new DatabaseTool();
              int result = await database.insertSensor(sensor);
              print("插入数据库的返回码是:$result");
              await database.close();
            }
          },
        ),
      ),
    );
  }
}
