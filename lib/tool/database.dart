import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:thereiot/entity/sensorEntity.dart';


class DatabaseTool{

  Database _database;

  final String tableName = "SensorTable";
  final String columnId = "sensorId";
  final String columnName = "sensorName";
  final String columnType = "sensorType";
  final String columnRoomId = "parentRoom";
  final String coulmnDescription = "descripyion";

  Future get db async{

    if(_database!=null){
      return _database;
    }else{
      print("初始化数据库");
      _database = await initDataBase();
      return _database;
    }

  }

  initDataBase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,"sensorlist");
    var database = await openDatabase(path,version:1,onCreate: onCreateDB);
    print("the path of the database is :$path");
    return database;
  }

  FutureOr<void> onCreateDB(Database db,int version) async{
    await db.execute(''''
    create table $tableName(
      $columnId integer primary key,
      $columnName text not null,
      $columnType text not null,
      $columnRoomId integer not null,
      $coulmnDescription text
    )
      '''
    );
    print("the table has created");
  }

  Future<int> insertSensor(SensorEntity sensor) async{

    Database database = await db;
    var result = database.insert(tableName, sensor.toMap());

    print("插入了一个新的传感器");
    return result;

  }

  Future<List> getSensorList() async{
    Database database = await db;
    var result = database.rawQuery("select * from $tableName order by $columnId ");
    print("获取到了传感器列表: "+result.toString());
    return result;
  }

  Future<List> getSensorByRoom(int roomId) async{
    Database database = await db;
    var result = database.rawQuery("select * from $tableName where $columnRoomId = $roomId order by $columnId");
    return result;
  }


  Future<int> deleteSensor(int id) async{
    Database database = await db;
    var result = database.rawDelete("delete from $tableName where $columnId = $id");
    return result;
  }

  Future close() async{
    Database database = await db;
    database.close();
    print("数据库已关闭");
  }

}