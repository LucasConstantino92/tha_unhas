import '../../domain/entities/user_entity.dart';

class UserModel extends UserProfile {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: (json['name'] ?? json['nome'] ?? '') as String,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'phone': phone, 'role': role};
  }
}
