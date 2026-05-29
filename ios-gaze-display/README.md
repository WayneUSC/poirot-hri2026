# iOS Gaze Display

This Xcode project implements POIROT's animated face display.

## Core Behavior

- Captures front-camera frames with `AVCaptureSession`.
- Uses Apple Vision `VNDetectFaceLandmarksRequest` to locate eye landmarks.
- Maps detected face/eye position to bounded robot-eye offsets.
- Smooths motion with UIKit animation.
- Simulates blinking with randomized 3-7 second intervals.

## Run

1. Open `EyeTrackingApp.xcodeproj` in Xcode.
2. Select a physical iPhone with a front camera.
3. Grant camera permission.
4. Mount the iPhone in the robot head in landscape orientation.

The original study used an iPhone 12 Pro.
