# Firebase Setup Guide for TwendeMarket

## 1. Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add project" → Name it `twendemarket`
3. Enable Google Analytics (optional)

## 2. Add Android App
- Package name: `com.example.twendemarket`
- Download `google-services.json`
- Place it in `android/app/`

## 3. Add iOS App
- Bundle ID: `com.example.twendemarket`
- Download `GoogleService-Info.plist`
- Add it to `ios/Runner/` in Xcode

## 4. Enable Firebase Services
Go to Firebase Console and enable:
- **Authentication** → Email/Password
- **Firestore Database** → Start in test mode
- **Storage** (for product images)
- **Cloud Messaging** (for push notifications)

## 5. Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    // Anyone authenticated can read products
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    // Users can create orders, admins can update
    match /orders/{orderId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 6. Make a User Admin
After registering your first admin account, go to:
Firestore → users → [your-user-id] → edit `role` field to `"admin"`

## 7. Add Flutter Firebase Packages
```bash
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage firebase_messaging
flutterfire configure
```
