# BookVerse

BookVerse is a Flutter-based PDF reading and library management app designed for students and learners who need quick access to study materials, lecture notes, and textbooks in one place.

## Features

- Welcome screen and onboarding-style entry flow
- Home dashboard with quick stats and recently opened materials
- Library screen with category filters and search
- In-app PDF reader for online PDF URLs and local files
- On-device PDF library with import, reading progress, and removal
- In-document text search and PDF table of contents
- Bookmarks, notes, and reading progress synced to the signed-in profile
- Profile and settings screens for personalization

## Project goal

This app was developed as a varsity project to provide a clean mobile reading experience for digital study resources, making PDF management feel more organized and user-friendly.

## Getting started

1. Install Flutter SDK.
2. Run `flutter pub get` in the project root.
3. Launch the app with `flutter run`.
4. To verify the app behavior, run `flutter test`.

## Tech stack

- Flutter
- Dart
- Material 3 design system

## Firebase setup

The app uses Firebase Authentication for email/password accounts and Cloud
Firestore for the book catalogue, profile, favorites, bookmarks, notes, reading
progress, and settings. No demo credentials or hard-coded book catalogue are
used.

1. Create a Firebase project in the Firebase Console.
2. Enable **Authentication > Email/Password** and create a **Cloud Firestore**
   database.
3. Register the Android app with application ID `com.example.bookverse` and
   place its `google-services.json` at `android/app/google-services.json`. The
   Android Gradle plugin reads this file when building the app. For iOS, add
   the matching `GoogleService-Info.plist` to the Runner target.
4. Deploy `firestore.rules` to that Firebase project's Firestore database.
   If Firebase CLI commands fail with HTTP 401, refresh the local CLI login
   with `firebase login --reauth`.
5. For web, register a web app, get its configuration from Project settings,
   and run `flutter run -d chrome` with these Dart defines (replace the values
   with your project's configuration):

```powershell
flutter run -d chrome `
  --dart-define=FIREBASE_API_KEY=your-api-key `
  --dart-define=FIREBASE_PROJECT_ID=your-project-id `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id `
  --dart-define=FIREBASE_WEB_APP_ID=your-web-app-id `
  --dart-define=FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com `
  --dart-define=FIREBASE_STORAGE_BUCKET=your-storage-bucket
```

Android and iOS use their native Firebase configuration files. If web Firebase
configuration is missing, the app shows a setup screen instead of pretending
that sign-in or database operations succeeded.

Registering a user creates a private `users/{uid}` profile. Add books from the
Library screen; the book documents are stored in the top-level `books`
collection and are readable only by the account that created them. Imported
PDFs are stored in a separate app documents directory for each signed-in
account and remain on that device; they are not uploaded to Firebase. On web,
imported PDFs remain available for the current session and are separated by
account. Local PDFs imported before account-specific storage was added had no
saved owner, so re-import those files while signed in to the intended account.

A PDF URL is visible only through its owner's book record in BookVerse.
However, an external HTTP(S) URL that is publicly accessible is not made
private by Firestore rules; anyone who already has that URL may be able to open
it outside the app. To protect PDF bytes themselves, store them in Firebase
Storage with authenticated owner-only Storage rules rather than using a public
download URL.

Firestore layout:

- `books/{bookId}`: book details and optional PDF URL/content
- `users/{uid}`: profile fields
- `users/{uid}/favorites/{bookId}`
- `users/{uid}/bookmarks/{bookId}`
- `users/{uid}/reading_history/{bookId}`
- `users/{uid}/notes/{bookId}`

The `books` documents include `title`, `author`, `category`, `description`,
`content`, `pdfUrl`, `page`, `total`, `color`, `rating`, `date`, `size`,
`createdBy`, and `createdAt`. The Library screen can create book documents
without using the Firebase console; each created document is owned by the
signed-in user and readable, updateable, or removable only by that owner under
the included rules. Deploy the updated `firestore.rules` to apply this policy.

For step-by-step instructions on adding a book category in Firestore, see
[FIREBASE_CATEGORIES.md](./FIREBASE_CATEGORIES.md).

## Source layout

- `lib/main.dart` is the Flutter entry point.
- `lib/app.dart` configures the app and its theme.
- `lib/ui/screens/` contains each application screen.
- `lib/ui/widgets/` contains shared UI widgets.
- `lib/models/`, `lib/data/`, and `lib/viewmodels/` hold the app's data model and state logic.
- `lib/services/local_book_repository.dart` selects persistent device storage
  or session storage for imported PDFs, depending on the platform.
