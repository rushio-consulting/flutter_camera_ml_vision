library flutter_camera_ml_vision;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

part 'utils.dart';

typedef HandleDetection<T> = Future<T> Function(FirebaseVisionImage image);
typedef Widget ErrorWidgetBuilder(BuildContext context, CameraError error);

enum CameraError {
  unknown,
  cantInitializeCamera,
  androidVersionNotSupported,
  noCameraAvailable,
}

enum _CameraState {
  loading,
  error,
  ready,
}

class CameraMlVision<T> extends StatefulWidget {
  final HandleDetection<T> detector;
  final Function(T) onResult;
  final WidgetBuilder loadingBuilder;
  final ErrorWidgetBuilder errorBuilder;

  CameraMlVision({
    Key key,
    @required this.onResult,
    this.detector,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  CameraMlVisionState createState() => CameraMlVisionState<T>();
}

class CameraMlVisionState<T> extends State<CameraMlVision<T>> {
  String _lastImage;
  CameraController _cameraController;
  HandleDetection _detector;
  ImageRotation _rotation;
  _CameraState _cameraMlVisionState = _CameraState.loading;
  CameraError _cameraError = CameraError.unknown;
  bool _alreadyCheckingImage = false;
  bool _isStreaming = false;
  bool _isDeactivate = false;

  @override
  void initState() {
    super.initState();

    final FirebaseVision mlVision = FirebaseVision.instance;
    _detector = widget.detector ?? mlVision.barcodeDetector().detectInImage;
    _initialize();
  }

  Future<void> stop() async {
    if (_lastImage != null && File(_lastImage).existsSync()) {
      await File(_lastImage).delete();
    }

    Directory tempDir = await getTemporaryDirectory();
    _lastImage = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}';
    await _cameraController.takePicture(_lastImage);

    await _stop(false);
  }

  Future<void> _stop(bool silently) async {
    if (_cameraController.value.isStreamingImages) {
      await _cameraController.stopImageStream();
    }

    if (silently) {
      _isStreaming = false;
    } else {
      setState(() {
        _isStreaming = false;
      });
    }
  }

  void start() {
    _start(false);
  }

  void _start(bool silently) {
    _cameraController.startImageStream(_processImage);
    if (silently) {
      _isStreaming = true;
    } else {
      setState(() {
        _isStreaming = true;
      });
    }
  }

  Future<void> _initialize() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 21) {
        debugPrint('Camera plugin doesn\'t support android under version 21');
        _cameraMlVisionState = _CameraState.error;
        _cameraError = CameraError.androidVersionNotSupported;
        return;
      }
    }

    CameraDescription description = await _getCamera(CameraLensDirection.back);
    if (description == null) {
      _cameraMlVisionState = _CameraState.error;
      _cameraError = CameraError.noCameraAvailable;

      return;
    }
    _cameraController = CameraController(description,
        Platform.isIOS ? ResolutionPreset.low : ResolutionPreset.medium);
    if (!mounted) {
      return;
    }

    try {
      await _cameraController.initialize();
    } catch (ex, stack) {
      setState(() {
        _cameraMlVisionState = _CameraState.error;
        _cameraError = CameraError.cantInitializeCamera;
      });
      debugPrint('Can\'t initialize camera');
      debugPrint('$ex, $stack');
      return;
    }

    setState(() {
      _cameraMlVisionState = _CameraState.ready;
    });
    _rotation = _rotationIntToImageRotation(
      description.sensorOrientation,
    );

    start();
  }

  @override
  void deactivate() {
    if (_isDeactivate) {
      _isDeactivate = false;
      _start(true);
    } else {
      _isDeactivate = true;
      _stop(true);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (_lastImage != null && File(_lastImage).existsSync()) {
      File(_lastImage).delete();
    }
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraMlVisionState == _CameraState.loading) {
      return widget.loadingBuilder == null
          ? Center(child: CircularProgressIndicator())
          : widget.loadingBuilder(context);
    }
    if (_cameraMlVisionState == _CameraState.error) {
      return widget.errorBuilder == null
          ? Center(child: Text('$_cameraMlVisionState $_cameraError'))
          : widget.errorBuilder(context, _cameraError);
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
          child: _isStreaming
              ? CameraPreview(
                  _cameraController,
                )
              : _getPicture(),
        ),
      ),
    );
  }

  _processImage(CameraImage cameraImage) async {
    if (!_alreadyCheckingImage) {
      _alreadyCheckingImage = true;
      try {
        final T results = await _detect<T>(cameraImage, _detector, _rotation);
        if (results != null) {
          if (results is List && results.length > 0) {
            widget.onResult(results);
          } else if (results is! List) {
            widget.onResult(results);
          }
        }
      } catch (ex, stack) {
        debugPrint('$ex, $stack');
      }
      _alreadyCheckingImage = false;
    }
  }

  void toggle() {
    if (_isStreaming) {
      stop();
    } else {
      start();
    }
  }

  Widget _getPicture() {
    if (_lastImage != null) {
      final file = File(_lastImage);
      if (file.existsSync()) {
        return Image.file(file);
      }
    }

    return Container();
  }
}
