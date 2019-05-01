import 'package:flutter/material.dart';
import 'package:thereiot/entity/sensorEntity.dart';

Card SensorCardWidget(SensorEntity sensor) {
  return Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.0 / 1.0,
          child: Image.asset(
            "assets/${sensor.sensorType}.png",
            width: 60,
            height: 60,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                  sensor.sensorName,
                  maxLines: 1,
                ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}
