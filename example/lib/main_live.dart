import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> data = [];
  final _scanKey = GlobalKey<CameraMlVisionState>();
  BarcodeDetector detector = FirebaseVision.instance.barcodeDetector();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraMlVision<List<Barcode>>(
            key: _scanKey,
            detector: detector.detectInImage,
            resolution: ResolutionPreset.high,
            onResult: (barcodes) {
              if (barcodes == null ||
                  barcodes.isEmpty ||
                  data.contains(barcodes.first.displayValue) ||
                  !mounted) {
                return;
              }
              setState(() {
                data.add(barcodes.first.displayValue);
              });
            },
            onDispose: () {
              detector.close();
            },
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 250),
                  child: Scrollbar(
                    child: ListView(
                      children: data.map((d) {
                        return Container(
                          color: Color(0xAAFFFFFF),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(d),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        _scanKey.currentState.toggle();
                      },
                      child: Text('Start/Pause camera'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => _SecondScreen()));
                      },
                      child: Text('Push new route'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RaisedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => _SecondScreen(),
          ));
        },
        child: Text('Push new route'),
      ),
    );
  }
}
