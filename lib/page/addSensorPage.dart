import 'package:flutter/material.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:thereiot/tool/sensorManageTool.dart';

class AddSensorPage extends StatefulWidget {
  @override
  _AddSensorPageState createState() => _AddSensorPageState();
}

class _AddSensorPageState extends State<AddSensorPage> {
  int _sensorId;
  int _roomid;
  int _fieldNum;
  String _sensorName;
  String _sensorType;
  String _fieldNames;
  String _valuePrecison;

  final _formKey = new GlobalKey<FormState>();
  TextEditingController textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("添加传感器"),
      ),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              children: <Widget>[
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: initSensorId(),
                ),
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: initSensorName(),
                ),
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: initSensorType(),
                ),
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: initRoomId(),
                ),
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: initFieldNum(),
                ),
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: initFieldNames(),
                ),
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  child: initValuePrecison(),
                ),
                Container(
                  height: 10,
                  color: Colors.grey[100],
                ),
                initSubmitButton(context),
                Container(
                  height: 20,
                  color: Colors.grey[100],
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  TextFormField initSensorId() {
    return TextFormField(
      onSaved: (String value) => _sensorId = int.parse(value),
      decoration: InputDecoration(
        labelText: 'sensorId',
        border: InputBorder.none,
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
        border: InputBorder.none,
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
        border: InputBorder.none,
      ),
      onSaved: (String value) => _roomid = int.parse(value),
      validator: (String value) {
        if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'roomId必须为数字';
        }
      },
    );
  }

  TextFormField initSensorType() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'sensorType',
        border: InputBorder.none,
      ),
      onSaved: (String value) => _sensorType = value,
      validator: (String value) {
        if (value.isEmpty) {
          return "非空";
        }
      },
    );
  }

  TextField initFieldNum() {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: '参数数量',
        hintText: '请输入参数数量',
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.numberWithOptions(),
      onChanged: (String value) => _fieldNum = int.parse(value),
    );
  }

  TextFormField initFieldNames() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '参数名称',
        hintText: '以逗号分隔开',
        border: InputBorder.none,
      ),
      onSaved: (String value) => _fieldNames = value,
      validator: (String value) {
        if (value.isEmpty) {
          return "非空";
        } else if (value.split(",").length != _fieldNum) {
          return "fieldname的数量为:${value.split(",").length} 与fieldNum:$_fieldNum 不匹配";
        }
      },
    );
  }

  TextFormField initValuePrecison() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: '数据精度',
        hintText: '以逗号分隔开',
        border: InputBorder.none,
      ),
      onSaved: (String value) => _valuePrecison = value,
      validator: (String value) {
        if (value.isEmpty) {
          return "非空";
        } else if (value.split(",").length != _fieldNum) {
          return "数量与fieldNum不匹配";
        }
      },
    );
  }

  Center initSubmitButton(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40,
        child: RaisedButton(
          child: Text('确定', style: TextStyle(color: Colors.white)),
          color: Colors.blueAccent,
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              SensorEntity sensor = new SensorEntity(_sensorId, _sensorName,
                  _sensorType, _roomid, _fieldNum, _fieldNames, _valuePrecison);
              /*  DatabaseTool database = new DatabaseTool();
              int result = await database.insertSensor(sensor);
              print("插入数据库的返回码是:$result");
              await database.close();  */
              SensorManageTool sensorManageTool = new SensorManageTool();
              String result = await sensorManageTool.addSensor(sensor.toMap());
              final snackBar = new SnackBar(
                content: Text(result),
                backgroundColor: Colors.lightBlue,
              );
              Scaffold.of(context).showSnackBar(snackBar);
            }
          },
        ),
      ),
    );
  }
}
