import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'There IOT',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'There IOT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Timer timer;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    _reflashData();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

_getData() async{

    var url = "http://123.56.20.55:8086/query?u=hou&p=Hou13734&db=yuntest";
    var response = await http.post(url,body:{'q':'select last(fieldvalue0),fieldvalue1,fieldvalue2,sensorType from room34563 group by sensorId'});

    if(response.statusCode==200){

      Map<String,dynamic> result = json.decode(response.body);

      for(dynamic data in result['results'][0]['series']){

        if(data['values'][0][4]=="ds18b20"){
          print("传感器类型:ds18b20,更新时间: ${data['values'][0][0]},温度: ${data['values'][0][1]}");
        }else if(data['values'][0][4]=='dht11'){
          print("传感器类型:dht11,更新时间: ${data['values'][0][0]},温度:${data['values'][0][1]},湿度:${data['values'][0][2]}%");
        }else if(data['values'][0][4]=='mpu6050'){
          print("传感器类型:mpu6050,更新时间: ${data['values'][0][0]},x轴:${data['values'][0][1]},y轴:${data['values'][0][2]},z轴:${data['values'][0][3]}");
        }else{

          print("传感器类型:${data['values'][0][4]}(未知类型),更新时间: ${data['values'][0][0]},fieldvalue0:${data['values'][0][1]},fieldvalue1:${data['values'][0][2]},fieldvalue2:${data['values'][0][3]}");
        }

      }

    }else{
      print("获取失败,错误码为:${response.statusCode}");
    }

  }

  _reflashData() async{

    if(timer==null){
      timer = Timer.periodic(Duration(seconds: 15), (as) async {

        DateTime datetime = DateTime.now();
        print("获取新的数据,现在的时间是$datetime");

        await _getData();

        setState(() {
          
        });

      });
    }

  }

}
