library flutter_camera_ml_vision;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'utils.dart';

typedef HandleDetection<T> = Future<T> Function(FirebaseVisionImage image);
typedef WidgetBuilder = Widget Function(BuildContext);

enum CameraMlVisionState {
  loading,
  noCamera,
  error,
  ready,
}

class CameraMlVision<T> extends StatefulWidget {
  final HandleDetection<T> detector;
  final Function(T) onResult;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder errorBuilder;

  CameraMlVision({
    @required this.onResult,
    this.detector,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  _CameraMlVisionState createState() => _CameraMlVisionState<T>();
}

class _CameraMlVisionState<T> extends State<CameraMlVision<T>> {
  CameraController _cameraController;
  HandleDetection detector;
  CameraMlVisionState _cameraMlVisionState = CameraMlVisionState.loading;
  bool _alreadyCheckingImage = false;

  @override
  void initState() {
    super.initState();

    final FirebaseVision mlVision = FirebaseVision.instance;
    detector = widget.detector ?? mlVision.barcodeDetector().detectInImage;
    _initialize();
  }

  Future<void> _initialize() async {
    CameraDescription description = await _getCamera(CameraLensDirection.back);
    if (description == null) {
      _cameraMlVisionState = CameraMlVisionState.noCamera;
      return;
    }
    _cameraController = CameraController(description, ResolutionPreset.medium);
    if (!mounted) {
      return;
    }

    try {
      await _cameraController.initialize();
    } catch (ex, stack) {
      setState(() {
        _cameraMlVisionState = CameraMlVisionState.error;
      });
      debugPrint('Can\'t initialize camera');
      debugPrint('$ex, $stack');
      return;
    }
    setState(() {
      _cameraMlVisionState = CameraMlVisionState.ready;
    });
    ImageRotation rotation = _rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _cameraController.startImageStream((cameraImage) async {
      if (!_alreadyCheckingImage) {
        _alreadyCheckingImage = true;
        try {
          final T results = await _detect<T>(cameraImage, detector, rotation);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraMlVisionState == CameraMlVisionState.loading) {
      return widget.loadingBuilder == null ? Center(child: CircularProgressIndicator()) : widget.loadingBuilder(context);
    }
    if (_cameraMlVisionState == CameraMlVisionState.noCamera || _cameraMlVisionState == CameraMlVisionState.error) {
      return widget.errorBuilder == null ? Center(child: Text('$_cameraMlVisionState')) : widget.errorBuilder(context);
    }
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.cover,
      child: SizedBox(
        width: _cameraController.value.previewSize.height * _cameraController.value.aspectRatio,
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
