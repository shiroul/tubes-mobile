# Firebase Setup for LINA Disaster Management App

## Required Firebase Services
- Firebase Authentication
- Cloud Firestore
- Firebase Storage (for images via Cloudinary)

## Setup Steps

### 1. Firebase Project Setup
1. Go to https://console.firebase.google.com/ and create a new project (or use an existing one).
2. Register your app (Android/iOS/Web) in the Firebase console.
3. Download the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - `firebase_options.dart` for Flutter

### 2. Firestore Database Setup
1. Create a Firestore database in Firebase Console
2. Set up the following collections:
   - `users` - User profiles and roles
   - `events` - Disaster relief events
   - `reports` - Disaster reports from users
   - `volunteer_registrations` - User registrations for events

### 3. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // All authenticated users can read events
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Add role-based restrictions as needed
    }
    
    // Users can create reports, admins can read all
    match /reports/{reportId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
    
    // Users can register for events
    match /volunteer_registrations/{regId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Required Firestore Indexes
The app requires composite indexes for optimal performance. Use the `firestore.indexes.json` file in the project root to deploy indexes:

```bash
firebase deploy --only firestore:indexes
```

Or manually create these indexes in Firebase Console:
- **volunteer_registrations**: `userId` (ascending) + `registeredAt` (descending)
- **events**: `status` (ascending) + `date` (descending)  
- **reports**: `uid` (ascending) + `timestamp` (descending)

### 5. Initialize Firebase
Ensure Firebase is initialized in `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

## Troubleshooting

### Index Errors
If you see "The query requires an index" errors:
1. Click the provided link in the error message, OR
2. Go to Firebase Console > Firestore > Indexes
3. Create the required composite index
4. Wait for index creation to complete (may take several minutes)

### Authentication Issues
- Ensure authentication methods are enabled in Firebase Console
- Check that `google-services.json` is properly placed and up to date

### Build Issues
- Clean and rebuild the project after adding Firebase configuration files
- Ensure all required dependencies are in `pubspec.yaml`
