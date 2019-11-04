part of 'flutter_camera_ml_vision.dart';

Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
    (cameras) => cameras.firstWhere(
      (camera) => camera.lensDirection == dir,
      orElse: () => cameras.isNotEmpty ? cameras.first : null,
    ),
  );
}

Uint8List _concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

FirebaseVisionImageMetadata buildMetaData(
  CameraImage image,
  ImageRotation rotation,
) {
  return FirebaseVisionImageMetadata(
    rawFormat: image.format.raw,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: rotation,
    planeData: image.planes
        .map(
          (plane) => FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          ),
        )
        .toList(),
  );
}

Future<T> _detect<T>(
  CameraImage image,
  HandleDetection<T> handleDetection,
  ImageRotation rotation,
) async {
  return handleDetection(
    FirebaseVisionImage.fromBytes(
      _concatenatePlanes(image.planes),
      buildMetaData(image, rotation),
    ),
  );
}

ImageRotation _rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return ImageRotation.rotation0;
    case 90:
      return ImageRotation.rotation90;
    case 180:
      return ImageRotation.rotation180;
    default:
      assert(rotation == 270);
      return ImageRotation.rotation270;
  }
}
