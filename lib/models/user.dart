class UserModel {
  final int id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  // Maps the incoming Laravel API JSON response directly to your Flutter App
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Guest Client', // Maps to $fillable 'name'
      email: json['email'] ?? '',            // Maps to $fillable 'email'
    );
  }

  // Converts the user object to JSON if you need to send profile updates to Laravel
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}