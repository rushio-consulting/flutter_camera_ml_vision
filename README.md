# Flutter Camera Ml Vision

[![pub package](https://img.shields.io/pub/v/flutter_camera_ml_vision.svg)](https://pub.dartlang.org/packages/flutter_camera_ml_vision)


A Flutter package for iOS and Android to show a preview of the camera and detect things with Firebase ML Vision.

<img src="https://raw.githubusercontent.com/rushio-consulting/flutter_camera_ml_vision/master/videos/scan_page.gif" width="100" />

## Installation

First, add `flutter_camera_ml_vision` as a dependency.

```yaml
...
dependencies:
  flutter:
    sdk: flutter
  flutter_camera_ml_vision: ^3.0.1
...
```

### iOS

Add two rows to the ios/Runner/Info.plist:

* one with the key Privacy - Camera Usage Description and a usage description.
* and one with the key Privacy - Microphone Usage Description and a usage description.
Or in text format add the key:

```
<key>NSCameraUsageDescription</key>
<string>Can I use the camera please?</string>
<key>NSMicrophoneUsageDescription</key>
<string>Can I use the mic please?</string>
```

If you're using one of the on-device APIs, include the corresponding ML Kit library model in your Podfile. Then run pod update in a terminal within the same directory as your Podfile.

```
pod 'GoogleMLKit/BarcodeScanning' '~> 2.2.0'
pod 'GoogleMLKit/FaceDetection' '~> 2.2.0'
pod 'GoogleMLKit/ImageLabeling' '~> 2.2.0'
pod 'GoogleMLKit/TextRecognition' '~> 2.2.0'
```

### Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```
_ps: This is due to the dependency on the camera plugin._


If you're using the on-device `LabelDetector`, include the latest matching [ML Kit: Image Labeling](https://firebase.google.com/support/release-notes/android) dependency in your app-level `build.gradle` file.

```gradle
android {
    dependencies {
        // ...

        api 'com.google.mlkit:image-labeling:17.0.5'
    }
}
```

If you receive compilation errors, try an earlier version of [ML Kit: Image Labeling](https://firebase.google.com/support/release-notes/android).

Optional but recommended: If you use the on-device API, configure your app to automatically download the ML model to the device after your app is installed from the Play Store. To do so, add the following declaration to your app's `AndroidManifest.xml` file:

```xml
<application ...>
  ...
  <meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="ocr" />
  <!-- To use multiple models: android:value="ocr,label,barcode,face" -->
</application>
```

## Usage

### 1. Example with Barcode

```dart
CameraMlVision<List<Barcode>>(
  detector: GoogleMlKit.vision.barcodeScanner().processImage,
  onResult: (List<Barcode> barcodes) {
    if (!mounted || resultSent) {
      return;
    }
    resultSent = true;
    Navigator.of(context).pop<Barcode>(barcodes.first);
  },
)
```

`CameraMlVision` is a widget that shows the preview of the camera. It takes a detector as a parameter; here we pass the `processImage` method of the `BarcodeScanner` object.
The detector parameter can take all the different MLKit Vision Detectors. Here is a list :

```
GoogleMlKit.vision.barcodeScanner().processImage
GoogleMlKit.vision.imageLabeler().processImage
GoogleMlKit.vision.faceDetector().processImage
GoogleMlKit.vision.textDetector().processImage
```

Then when something is detected the onResult callback is called with the data in the parameter of the function.

### Exposed functionality from CameraController

We expose some functionality from the CameraController class here a list of these :

- value
- prepareForVideoRecording
- startVideoRecording
- stopVideoRecording
- takePicture

## Getting Started

See the `example` directory for a complete sample app.

## Features and bugs 

Please file feature requests and bugs at the [issue tracker](https://github.com/santetis/flutter_camera_ml_vision/issues).

## Technical Support

For any technical support, don't hesitate to contact us. 
Find more information in our [website](https://rushio-consulting.fr)

For now, all the issues with the label `support` mean that they come out of the scope of the following project. So you can [contact us](https://rushio-consulting.fr/support) as a support.

