library flutter_camera_ml_vision;

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/widgets.dart';

enum CameraMlVisionState {
  loading,
  noCamera,
  ready,
}

class BarcodeCameraMlVision extends StatefulWidget {
  final BarcodeFormat barcodeFormat;
  final ValueChanged<Barcode> onBarcode;

  BarcodeCameraMlVision({
    this.barcodeFormat: BarcodeFormat.all,
    @required this.onBarcode,
  });

  @override
  _BarcodeCameraMlVisionState createState() => _BarcodeCameraMlVisionState();
}

class _BarcodeCameraMlVisionState extends State<BarcodeCameraMlVision> {
  BarcodeDetector _barcodeDetector;
  CameraController _cameraController;
  CameraMlVisionState _cameraMlVisionState = CameraMlVisionState.loading;
  bool _alreadyCheckingImage = false;

  @override
  void initState() {
    super.initState();
    _barcodeDetector = FirebaseVision.instance.barcodeDetector(
      BarcodeDetectorOptions(
        barcodeFormats: widget.barcodeFormat,
      ),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _cameraMlVisionState = CameraMlVisionState.noCamera;
      return;
    }
    _cameraController =
        CameraController(cameras.first, ResolutionPreset.medium);
    if (!mounted) {
      return;
    }
    await _cameraController.initialize();
    setState(() {
      _cameraMlVisionState = CameraMlVisionState.ready;
    });

    _cameraController.startImageStream((cameraImage) async {
      if (!_alreadyCheckingImage) {
        _alreadyCheckingImage = true;
        final image = FirebaseVisionImage.fromBytes(
          cameraImage.planes.first.bytes,
          FirebaseVisionImageMetadata(
            planeData: [
              FirebaseVisionImagePlaneMetadata(
                bytesPerRow: cameraImage.planes.first.bytesPerRow,
                height: cameraImage.planes.first.height,
                width: cameraImage.planes.first.width,
              ),
            ],
            rawFormat: cameraImage.format.raw,
            size: Size(
              cameraImage.width.toDouble(),
              cameraImage.height.toDouble(),
            ),
          ),
        );
        final List<Barcode> barcodes =
            await _barcodeDetector.detectInImage(image);
        extractBarcodes(barcodes);
        _alreadyCheckingImage = false;
      }
    });
  }

  void extractBarcodes(List<Barcode> barcodes) {
    for (Barcode barcode in barcodes) {
      widget.onBarcode(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraMlVisionState == CameraMlVisionState.loading) {
      //  TODO: add a way to let the user to add it's own loading screen
      return Container();
    }
    if (_cameraMlVisionState == CameraMlVisionState.noCamera) {
      //  TODO: add a better message when no camera available
      return Text('no camera available');
    }
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.cover,
      child: SizedBox(
        width: _cameraController.value.previewSize.height *
            _cameraController.value.aspectRatio,
        height: _cameraController.value.previewSize.height,
        child: AspectRatio(
          aspectRatio: _cameraController.value.aspectRatio,
          child: CameraPreview(
            _cameraController,
          ),
        ),
      ),
    );
  }
}
