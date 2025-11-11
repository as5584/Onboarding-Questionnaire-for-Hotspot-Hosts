import 'package:flutter/material.dart';
import 'package:luminus/screens/experience_selection_screen.dart'; // Import the new screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Onboarding Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // You can define your app's theme here, e.g., colors, fonts
        // For example, to match the dark theme in the screenshots:
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white, // Color of icons and title in AppBar
          elevation: 0, // Remove shadow
        ),
        // Define other theme properties as needed
      ),
      home: ExperienceSelectionScreen(), // Set ExperienceSelectionScreen as the home screen
    );
  }
}
