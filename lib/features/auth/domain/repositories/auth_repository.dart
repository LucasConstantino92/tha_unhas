import 'package:tha_unhas/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserProfile?> login(String email, String password);
  Future<UserProfile?> register(String name, String email, String password);
  Future<void> logout();
  Future<UserProfile?> getCurrentUser();
  Future<String?> signUp(String email, String password);
  Future<void> createUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateProfile(String userId, String name, String phone);
  Future<void> softDeleteUser(String userId);
}
