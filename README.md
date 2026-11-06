SafeBite
AI-driven food ingredient analysis and personalized health suitability assessment

SafeBite is a Flutter-based Android application prototype that helps users review packaged-food ingredient labels in the context of their personal dietary profile. Users can create a local profile, record allergies and dietary preferences, scan or select an ingredient-label image, review recognized ingredients, and receive a Personal Health Suitability Score (PHSS) with explanatory warnings.
Project status: Academic / FYP prototype. The current implementation uses on-device OCR and a bundled starter ingredient dataset. It is not a clinically validated medical or nutrition assessment tool.

Contents
- Key features
- How it works
- PHSS calculation
- Technology stack
- Project structure
- Requirements
- Setup and run
- Build an Android APK
- Dataset
- Current limitations
- Privacy and security
- Disclaimer
Key features
- Local account flow: Sign up, sign in, or continue as a guest.
- Personal health profile: Maintain profile details, allergies, ingredients to avoid, dietary needs, nutrition goals, and dietary preferences.
- Ingredient-label OCR: Select or capture a label image and extract text using Google ML Kit Text Recognition on supported mobile platforms.
- Ingredient matching: Compare extracted ingredient names and aliases against the bundled CSV dataset.
- Personalized assessment: Calculate a PHSS using the available ingredient signals and profile settings.
- Clear result categories: Present a Safe, Caution, or Avoid result, along with reasons and warnings.
- Unmatched ingredient warnings: Explicitly identify ingredients that are not present in the local dataset so they can be checked manually.
- Scan history: Save previous analysis results locally and review or remove history entries.
- Flutter UI: Material-based interface with reusable visual components and app theme.
How it works
1. Create a profile or continue as guest.
2. Set personal preferences. Add allergies, avoid-list items, dietary needs, nutrition goals, and dietary preferences.
3. Scan an ingredient label. Choose an image containing the product's ingredient list.
4. Extract label text. Google ML Kit performs text recognition on the device.
5. Match ingredients. The extracted text is cleaned, split into ingredient tokens, and compared with names and aliases in assets/datasets/ingredients.csv.
6. Calculate PHSS. The app evaluates the matched ingredient signals against the user's profile.
7. Review the result. The result screen displays the suitability category, score, reasons, and any verification warnings. A scan can be saved to local history.
PHSS calculation
The current scoring implementation is in lib/core/utils/phss_calculator.dart.

The weighted score is:
PHSS = (0.40 × H) + (0.30 × N) + (0.20 × D) + (0.10 × G)
Component	Weight	Purpose
H — Health-related dietary needs	40%	Checks supported dietary needs against available nutrition values
N — Nutrition goals	30%	Evaluates supported goals such as reducing sugar or calories
D — Dietary preferences	20%	Checks supported preferences such as vegetarian or vegan
G — General ingredient suitability	10%	Applies the current list of ingredient/additive signals


Current score labels:
- Safe: score of 80 or above
- Caution: score from 50 to below 80
- Avoid: score below 50
- Allergen hard constraint: if a declared allergen is detected in the ingredient names, the product is immediately marked Avoid with a score of 0.
The calculation is a prototype rule-based assessment. It should not be interpreted as a medical diagnosis, guarantee of safety, or substitute for checking the package label and consulting a qualified professional.
Technology stack
Area	Technology
Mobile app framework	Flutter / Dart
UI	Flutter Material, Google Fonts
Navigation	GoRouter
State management	Provider
OCR	Google ML Kit Text Recognition
Local persistence	SharedPreferences
Password hashing in prototype	crypto (SHA-256)
Image selection	image_picker
Charts / visual elements	fl_chart and reusable custom widgets
Ingredient data	CSV asset


