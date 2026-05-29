# Reproduction Guide

This guide reconstructs the technical workflow used in the POIROT HRI study.

## System Overview

POIROT combines five subsystems:

1. A physical tabletop robot body with differential-drive base, 2-DOF arms, embedded iPhone face display, and abdomen-mounted card dispenser.
2. An iOS gaze display that tracks nearby faces and animates robot eyes.
3. A physical clue-card dispenser that delivers laminated cards with a friction roller.
4. An iOS companion app for script reading, role selection, rooms, public clues, and private clues.
5. A voice interaction module built around an ESP32-S3 audio board and an LLM-based Xiaozhi agent.

## Robot Platform

The appendix reports the robot as approximately 50.1 cm tall with a circular base of 34.3 cm diameter. The shell was 3D-printed PLA and modeled in Rhino. The locomotion base was derived from the open-source FishBot platform. Two 2-DOF arms provided idle gestures.

The most study-relevant custom modules are documented here:

- Gaze display: `ios-gaze-display/`
- Card dispenser: `hardware/clue-dispenser/`
- Voice architecture: `docs/voice-interaction.md`
- Study companion app: `ios-script-distributor/`
- Android reference implementation: `android-script-distributor/`

## iOS Companion App

The HRI experiment used the iOS app in `ios-script-distributor/`. It supports:

- script library browsing
- room creation/joining
- role selection
- role-specific PDF script rendering
- public clue image gallery
- private clue image gallery
- Firebase-backed room synchronization

Setup:

1. Create a Firebase iOS app.
2. Download `GoogleService-Info.plist`.
3. Place it at `ios-script-distributor/Scripts Distributor/GoogleService-Info.plist`.
4. Replace placeholder URLs in `ios-script-distributor/Scripts Distributor/*.json`.
5. Run `pod install` in `ios-script-distributor/`.
6. Open `Scripts Distributor.xcworkspace` in Xcode and run on participant devices.

The released JSON files use placeholder URLs. Preserve the schema when replacing assets:

- `roleScripts`: role name -> act number -> PDF URL
- `publicClueImageURLsDict`: act number -> public clue image URLs
- `privateClueImageURLsDict`: role name -> act number -> private clue image URLs

## Android Reference App

The Android app is retained as a later/parallel implementation reference. It was not the primary app used in the HRI experiment.

Setup:

1. Create a Firebase Android app.
2. Download `google-services.json`.
3. Place it at `android-script-distributor/app/google-services.json`.
4. Replace placeholder URLs in `android-script-distributor/app/src/main/assets/Scripts/*.json`.
5. Open the project in Android Studio and run on Android 7.0+.

The released JSON files use placeholder URLs. Preserve the schema when replacing assets:

- `roleScripts`: role name -> act number -> PDF URL
- `publicClueImageURLsDict`: act number -> public clue image URLs
- `privateClueImageURLsDict`: role name -> act number -> private clue image URLs

## iOS Gaze Display

The iOS app uses:

- `AVCaptureSession` for front camera frames
- `VNDetectFaceLandmarksRequest` from Apple Vision
- normalized eye landmarks to estimate face/gaze position
- bounded eye movement to avoid unnatural offsets
- randomized blinking every 3-7 seconds

Open `ios-gaze-display/EyeTrackingApp.xcodeproj` in Xcode and run on an iPhone. The original study used an iPhone 12 Pro embedded in the robot head.

## Physical Clue Delivery

The physical-card condition used laminated cards, 6.3 cm x 8.8 cm. Private clues were dispensed individually; public cards were dispensed at the table center before script reading started.

Build details are in `hardware/clue-dispenser/README.md`.

## Voice Interaction

The voice module used an ESP32-S3-N16R8 board with:

- INMP441 I2S microphone
- MAX98357 digital amplifier
- 3W speaker
- VAD -> streaming ASR -> Xiaozhi LLM agent -> streaming TTS

See `docs/voice-interaction.md`.

## Experimental Procedure

See `experiment-materials/experimental-protocol.md`.

## Public-Release Checklist

Before pushing publicly:

- Confirm license choice.
- Confirm all images, script text, and clue assets are owned by you or redistributable.
- Replace placeholder Firebase and media URLs.
- Add final CAD files if available.
- Remove any participant data and raw recordings.
