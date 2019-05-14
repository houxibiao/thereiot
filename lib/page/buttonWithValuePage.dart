import 'package:flutter/material.dart';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class ButtonWithValuePage extends StatefulWidget {
  //这是带数字量的开关，比如带亮度调节功能的灯

  SensorEntity sensor;

  ButtonWithValuePage({Key key, @required this.sensor}) : super(key: key);

  @override
  _ButtonWithValuePageState createState() => _ButtonWithValuePageState();
}

class _ButtonWithValuePageState extends State<ButtonWithValuePage> {
  SensorEntity sensor;
  bool buttonState = true;
  int digital_value = 100;

  @override
  void initState() {
    super.initState();
    sensor = widget.sensor;
    _getLastValue(sensor);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      
      child: Material(
        color: Colors.grey,
        child: Container(
          height: 200,
          width: 200,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(sensor.sensorName,style: TextStyle(fontSize: 20,color: Colors.white54),),
            Switch(
              value: buttonState,
              activeColor: Colors.blue,
              onChanged: (bool val){
                this.setState((){
                  this.buttonState = val;
                });
                _postLastValue(sensor);
              },
            ),
            SizedBox(height: 20,),
            Slider(
              value: digital_value.toDouble(),
              max: 1000.0,
              min: 0.0,
              activeColor: Colors.blue,
              onChanged: (double val){
                this.setState((){
                  this.digital_value = val.toInt();
                });
                _postLastValue(sensor);
              },
            ),
          ],
        ),
        )
      )
    );
  }

  _getLastValue(SensorEntity sensor) async {
    String qStr =
        "select last(fieldvalue0),fieldvalue1 from room34563 where sensorId = '${sensor.sensorId}' tz('Asia/Shanghai')";

    var url = "http://123.56.20.55:8086/query?u=hou&p=Hou13734&db=yuntest";
    var response = await http.post(url, body: {'q': qStr});

    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);

      try {
        buttonState =
            result['results'][0]['series'][0]['values'][0][1] == 1 ? true : false;
        digital_value = result['results'][0]['series'][0]['values'][0][2];
        setState(() {
          
        });
      } catch (e) {
        print("undefined error:$e");
      }
    } else {
      print("error code: ${response.statusCode}");
    }
  }

  _postLastValue(SensorEntity sensor) async {
    var url = "http://123.56.20.55:8086/write?u=hou&p=Hou13734&db=yuntest";

    String data;

    data = buttonState == true
        ? "room34563,sensorId=${sensor.sensorId},sensorType=buttonwithvalue fieldvalue0=1,fieldvalue1=$digital_value"
        : "room34563,sensorId=${sensor.sensorId},sensorType=buttonwithvalue fieldvalue0=0,fieldvalue1=$digital_value";

    Dio dio = new Dio();

    Response response = await dio.post(url,
        data: data, options: Options(contentType: ContentType.text));

    if(response.statusCode==200||response.statusCode==204){
      print("${response.data}");
    }else{
      print("error code: ${response.statusCode}");
    }
  }
}
