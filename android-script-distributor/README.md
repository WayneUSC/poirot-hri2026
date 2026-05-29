# Android Script Distributor

This Android app was used as the companion interface for script reading, room setup, role selection, and digital clue access.

## Setup

1. Open this folder in Android Studio.
2. Create a Firebase project with Realtime Database enabled.
3. Download your Android `google-services.json`.
4. Put it at `app/google-services.json`.
5. Replace `https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com` in Java code with your Firebase Realtime Database URL.
6. Replace placeholder URLs in `app/src/main/assets/Scripts/*.json` with your role-script PDFs and clue-card images.

## Firebase Data Model

The app writes under:

```text
rooms/{roomId}/public_message
rooms/{roomId}/bot_message/{playerName}
rooms/{roomId}/inRoom/{playerName}
rooms/{roomId}/readyStatus/{deviceId}
```

For a controlled lab study, prefer authenticated devices or a locked-down database. Do not use open public rules in production.

## Script JSON Schema

Each script JSON contains:

- `name`
- `tags`
- `rating`
- `poster`
- `playerInfo`
- `intro`
- `roles`
- `character_posters`
- `acts`
- `roleScripts`
- `publicClueImageURLsDict`
- `privateClueImageURLsDict`

The included JSON files preserve the structure but use placeholder URLs for public release.
