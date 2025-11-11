# luminus

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
git clone https://github.com/as5584/Onboarding-Questionnaire-for-Hotspot-Hosts.git
cd <Onboarding-Questionnaire-for-Hotspot-Hosts>

     Install dependencies:

      bash

    Copy
    flutter pub get
    Run the application:

    bash

    Copy
    flutter run

    ### Notes on Implementation

- The project structure follows standard Flutter practices with screens organized into `lib/screens/`.
- Error handling for API calls and permissions is included.

### How to Use This README

1. **Replace Placeholders:**
   - Replace `flutter-onboarding-questionnaire` in the "Clone the repository" step with your actual repository name.
   - Replace `<your-github-repo-url>` with the URL of your GitHub repository.
   - If you implemented Riverpod/BLoC or integrated Dio, update the "State Management" and "API Client" sections accordingly.

2. **GitHub Repository:**
   - Ensure your GitHub repository is public or accessible to the reviewer.

3. **Screen Recording:**
   - Prepare a short demo video showcasing the app's functionality, especially the onboarding flow, recording features, and UI elements.