Project structure
safebite_app/
├── android/                         # Android platform project
├── assets/
│   └── datasets/
│       └── ingredients.csv          # Starter ingredient names and aliases
├── lib/
│   ├── core/
│   │   ├── constants/                # App constants
│   │   ├── theme/                    # App theme
│   │   └── utils/                    # Routing and PHSS calculation
│   ├── data/
│   │   ├── models/                   # User, product, and scan-history models
│   │   ├── providers/                # Authentication and scan state
│   │   └── services/                 # OCR platform implementations
│   ├── presentation/
│   │   ├── screens/                  # App screens
│   │   └── widgets/                  # Reusable UI components
│   └── main.dart                     # Application entry point
├── test/                             # Flutter tests
├── .github/workflows/
│   └── build-apk.yml                 # GitHub Actions APK workflow
├── pubspec.yaml                      # Dependencies and assets
└── README.md
Requirements
- Flutter SDK compatible with the Dart constraint in pubspec.yaml (^3.13.7).
- Android SDK and Android toolchain configured.
- Android device or emulator for testing.
- USB debugging enabled if running on a physical Android phone.
Check your Flutter installation:
flutter doctor
Setup and run
1. Extract the project ZIP.
2. Open a terminal in the safebite_app project directory (the directory containing pubspec.yaml).
3. Install dependencies:
   flutter pub get
4. Check connected devices:
   flutter devices
5. Run the application:
   flutter run
To run on a particular device:
flutter run -d <device_id>
Build an Android APK
Build a release APK locally:
flutter build apk --release
The APK is generated at:
build/app/outputs/flutter-apk/app-release.apk
Build with GitHub Actions
This repository includes .github/workflows/build-apk.yml.
1. Push the contents of the safebite_app folder to a GitHub repository.
2. Open the repository's Actions tab.
3. Select Build Android APK and run the workflow using Run workflow (or push to main / master).
4. When the workflow completes, open the workflow run.
5. Download the safebite-apk artifact.
The workflow installs Java 17 and Flutter, fetches dependencies, builds the release APK, and uploads the APK as an artifact.
Dataset
The starter ingredient dataset is located at:
assets/datasets/ingredients.csv
The current matching logic uses the ingredient name, aliases, and category columns. Keep the CSV header and expected column order consistent with the implementation when editing it. Use reliable, traceable sources when adding ingredient information, and review the dataset before project evaluation or public release.
Current limitations
- Prototype authentication: Accounts and profile data are stored on the device using SharedPreferences. There is no secure remote authentication service or multi-device account synchronization.
- Local storage: User profile and scan history are device-local and may be lost if app data is cleared or the app is uninstalled.
- OCR accuracy: Recognition depends on image quality, lighting, focus, label layout, and supported text. Always verify extracted text against the physical package.
- Ingredient coverage: The bundled CSV is a starter dataset, not a complete ingredient reference. Unmatched ingredients are flagged for manual verification.
- Nutrition information: The current OCR flow extracts ingredient text; it does not reliably extract nutrition facts. Consequently, nutrition-based PHSS components may be incomplete and the app displays a warning.
- Matching approach: Current matching is based on normalized exact names and aliases; it is not a full semantic or AI/LLM-based ingredient understanding system.
- Platform support: Google ML Kit text recognition is mobile-specific. Web builds use a platform stub and do not provide the same OCR functionality.
- Not clinically validated: The PHSS weights, thresholds, and ingredient signals are prototype rules and have not been clinically validated.
Privacy and security
This prototype stores account information, profile details, and scan history locally on the device. Passwords are hashed with SHA-256 in the local prototype, but this is not a production-grade authentication design. Do not use real or sensitive personal information in a demonstration build.

Before production deployment, implement a secure backend, use a modern password-hashing scheme on the server (with a unique salt and an appropriate work factor), protect data in transit and at rest, define retention/deletion policies, and obtain informed consent for any personal data processing.
Disclaimer
SafeBite is an educational software prototype intended to demonstrate personalized ingredient-label analysis. It does not provide medical advice and cannot guarantee that a food product is safe for any individual. Ingredient labels and manufacturing practices can change, OCR and dataset matching can be incomplete, and cross-contamination information may not be captured. Users should verify the complete package information and consult a qualified healthcare professional or dietitian for individual medical or dietary decisions.
Contributing
For project development:
1. Create a feature branch.
2. Make focused changes and run relevant checks.
3. Test on a physical Android device where possible, especially OCR and image selection.
4. Submit a pull request with a short description and screenshots for UI changes.
License
No license has been specified for this project. All rights remain with the project owners unless a license is added.

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
=======
AI-powered personalized food ingredient analysis application
>>>>>>> 0ddad54ba83cd1b0bb68db3b5f0cb76d79577839
