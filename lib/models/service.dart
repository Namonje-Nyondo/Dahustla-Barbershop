class ServiceModel {
  final int id;
  final String name;
  final double price;
  final int duration;
  final String description;
  final String? imageUrl; // Optional field

  const ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    this.imageUrl, // FIXED: Added to constructor
  });

  // Safe parsing factory to translate your Laravel/MySQL payloads dynamically
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      // Use double.tryParse and .toString() to handle both "25.00" and 25.0 safely
      id: int.tryParse(json['id'].toString()) ?? 0,

      // Maps 'service_name' from Laravel to 'name' in Flutter
      name: json['service_name'] ?? json['name'] ?? 'Premium Grooming Cut',

      // FIXED: Safe parsing for decimal strings from MySQL
      price: double.tryParse(json['price'].toString()) ?? 0.0,

      // FIXED: Safe parsing for duration integers
      duration: int.tryParse(json['duration'].toString()) ?? 30,

      description: json['description'] ?? '',

      // FIXED: correctly placed inside the return statement
      imageUrl: json['image_url'],
    );
  }

  // Converts a Dart object instance back into a JSON-ready Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'image_url': imageUrl,
    };
  }
}