import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<UserEntity?> login(String email, String password) {
    return remoteDatasource.login(email, password);
  }

  @override
  Future<UserEntity?> register(String name, String email, String password) {
    return remoteDatasource.register(name, email, password);
  }

  @override
  Future<void> logout() {
    return remoteDatasource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return remoteDatasource.getCurrentUser();
  }
}
