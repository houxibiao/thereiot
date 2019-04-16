import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseTool{

  Database _database;

  final String tableName = "SensorTable";
  final String columnId = "sensorId";
  final String columnName = "sensorName";
  final String columnType = "sensorType";
  final String columnRoomId = "roomId";
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
      $columnType text,
      $columnRoomId integer not null,
      $coulmnDescription text
    )
      '''
    );
    print("the table has created");
  }

  

}