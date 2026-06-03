class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role; // 'user' ou 'admin'

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user', // Default caso venha nulo
    );
  }
}
