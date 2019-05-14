import 'dart:io';
import 'package:thereiot/entity/sensorEntity.dart';
import 'package:dio/dio.dart';

class SensorManageTool {
  Future<List<SensorEntity>> getSensorList() async {

    Dio dio = new Dio();
    List<SensorEntity> sensorlist = new List<SensorEntity>();

    var url = "http://123.56.20.55:8082/sensors/getSensors";

    Response response = await dio.get(url);  // var response = await http.get(url);
    if (response.statusCode == 200) {

      Map<String, dynamic> result = response.data;

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

  Future<String> addSensor(Map<String,dynamic> sensorMap) async{

    Dio dio = new Dio();
    Response response;
    var url = "http://123.56.20.55:8082/sensors/addSensor";

    try{
      response = await dio.post(url,data:sensorMap,options: Options(contentType: ContentType.json));
      print(response.data);
      return response.data.toString();
    }catch(e){
      print(e);
      return e.toString();
    }  
  }

  Future<String> modifySensor(Map<String,dynamic> sensorMap) async{

    Dio dio = new Dio();
    Response response;
    var url = "http://123.56.20.55:8082/sensors/modifySensor";

    try{
      response = await dio.post(url,data:sensorMap,options: Options(contentType: ContentType.json));
      print(response.data);
      return response.data.toString();
    }catch(e){
      print(e);
      return e.toString();
    }  
  }

}
