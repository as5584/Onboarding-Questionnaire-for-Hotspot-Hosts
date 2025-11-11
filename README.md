
# Luminus

# Flutter Onboarding Questionnaire for Hotspot Hosts

This project is a **Flutter application** designed to guide potential hotspot hosts through an engaging onboarding process. It includes two main screens — **Experience Type Selection** and an **Onboarding Question Screen** — complete with **audio and video recording** capabilities.

---

## 🚀 Features Implemented

### 1. Experience Type Selection Screen:
- Fetches a list of experiences from the API endpoint:  
  `https://staging.chamberofsecrets.8club.co/v1/experiences?active=true`
- Displays experiences as **interactive “stamp-like” cards**.
- Supports **multiple selection** of experience types.
- Unselected experience cards appear in **grayscale**.
- Includes a **text field** (max 250 characters) for users to describe their ideal hotspot.
- Navigates to the **Onboarding Question Screen** upon tapping **Next**.

### 2. Onboarding Question Screen:
- Users can answer questions using:
  - **Text input** (max 600 characters)
  - **Audio recording** (with live waveform)
  - **Video recording**
- Supports:
  - Canceling or stopping recordings.
  - Deleting recorded assets.
  - Playback of recorded audio/video with custom UI controls.
- Features:
  - A **custom animated wavy line progress indicator** in the AppBar.
  - Dynamic layout adjustments based on recording state.
  - A **visually rich dark theme** aligned with Figma design specifications.

---

## ✨ Brownie Points (Optional Enhancements)

### 🎨 UI/UX - Pixel Perfect Design
- Achieved a **high-fidelity implementation** of the provided Figma mockups:
  - Custom **AppBar gradient** for the title.
  - **Dark theme** with nuanced shadows, rounded corners, and contrasts.
  - **Stamp-style cards** using clipping and grayscale shaders.
  - **Animated gradient text** for buttons.
  - A refined **audio/video playback UI** with animations and transitions.

### 🧩 Animations
- Smooth scroll animation to bring the **selected card** to the front.
- Animated **Next button width transitions** based on the recording state.

### ⚙️ State Management
- Uses `setState` for simple, efficient state management.  
  *(If migrating to Riverpod/BLoC in future, update this section.)*

### 🌐 API Client
- Built using a custom lightweight `ApiService` for network communication.  
  *(Replace with `Dio` for more advanced request handling or interceptors if needed.)*

---

## 🧭 Getting Started

Follow these steps to set up and run the project on your local machine.

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>
````

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Run the Application

Connect your device or start an emulator, then run:

```bash
flutter run
```

### 4️⃣ Optional: Build Release APK

To generate a release build:

```bash
flutter build apk --release
```

---

## 🧩 Project Structure

The codebase follows standard Flutter conventions for scalability and clarity:

```
lib/
│
├── screens/
│   ├── experience_selection_screen.dart
│   └── onboarding_question_screen.dart
│
├── services/
│   └── api_service.dart
│
├── widgets/
│   ├── experience_card.dart
│   ├── waveform_visualizer.dart
│   └── custom_progress_indicator.dart
│
└── main.dart
```

---

## 🧠 Notes on Implementation

* **Error Handling:**
  Comprehensive try–catch blocks and user-friendly error prompts for failed API calls and permission denials.

* **Media Permissions:**
  Microphone and camera permissions are requested dynamically at runtime.

* **Recording Functionality:**
  Audio and video features use platform-specific implementations ensuring smooth recording and playback on both Android and iOS.

* **Responsiveness:**
  All screens are fully responsive, adapting seamlessly across screen sizes.

* **Code Quality:**
  Organized, modular, and documented to ease future feature additions and state management upgrades.

---

```

