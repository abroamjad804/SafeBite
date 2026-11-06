# SafeBite
## AI-Driven Mobile Application for Personalized Food Ingredient Analysis and Health and Nutrition RecommendationsUsing RAG, LLMs, and Contextual Intelligence

SafeBite is a Flutter-based Android application prototype that helps users review packaged-food ingredient labels in the context of their personal dietary profile. Users can create a local profile, record allergies and dietary preferences, scan or select an ingredient-label image, review recognized ingredients, and receive a Personal Health Suitability Score (PHSS) with explanatory warnings.
Project status: Academic / FYP prototype. The current implementation uses on-device OCR and a bundled starter ingredient dataset. It is not a clinically validated medical or nutrition assessment tool.

Final Year Project, BS Computer Science (Batch 23), Department of Computer science, Sukkur IBA University.
Supervisor: Dr. Saif Hassan

## Contents
## 📑 Table of Contents

| No. | Documentation Section |
|:---:|---|
| 01 | [🚀 Key Features](#-key-features) |
| 02 | [⚙️ How It Works](#-how-it-works) |
| 03 | [📊 PHSS Calculation](#-phss-calculation) |
| 04 | [💻 Technology Stack](#-technology-stack) |
| 05 | [📁 Project Structure](#-project-structure) |
| 06 | [📋 Requirements](#-requirements) |
| 07 | [🛠️ Setup and Run](#-setup-and-run) |
| 08 | [📱 Build an Android APK](#-build-an-android-apk) |
| 09 | [🗂️ Dataset](#-dataset) |
| 10 | [⚠️ Current Limitations](#-current-limitations) |
| 11 | [🔒 Privacy and Security](#-privacy-and-security) |
| 12 | [📌 Disclaimer](#-disclaimer) |

  ## Demo Video
  [▶ Watch Project Demo](https://github.com/abroamjad804/SafeBite/blob/298269be863c2caae3b00912ad23600d22f9945a/SafeBite_Demo.mp4)

# Software Requirements Specification (SRS)

[📄 View SRS Document](https://github.com/abroamjad804/SafeBite/blob/38081e519871fb35295e0e5204ed4e0c9de5711d/Software_Requirements_Specification(SRS).pdf)
# Software Design Specification (SDS)
[📄 View SDS Document](https://github.com/abroamjad804/SafeBite/blob/7ba8540cbcb76f744e3b570a84afa20e4d042c59/Software_Design_Specifications(SDS).pdf)
## Key features
## 🚀 Key Features
| # | Feature | Description |
|:---:|---|---|
| 1 | **Local Account Management** | Supports user registration, sign-in, and guest access for a flexible authentication experience. |
| 2 | **Personal Health Profile** | Allows users to manage personal details, allergies, ingredients to avoid, dietary requirements, nutrition goals, and dietary preferences. |
| 3 | **Ingredient Label OCR** | Enables users to capture or upload product ingredient labels and extract text using Google ML Kit Text Recognition on supported mobile platforms. |
| 4 | **Ingredient Matching** | Matches extracted ingredient names and their aliases against the locally bundled CSV ingredient dataset. |
| 5 | **Personalized Health Assessment** | Calculates the Personal Health Suitability Score (PHSS) based on ingredient information and individual health profile settings. |
| 6 | **Result Classification** | Displays clear assessment categories: **Safe, Caution, or Avoid**, along with explanations, relevant reasons, and warnings. |
| 7 | **Unmatched Ingredient Detection** | Identifies ingredients that are not available in the local dataset and highlights them for manual verification. |
| 8 | **Scan History Management** | Stores previous ingredient analysis results locally and allows users to review or delete saved scan history entries. |
| 9 | **Flutter-Based User Interface** | Provides a modern Material Design interface with reusable UI components, consistent styling, and a customized application theme. |

---
## How it works
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



## Setup and run
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
## Build with GitHub Actions
This repository includes .github/workflows/build-apk.yml.
1. Push the contents of the safebite_app folder to a GitHub repository.
2. Open the repository's Actions tab.
3. Select Build Android APK and run the workflow using Run workflow (or push to main / master).
4. When the workflow completes, open the workflow run.
5. Download the safebite-apk artifact.
The workflow installs Java 17 and Flutter, fetches dependencies, builds the release APK, and uploads the APK as an artifact.
## Dataset
The starter ingredient dataset is located at:
assets/datasets/ingredients.csv
The current matching logic uses the ingredient name, aliases, and category columns. Keep the CSV header and expected column order consistent with the implementation when editing it. Use reliable, traceable sources when adding ingredient information, and review the dataset before project evaluation or public release.




## UI
## 🎨 UI Design System

| # | Component | Description |
|:---:|---|---|
| 1 | **Icon3D** | Provides soft-depth 3D-style icons using Material Rounded iconography. |
| 2 | **RaisedCard** | Creates elevated card layouts with subtle shadows and a soft-depth visual appearance. |
| 3 | **GradientButton** | Provides gradient-styled buttons for attractive and interactive user actions. |
| 4 | **ScoreRing** | Displays PHSS scores using a circular progress indicator. |
| 5 | **StatusPill** | Displays assessment statuses such as Safe, Caution, and Avoid using styled status indicators. |
| 6 | **ProductThumb** | Provides thumbnail previews for product images. |

**Implementation:** `lib/presentation/widgets/common/fx.dart`

**Design Style:** Soft-depth 3D design system with Material Rounded icons. All icons use Material Rounded iconography instead of emojis.

---
## Run
    flutter pub get
    flutter run

## Build an APK without Android Studio
Push this folder to a GitHub repo, open Actions, run "Build Android APK",
then download `safebite-apk` from the run's Artifacts.

## SafeBite OCR implementation notes

## ⚙️ Technical Details, Limitations & Setup

| # | Category | Description |
|:---:|---|---|
| 1 | **Authentication** | Authentication is currently a local prototype using SharedPreferences and SHA-256 password hashes. It is not a production-ready account service. A secure backend such as Firebase Auth, Supabase, or a custom API is required before deployment. |
| 2 | **Signup Requirements** | Registration collects the user's full name, age, email, and password. Passwords must contain 8–12 characters, including uppercase letters, lowercase letters, and numeric characters. |
| 3 | **Guest Access** | Guest sessions are stored locally and allow users to create and manage their health profiles without registering for a demo account. |
| 4 | **Health Profile Storage** | Health profile information is entered manually by users and saved locally after each update. Profile photos can be selected from the device gallery and stored locally. |
| 5 | **OCR Compatibility** | Ingredient-label text recognition uses Google ML Kit Text Recognition on Android and iOS. Web builds currently display an availability message because the OCR plugin supports mobile platforms only. |
| 6 | **Ingredient Dataset** | The starter ingredient dataset is located at `assets/datasets/ingredients.csv`. It should be replaced or expanded with the verified project dataset before evaluation. The application does not fabricate ingredient data. |
| 7 | **PHSS Calculation** | The Personal Health Suitability Score (PHSS) is calculated using recognized ingredient signals and the user's health profile. |
| 8 | **Nutrition Data Limitation** | OCR currently does not extract nutrition facts. Therefore, nutrition-based assessment factors may be incomplete, and the application displays a relevant warning. |
| 9 | **Unmatched Ingredients** | Ingredients that cannot be matched with the local dataset are explicitly flagged for manual verification. |
| 10 | **Dependency Installation** | Run `flutter pub get` after extracting the project to install the required Flutter dependencies. |
| 11 | **Application Execution** | Run `flutter run` to launch the application on a connected Android device or emulator. |
| 12 | **Camera Permission** | Camera permission is already declared in the Android manifest for capturing ingredient-label images. |

---

## ▶️ Getting Started

Run the following commands in your project terminal:

```bash
flutter pub get
flutter run
