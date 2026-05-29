# iOS Script Distributor

This is the iOS companion app used in the HRI study for room setup, role selection, script reading, act progression, and digital clue access.

## Role in the Study

The experiment used this iOS app, not the Android implementation, as the participant-facing script and clue distribution interface. The Android folder in this repository is retained as a later/parallel implementation reference.

## Included Public Assets

This public package keeps the *Judgment Quartet* / `审判四重奏` study materials needed to reproduce the app workflow:

- `审判四重奏-A.json`
- `审判四重奏-B.json`
- `Quartet of Judgment-A.json`
- `Quartet of Judgment-B.json`
- corresponding Chinese/English role portraits and posters

The JSON files preserve the original schema, but role-script PDF URLs and clue-image URLs have been replaced with placeholders. Replace `https://example.com/role-script.pdf` and `https://example.com/clue-card.jpg` with redistributable study assets before running a full replication.

## Setup

1. Install CocoaPods if needed.
2. Create a Firebase iOS app with Realtime Database enabled.
3. Download `GoogleService-Info.plist`.
4. Place it at `Scripts Distributor/GoogleService-Info.plist`.
5. Run:

```bash
pod install
```

6. Open `Scripts Distributor.xcworkspace` in Xcode.
7. Build and run on iPhone/iPad devices used by participants.

## Firebase Data Model

The app writes room state under:

```text
rooms/{roomID}/players
rooms/{roomID}/selectedRoles
rooms/{roomID}/playerRoles/{playerID}
rooms/{roomID}/readyStatus/{playerID}
rooms/{roomID}/playerReadyStatus/{playerID}
rooms/{roomID}/currentAct
```

Use locked-down Firebase rules for real studies. The provided `GoogleService-Info.plist.example` is only a placeholder.

## Main Source Files

- `ScriptsLibraryController.swift`: study script listing.
- `ScriptsDetailController.swift`: script overview and room entry.
- `CreateRoomViewController.swift` / `JoinRoomViewController.swift`: room setup.
- `RoleSelectionViewController.swift`: synchronized role selection.
- `GameViewController.swift`: PDF script display and act readiness.
- `CluesViewController.swift`: public/private clue image display.
- `Script.swift`: JSON schema models.
