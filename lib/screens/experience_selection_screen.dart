import 'package:flutter/material.dart';
import 'experience.dart';
import 'api_service.dart';
import 'experience_model.dart';
import 'onboarding_question_screen.dart';

class ExperienceSelectionScreen extends StatefulWidget {
  @override
  _ExperienceSelectionScreenState createState() => _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen> {
  late ApiService _apiService;
  List<Experience> _experiences = [];
  List<int> _selectedExperienceIds = [];
  String _descriptionText = '';
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _descriptionController = TextEditingController();
  final int _descriptionCharLimit = 250;
  final ScrollController _scrollController = ScrollController(); // Added ScrollController

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchExperiences();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _fetchExperiences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final experiences = await _apiService.fetchExperiences();
      experiences.sort((a, b) => a.order.compareTo(b.order));
      setState(() {
        _experiences = experiences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load experiences. Please try again later.";
        _isLoading = false;
      });
      print("Error in _fetchExperiences: $e");
    }
  }

  void _toggleExperienceSelection(int id) {
    setState(() {
      if (_selectedExperienceIds.contains(id)) {
        _selectedExperienceIds.remove(id);
      } else {
        _selectedExperienceIds.add(id);
        _scrollToSelectedExperience(id); // Scroll to selected item
      }
    });
  }

  void _scrollToSelectedExperience(int id) {
    final int index = _experiences.indexWhere((exp) => exp.id == id);
    if (index != -1) {
      _scrollController.animateTo(
        index * (150 + 16).toDouble(), // Approximate item width + horizontal margin
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDescriptionChanged(String text) {
    setState(() {
      _descriptionText = text;
    });
  }

  void _onNextPressed() {
    print('Selected Experience IDs: $_selectedExperienceIds');
    print('Description: $_descriptionText');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OnboardingQuestionScreen(
          selectedExperienceIds: _selectedExperienceIds,
          hostDescription: _descriptionText,
        ),
      ),
    );
  }

  // --- UI Helper Methods ---
  Widget _buildProgressIndicator() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [Color(0xFF8A2BE2), Colors.purple.shade300, Colors.pink.shade200],
          stops: [0.0, 0.5, 1.0],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Container(
        width: 150,
        height: 40,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomPaint(
              size: Size(130, 6),
              painter: _WavyLinePainter(
                progress: 0.2,
                waveColor: Colors.white,
                backgroundColor: Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Experience experience, bool isSelected) {
    return ExperienceCard(
      experience: experience,
      isSelected: isSelected,
      onTap: () => _toggleExperienceSelection(experience.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if the description has at least one character and experiences are selected
    final bool isNextButtonEnabled = _selectedExperienceIds.isNotEmpty && _descriptionText.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildProgressIndicator(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What kind of experiences do you want to host?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),

                      Container(
                        height: 220,
                        child: ListView.builder(
                          controller: _scrollController, // Assign the controller
                          scrollDirection: Axis.horizontal,
                          itemCount: _experiences.length,
                          itemBuilder: (context, index) {
                            final experience = _experiences[index];
                            final isSelected = _selectedExperienceIds.contains(experience.id);
                            return _buildExperienceCard(experience, isSelected);
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      TextField(
                        controller: _descriptionController,
                        maxLength: _descriptionCharLimit,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '/Describe your perfect hotspot',
                          hintStyle: TextStyle(color: Colors.white54),
                          // Adjusted border and background to better match the design
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none, // No border line
                          ),
                          filled: true,
                          fillColor: Color(0xFF1E1E1E).withOpacity(0.8), // Darker background
                          contentPadding: EdgeInsets.all(12.0),
                          counterText: '', // Hide default counter text, we'll show it manually if needed
                        ),
                        onChanged: _onDescriptionChanged,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0), // Adjust padding as needed
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${_descriptionController.text.length}/$_descriptionCharLimit',
                            style: TextStyle(color: Colors.white70, fontSize: 12), // Smaller text for counter
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isNextButtonEnabled ? _onNextPressed : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            // Updated button style to be a dark gradient
                            backgroundColor: Color(0xFF1E1E1E), // Base color, gradient will be in foreground
                            foregroundColor: Colors.white, // Text color
                            shadowColor: Colors.black.withOpacity(0.6), // Shadow color
                            elevation: 5,
                          ),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [Colors.pink.shade300, Colors.purple.shade400, Colors.deepPurple.shade500],
                                stops: [0.0, 0.5, 1.0],
                                tileMode: TileMode.clamp,
                              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                            },
                            child: Text(
                              'Next',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), // Ensure text color is white within shader mask
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _WavyLinePainter extends CustomPainter {
  final double progress;
  final Color waveColor;
  final Color backgroundColor;

  _WavyLinePainter({
    required this.progress,
    required this.waveColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    final path = Path();
    path.moveTo(0, size.height / 2);

    final double waveHeight = size.height / 2;
    final double waveFrequency = 3;
    final double waveLength = size.width / waveFrequency;

    // Draw the wavy line based on progress
    for (double i = 0; i < size.width * progress; i += waveLength / 10) {
      path.quadraticBezierTo(
        i + waveLength / 4,
        size.height / 2 - waveHeight,
        i + waveLength / 2,
        size.height / 2,
      );
      path.quadraticBezierTo(
        i + 3 * waveLength / 4,
        size.height / 2 + waveHeight,
        i + waveLength,
        size.height / 2,
      );
    }
    
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _WavyLinePainter && oldDelegate.progress != progress;
  }
}
