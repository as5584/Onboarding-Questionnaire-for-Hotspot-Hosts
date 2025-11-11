import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Brightness
import 'package:transparent_image/transparent_image.dart'; // For placeholder
import 'experience_model.dart'; // Import your Experience model

class ExperienceCard extends StatefulWidget {
  final Experience experience;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onSlideToFirstIndex; // For brownie point animation

  ExperienceCard({
    required this.experience,
    required this.isSelected,
    required this.onTap,
    this.onSlideToFirstIndex,
  });

  @override
  _ExperienceCardState createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<RelativeRect> _rectAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300), // Animation duration
    );

    // Initialize animation if it needs to slide to the first index
    if (widget.isSelected && widget.onSlideToFirstIndex != null) {
      // This is a simplified approach. A more robust solution might use AnimatedList.
      // For now, we'll just trigger the animation if isSelected is true on init.
      // A better approach would be to manage this animation from the parent.
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to apply grayscale effect
  ColorFilter _buildGrayscaleFilter() {
    return ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: widget.experience.imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration(milliseconds: 300),
        fadeOutDuration: Duration(milliseconds: 300),
        imageErrorBuilder: (context, error, stackTrace) =>
            Container(
              color: Colors.grey[800],
              child: Icon(Icons.broken_image, color: Colors.white70),
            ),
      ),
    );

    // Apply grayscale only if NOT selected
    if (!widget.isSelected) {
      imageWidget = ColorFiltered(
        colorFilter: _buildGrayscaleFilter(),
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        width: 150,
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with conditional grayscale
            imageWidget,

            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),

            // Text content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.experience.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  if (widget.experience.tagline.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        widget.experience.tagline,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Selection indicator
            if (widget.isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: Colors.red, size: 24),
              ),
          ],
        ),
      ),
    );
  }
}