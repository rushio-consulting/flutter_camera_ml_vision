import 'package:google_ml_kit/google_ml_kit.dart';
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
  BarcodeScanner scanner = GoogleMlKit.vision.barcodeScanner();

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
            detector: scanner.processImage,
            resolution: ResolutionPreset.high,
            onResult: (barcodes) {
              if (barcodes == null ||
                  barcodes.isEmpty ||
                  data.contains(barcodes.first.value.displayValue) ||
                  !mounted) {
                return;
              }
              setState(() {
                data.add(barcodes.first.value.displayValue);
              });
            },
            onDispose: () {
              scanner.close();
            },
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ConstrainedBox(
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _scanKey.currentState.toggle();
                      },
                      child: Text('Start/Pause camera'),
                    ),
                    ElevatedButton(
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
      body: ElevatedButton(
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
