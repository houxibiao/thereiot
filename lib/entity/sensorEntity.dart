class SensorEntity {
  int sensorId;
  String sensorName;
  String sensorType;
  int parentRoom; //传感器的房间归属,非空，方便后续的程序设计的调整
  int fieldNum;
  String fieldNames;
  String valuePrecison;

  SensorEntity(
    this.sensorId,
    this.sensorName,
    this.sensorType,
    this.parentRoom,
    this.fieldNum,
    this.fieldNames,
    this.valuePrecison
  );

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'sensorId': sensorId,
      'sensorName': sensorName,
      'sensorType': sensorType,
      'parentRoom': parentRoom,
      'fieldNum':fieldNum,
      'fieldNames':fieldNames,
      'valuePrecison':valuePrecison
    };
    return map;
  }

  SensorEntity.fromMap(Map<String, dynamic> map) {
    sensorId = map['sensorId'];
    sensorName = map['sensorName'];
    sensorType = map['sensorType'];
    parentRoom = map['parentRoom'];
    fieldNum = map['fieldNum'];
    fieldNames=map['fieldNames'];
    valuePrecison=map['valuePrecison'];
  }
}
