# ConnectCall

Connect with anyone, anywhere.

A 1-to-1 audio/video calling app built in Flutter for the Flutter Development Intern assignment.

## Features

- Email/password sign in and registration (Firebase Authentication)
- Contact list with live online/offline status and search
- 1-to-1 audio calls and video calls (ZEGOCLOUD Express Engine)
- Incoming call screen with accept/decline, 30s ring timeout (auto-missed)
- In-call controls: mute/unmute mic, camera on/off, switch front/rear camera, speaker toggle, end call
- Live network quality indicator (Good / Fair / Poor) during a call
- Call history with direction, duration, and missed/declined/completed status
- Editable profile (display name), logout
- Dark mode
- Runtime permission handling for camera/microphone with graceful denial states

## Tech stack

- **Flutter**, **Dart** — SDK constraint `^3.10.0`
- **State management: GetX** (`get`) — controllers hold reactive (`.obs`) state, `GetView`/`Obx` bind it to the UI, `Bindings` wire up dependencies per route, and `GetMaterialApp` handles navigation. Chosen because it keeps controllers as plain Dart classes (easy to reason about and test), needs no `BuildContext` for navigation/snackbars, and its dependency injection (`Get.put`/`Get.lazyPut`/`Get.find`) removes the boilerplate of `Provider`/`InheritedWidget` trees for a project with this many screens.
- **Backend: Firebase** — Firebase Auth for accounts, Cloud Firestore for the user directory, call invites (signaling), and per-user call history.
- **Calling: ZEGOCLOUD Express Engine** (`zego_express_engine`) — the lower-level ZEGO SDK, used directly rather than the ZEGO prebuilt-call widget. This was a deliberate choice made mid-build: `zego_uikit_prebuilt_call` (the higher-level widget) pulls in an invitation/CallKit subsystem that had a broken transitive dependency at the time of writing and failed to compile. Since call signaling here is already handled through Firestore (see below), the prebuilt widget's invitation system wasn't needed anyway — talking to the Express Engine directly gives full control over the call UI and avoids that broken dependency chain entirely.
- **Local storage:** `get_storage` for the dark mode preference.

## Architecture

```
lib/
├── core/
│   ├── bindings/     GetX Bindings per route (wires controllers + services)
│   ├── config/       app_config.dart — ZEGOCLOUD AppID/AppSign
│   ├── routes/       route names + GetPage list
│   ├── theme/        colors, text styles, light/dark ThemeData
│   └── utils/        call time formatting
├── models/           AppUser, CallRecord, CallInvite (plain Dart, fromMap/toMap)
├── services/         Firebase + ZEGO wrappers — no Flutter/UI imports
├── controllers/      GetxController classes — one per screen/feature
├── screens/          UI only, built on top of controllers via GetView/Obx
├── widgets/          shared, reusable UI pieces
└── main.dart
```

Business logic lives in `services/` (Firebase and ZEGO calls) and `controllers/` (screen state and orchestration). Screens are declarative and read from controllers via `Obx`; they don't talk to Firebase or ZEGO directly. This keeps the UI layer swappable/testable independently of the backend and calling SDK.

## Call signaling (how a call connects)

There's no separate push-notification service wired in, so incoming calls are signaled through Firestore directly, which is already in the stack for auth/user data:

1. Caller writes a `callInvites/{calleeId}` document (status `ringing`) and joins a ZEGO room named after both user IDs.
2. The callee has a permanent `IncomingCallController` (started once, right after login) listening to `callInvites/{myUid}`. A `ringing` invite pushes the Incoming Call screen.
3. Accept → the callee joins the same ZEGO room; both sides are now in the same room and stream to each other.
4. Decline / 30s no-answer / caller cancels → the invite status updates (`declined` / `missed` / `cancelled`) and each side logs its own call history record from its own perspective.

Each client only ever writes to its **own** `callHistory` subcollection — no cross-user writes — so this maps cleanly onto Firestore security rules (not included here, since none were required for the assignment, but the data model was designed with them in mind: a user can only write `users/{their own uid}/callHistory/*` and `callInvites/{their own uid}`).

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Firebase

1. Create a free Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Authentication → Email/Password**.
3. Create a **Cloud Firestore** database (test mode is fine for trying this out).
4. Install the FlutterFire CLI and run it from the project root:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` with your project's real config and registers the Android/iOS apps. Until this is run, the app builds and runs fine — it just can't sign in (the login/register screens will show a connection error).

### 3. ZEGOCLOUD

1. Create a free account at [console.zegocloud.com](https://console.zegocloud.com) (free tier: 10,000 minutes/month).
2. Create a project and copy its **AppID** and **AppSign**.
3. Paste them into `lib/core/config/app_config.dart`:
   ```dart
   static const int zegoAppId = <your app id>;
   static const String zegoAppSign = '<your app sign>';
   ```
   Until this is set, tapping a call button shows a "Calling not configured" message instead of crashing.

### 4. Run

```bash
flutter run
```

Test calling end-to-end with two accounts on two devices/emulators (or one physical device + one emulator, since two instances on the same simulator can't both hold a microphone).

## Known limitations

- Incoming calls only work while the app is running (foreground or backgrounded but alive) — there's no push-notification wake for a fully killed app, since that needs a server-side push component (FCM + a Cloud Function, or ZEGO's invitation/CallKit plugin) which was out of scope for the signaling approach used here.
- Call duration recorded for the caller includes ringing/wait time up to the callee joining, not just "connected" time — a reasonable approximation for a call log entry.
- No group calling, screen sharing, or call recording (all listed as bonus/optional in the assignment).
- Firestore security rules are not included in this repo; the data model was designed so each user only ever writes their own documents, but rules still need to be authored and deployed for production use.

## AI tools used

Built with Claude Code (Anthropic), including the ZEGOCLOUD Express Engine API surface look-ups against the installed package source (to avoid guessing at API shapes) and the debugging session that traced the splash-screen redirect bug back to `SplashController` never being instantiated under `Get.lazyPut`.
