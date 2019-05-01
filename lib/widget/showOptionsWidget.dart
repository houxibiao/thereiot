import 'package:flutter/material.dart';

Widget ShowOptionsWidget(Function onChangedFunction,String showValue) {
  return Padding(
    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
    child: ListTile(
      title: const Text("历史预览",style: TextStyle(fontSize: 12, color: Colors.black54),),
      trailing: DropdownButton<String>(
        value: showValue,
        onChanged: (String newValue){
          onChangedFunction(newValue);
        },
        items: <String>['RealTime','OneHour','OneDay','OneWeek'].map<DropdownMenuItem<String>>((String value){
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value,style: TextStyle(fontSize: 12, color: Colors.black54),),
          );
        }).toList(),
      ),
    ),
  );
}
