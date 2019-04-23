class SensorEntity {
  int sensorId;
  String sensorName;
  String sensorType;
  int parentRoom;//传感器的房间归属,非空，方便后续的程序设计的调整
  int fieldNum;//表示传感器测量值的数量0-3 0表示bool型传感器
  String description;

  SensorEntity(this.sensorId, this.sensorName, this.sensorType, this.parentRoom,this.fieldNum,
      {this.description});

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'sensorId': sensorId,
      'sensorName': sensorName,
      'sensorType': sensorType,
      'parentRoom': parentRoom,
      'fieldNum':fieldNum,
      'description': description
    };

    return map;
  }

  SensorEntity.fromMap(Map<String,dynamic> map){

    sensorId = map['sensorId'];
    sensorName = map['sensorName'];
    sensorType = map['sensorType'];
    parentRoom = map['parentRoom'];
    fieldNum = map['fieldNum'];
    description = map['description'];

  }

}
