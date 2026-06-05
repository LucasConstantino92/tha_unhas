class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role; // 'user' ou 'admin'

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );
  }
}
