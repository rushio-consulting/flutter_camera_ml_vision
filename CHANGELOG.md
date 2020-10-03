## [2.3.0] - 03/10/2020

- fix NPE on aspect ratio
- update deps

## [2.2.5] - 12/02/2020

- fix crash on android app lifecycle
- expose camera controller
- pass default resolution to high to improve reading of barcode
- update deps

## [2.2.4] - 04/11/2019

- simplify pause stream when not on screen by using VisibilityDetector widget

## [2.2.3] - 23/10/2019

- fix crash when setState is called when unmounted
- update dependencies

## [2.2.2] - 02/09/2019

- fix black screen on some Android device in profile/release mode

## [2.2.1] - 19/06/2019

- fix bug when specifying resolution

## [2.2.0] - 16/06/2019

- disable audio (#43)
- let user define camera resolution (#45)

## [2.1.0] - 16/05/2019

expose more function from camera controller
- prepareForVideoRecording
- startVideoRecording
- stopVideoRecording
- takePicture

## [2.0.1] - 5/05/2019

* fix a crash when poping a route with the camera preview

## [2.0.0] - 2/05/2019

* We now forward the result from firebase_ml_vision for onResult

## [1.5.0] - 24/04/2019

* fix installation problems
* Expose camera value

## [1.4.0] - 24/04/2019

* add cameraLensDirection parameter (this default to back)

## [1.3.0] - 17/04/2019

* add overlayBuilder parameter

## [1.2.0] - 12/04/2019

* fix crash above android api 21.
* fix pause when a new route is pushed.

## [1.1.0] - 11/04/2019

* Allow usage under android api 21.
* Add error type on error builder.

## [1.0.0] - 10/04/2019

* Initial release.
