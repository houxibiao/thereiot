
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:dio/dio.dart';

class SensorManageTool {
  Future<List<SensorEntity>> getSensorList() async {
    List<SensorEntity> sensorlist = new List<SensorEntity>();
    var url = "http://123.56.20.55:8082/sensors/getSensors";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);

      try {
        for (dynamic item in result["sensors"]) {
          sensorlist.add(SensorEntity.fromMap(item));
        }
      } catch (e) {
        print("$e");
      } finally {
        print("一次查询结束");
      }
    } else {
      print("status code :${response.statusCode}");
    }
    return sensorlist;
  }

  Future<void> deleteSensor(int id) async {
    Dio dio = new Dio();

    var url = "http://123.56.20.55:8082/sensors/deleteSensor";

    try {
      Response response = await dio.delete(url,queryParameters: {"sensorId":id});
      print(response.data);
    } catch (e) {
      print(e);
    } finally {
      print("删除操作结束");
    }
  }

  Future<void> addSensor(Map<String,dynamic> sensorMap) async{

    Dio dio = new Dio();

    var url = "http://123.56.20.55:8082/sensors/addSensor";

    try{
      Response response = await dio.post(url,data:sensorMap,options: Options(contentType: ContentType.json));
      print(response.data);
    }catch(e){
      print(e);
    }finally{
      print("添加任务完成");
    }
  }

}
