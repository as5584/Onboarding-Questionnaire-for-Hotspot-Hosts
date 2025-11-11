class Experience {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String iconUrl;
  final int order; // Added from your provided data

  Experience({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.iconUrl,
    required this.order,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      name: json['name'],
      tagline: json['tagline'] ?? '', // Handle potential null tagline
      description: json['description'],
      imageUrl: json['image_url'],
      iconUrl: json['icon_url'],
      order: json['order'],
    );
  }
}
