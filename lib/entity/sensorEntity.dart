class SensorEntity {
  int sensorId;
  String sensorName;
  String sensorType;
  int parentRoom;//传感器的房间归属,非空，方便后续的程序设计的调整
  String description;

  SensorEntity(this.sensorId, this.sensorName, this.sensorType, this.parentRoom,
      {this.description});

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'sensorId': sensorId,
      'sensorName': sensorName,
      'sensorType': sensorType,
      'parentRoom': parentRoom,
      'description': description
    };

    return map;
  }

  SensorEntity.fromMap(Map<String,dynamic> map){

    sensorId = map['sensorId'];
    sensorName = map['sensorName'];
    sensorType = map['sensorType'];
    parentRoom = map['parentRoom'];
    description = map['description'];

  }

}
