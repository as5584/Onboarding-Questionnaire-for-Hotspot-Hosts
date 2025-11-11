import 'package:dio/dio.dart';
import 'experience_model.dart'; // Corrected path and assumed model file name

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://staging.chamberofsecrets.8club.co/v1/experiences?active=true";

  Future<List<Experience>> fetchExperiences() async {
    try {
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        // Ensure response.data is treated as a Map
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> experienceList = responseData['data']['experiences'];
        return experienceList.map((json) => Experience.fromJson(json)).toList();
      }
      else {
        // Handle non-200 status codes
        throw Exception('Failed to load experiences: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching experiences: $e");
      throw e; // Re-throw the exception to be handled by the caller
    }
  }
}