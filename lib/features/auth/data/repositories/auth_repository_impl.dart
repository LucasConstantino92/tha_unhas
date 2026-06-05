import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<UserProfile?> login(String email, String password) {
    return remoteDatasource.login(email, password);
  }

  @override
  Future<UserProfile?> register(String name, String email, String password) {
    return remoteDatasource.register(name, email, password);
  }

  @override
  Future<void> logout() {
    return remoteDatasource.logout();
  }

  @override
  Future<UserProfile?> getCurrentUser() {
    return remoteDatasource.getCurrentUser();
  }

  @override
  Future<String?> signUp(String email, String password) {
    return remoteDatasource.signUp(email, password);
  }

  @override
  Future<void> createUserProfile(UserProfile profile) {
    final model = UserModel(
      id: profile.id,
      email: profile.email,
      name: profile.name,
      phone: profile.phone,
      role: profile.role,
    );
    return remoteDatasource.createUserProfile(model);
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) {
    return remoteDatasource.getUserProfile(userId);
  }

  @override
  Future<void> updateProfile(String userId, String name, String phone) {
    return remoteDatasource.updateProfile(userId, name, phone);
  }

  @override
  Future<void> softDeleteUser(String userId) {
    return remoteDatasource.softDeleteUser(userId);
  }
}
