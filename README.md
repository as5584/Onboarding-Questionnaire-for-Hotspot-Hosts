# luminus

# Flutter Onboarding Questionnaire for Hotspot Hosts

This project is a Flutter application designed to guide potential hotspot hosts through an onboarding questionnaire. It consists of two main screens: Experience Type Selection and an Onboarding Question Screen with audio/video recording capabilities.

## 🚀 Features Implemented

### 1. Experience Type Selection Screen:
*   Fetches a list of experiences from a provided API (`https://staging.chamberofsecrets.8club.co/v1/experiences?active=true`).
*   Displays experiences as interactive "stamp-like" cards.
*   Allows users to select multiple experience types.
*   Unselected experience cards display images in grayscale.
*   Includes a text field for users to describe their ideal hotspot (max 250 characters).
*   Navigates to the next screen upon pressing "Next".

### 2. Onboarding Question Screen:
*   Allows users to answer a question using text input (max 600 characters).
*   Supports recording audio answers with a live waveform visualization.
*   Supports recording video answers.
*   Provides options to cancel or stop audio/video recordings.
*   Allows deletion of recorded audio or video assets.
*   Displays recorded audio/video with playback controls (play/pause, progress bar).
*   Includes a dynamic UI that adjusts based on recording status and recorded assets.
*   Features a custom animated wavy line progress indicator in the AppBar.
*   Implements a visually appealing dark theme and custom UI elements matching the provided Figma design.

## ✨ Brownie Points (Optional Enhancements)

*   **UI/UX - Pixel Perfect Design:**
    *   Achieved a design closely matching the provided Figma mockups, including:
        *   Custom gradient for the AppBar title.
        *   Dark theme with specific background colors and rounded corners.
        *   "Stamp-like" UI for experience cards with custom clipping and grayscale effect.
        *   Animated "Next" button with gradient text.
        *   Custom progress indicator with an animated wavy line.
        *   Refined UI for recorded audio/video playback elements.
*   **Animations:**
    *   Implemented card animation on selection to scroll the selected card to the beginning of the horizontal list.
    *   Implemented animation for the "Next" button width change when recording controls appear/disappear.
*   **State Management:** Currently uses `setState` for state management, which is suitable for this project's scope. *(Note: If you later integrate Riverpod/BLoC, update this section.)*
*   **API Client:** Uses a custom `ApiService` for API calls. *(Note: If you integrate `Dio` here for enhanced network operations, update this section.)*

## 🚀 Getting Started

1.  **Clone the repository:**
   
     git clone <your-github-repo-url>
     cd flutter-onboarding-questionnaire
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
