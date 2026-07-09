# Wavemart FCM (Push Notification) Implementation Guide

This document outlines the setup and architecture for the Firebase Cloud Messaging (FCM) integration which replaces the previous battery-intensive polling system.

---

## 1. Firebase Console Setup

1.  **Project**: Create/Select your project at [console.firebase.google.com](https://console.firebase.google.com/).
2.  **Android/iOS Apps**: Add your apps to the project.
3.  **Service Account (For Backend)**:
    *   Settings (Gear Icon) > Project Settings > Service accounts.
    *   Click **Generate new private key**.
    *   Save this JSON file. You will need it for the Laravel backend.

---

## 2. Flutter Mobile Setup

### Configuration
1.  Ensure you have the Firebase CLI installed: `npm install -g firebase-tools`.
2.  Log in: `firebase login`.
3.  Run the FlutterFire CLI in the root of the flutter project:
    ```bash
    flutterfire configure
    ```
4.  This generates `lib/firebase_options.dart` and adds native config files.

### Critical Files
*   **`lib/main.dart`**: Initializes Firebase and starts the FCM service upon authentication.
*   **`lib/data/services/fcm_service.dart`**: Main listener for foreground/background messages.
*   **`lib/data/services/fcm_api_service.dart`**: Registers the device token with the Laravel backend.

---

## 3. Laravel Backend Setup

### Environment Configuration
1.  Store your Service Account JSON in `storage/app/firebase-auth.json`.
2.  Add to your `.env`:
    ```env
    FIREBASE_CREDENTIALS=storage/app/firebase-auth.json
    ```

### Architecture
*   **Table**: `user_devices` stores `fcm_token` and `platform` (android, ios, web).
*   **Controller**: `FcmController@registerToken` handles token submission from the app.
*   **Service**: `FcmService.php` handles the actual sending logic using `kreait/laravel-firebase`.
*   **Integration**: `NotificationService.php` has been updated to automatically trigger an FCM push whenever an in-app notification is created.

---

## 4. Message Payloads

The Flutter app expects specific data payloads to trigger the **Incoming Call Overlay**.

**Incoming Call Payload:**
```json
{
  "title": "Incoming Audio Call",
  "body": "User Name is calling you...",
  "data": {
    "type": "incoming_call",
    "conference_id": "123",
    "caller_name": "John Doe",
    "caller_initials": "JD",
    "listing_title": "Modern Apartment"
  }
}
```

---

## 5. Transitioning from Polling

Once FCM is fully configured:
1.  **Incoming Calls**: You can safely disable `startPolling()` in `IncomingCallNotifier`.
2.  **Unread Counts**: You can disable polling in `unreadMessagesCountProvider` and `unreadNotificationsCountProvider`.
3.  **Web Dashboard**: Implement the same registration logic in the JavaScript dashboard to receive desktop popups.

## 6. Troubleshooting
*   **Android**: If notifications don't show when the app is closed, ensure you have an `intent-filter` in your `AndroidManifest.xml`.
*   **iOS**: Ensure you have uploaded your APNs (.p8) key to the Firebase Console.
*   **Shared Hosting**: If notifications fail to send, ensure your host allows outgoing connections to `fcm.googleapis.com` on Port 443.
