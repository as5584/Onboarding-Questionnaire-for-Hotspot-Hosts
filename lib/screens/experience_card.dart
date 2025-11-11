import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'experience_model.dart';
import 'experience_card.dart';

class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final bool isSelected;
  final VoidCallback onTap;

  const ExperienceCard({
    Key? key,
    required this.experience,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  ColorFilter _buildGrayscaleFilter() {
    return const ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(0.0), // Removed border radius to match design
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: experience.imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        imageErrorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white70),
        ),
      ),
    );

    if (!isSelected) {
      imageWidget = ColorFiltered(
        colorFilter: _buildGrayscaleFilter(),
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        width: 150,
        height: 200,
        child: ClipPath(
          clipper: _StampClipper(), // Custom clipper for the stamp effect
          child: Container(
            padding: const EdgeInsets.all(4), // Padding to create the "stamp border"
            color: Colors.white.withOpacity(0.9), // Border color
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageWidget,
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                        Colors.transparent
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    experience.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0, // Adjusted font size slightly
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Clipper to create the "postage stamp" effect
class _StampClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notchSize = 8.0;
    const double cornerRadius = 4.0;
    
    final path = Path();
    
    // Top-left corner
    path.moveTo(0, cornerRadius);
    path.arcToPoint(Offset(cornerRadius, 0), radius: Radius.circular(cornerRadius));
    
    // Top edge with notches
    for (double i = cornerRadius; i < size.width - cornerRadius; i += notchSize * 2) {
      path.lineTo(i + notchSize / 2, 0);
      path.arcToPoint(Offset(i + notchSize * 1.5, 0), radius: Radius.circular(notchSize / 2), clockwise: false);
    }
    path.lineTo(size.width - cornerRadius, 0);
    
    // Top-right corner
    path.arcToPoint(Offset(size.width, cornerRadius), radius: Radius.circular(cornerRadius));

    // Right edge with notches
    for (double i = cornerRadius; i < size.height - cornerRadius; i += notchSize * 2) {
      path.lineTo(size.width, i + notchSize / 2);
      path.arcToPoint(Offset(size.width, i + notchSize * 1.5), radius: Radius.circular(notchSize / 2), clockwise: false);
    }
    path.lineTo(size.width, size.height - cornerRadius);
    
    // Bottom-right corner
    path.arcToPoint(Offset(size.width - cornerRadius, size.height), radius: Radius.circular(cornerRadius));

    // Bottom edge with notches
    for (double i = size.width - cornerRadius; i > cornerRadius; i -= notchSize * 2) {
      path.lineTo(i - notchSize / 2, size.height);
      path.arcToPoint(Offset(i - notchSize * 1.5, size.height), radius: Radius.circular(notchSize / 2), clockwise: false);
    }
    path.lineTo(cornerRadius, size.height);
    
    // Bottom-left corner
    path.arcToPoint(Offset(0, size.height - cornerRadius), radius: Radius.circular(cornerRadius));
    
    // Left edge with notches
    for (double i = size.height - cornerRadius; i > cornerRadius; i -= notchSize * 2) {
      path.lineTo(0, i - notchSize / 2);
      path.arcToPoint(Offset(0, i - notchSize * 1.5), radius: Radius.circular(notchSize / 2), clockwise: false);
    }
    path.lineTo(0, cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
