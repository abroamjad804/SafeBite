# SafeBite

AI-driven food ingredient analysis. Scan a barcode, get a Personal Health Suitability Score (PHSS) based on your allergies, dietary needs and goals.

## UI
Soft-depth "3D" design system in `lib/presentation/widgets/common/fx.dart`:
`Icon3D`, `RaisedCard`, `GradientButton`, `ScoreRing`, `StatusPill`, `ProductThumb`.
All icons are Material Rounded icons (no emoji).

## Run
    flutter pub get
    flutter run

## Build an APK without Android Studio
Push this folder to a GitHub repo, open Actions, run "Build Android APK",
then download `safebite-apk` from the run's Artifacts.

## SafeBite OCR implementation notes

- Authentication is currently a **local prototype** using SharedPreferences and SHA-256 password hashes. It is not a production account service; connect a secure backend (Firebase Auth/Supabase/custom API) before deployment.
- Signup collects full name, age, email and a password of 8–12 characters containing uppercase, lowercase and numeric characters.
- Guest sessions are stored locally and can build a health profile without a demo account.
- Health profile entries are user-typed and saved after each update. Profile photos are selected from the gallery and stored locally.
- Ingredient-label OCR uses Google ML Kit Text Recognition on Android/iOS. Web builds currently show an availability message because this OCR plugin is mobile-only.
- The starter ingredient dataset is `assets/datasets/ingredients.csv`. Replace/expand it with the verified project dataset before evaluation. No ingredient data is fabricated by the app.
- PHSS is calculated from the recognized ingredient signals and profile. OCR does not currently extract nutrition facts, so the result includes a warning that nutrition-based factors may be incomplete. Unmatched ingredients are explicitly flagged for verification.
- Run `flutter pub get` after extracting the project, then `flutter run` on an Android device/emulator. Camera permission is already declared in the Android manifest.
