import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  );
});

class AuthNotifier extends StateNotifier<UserProfile?> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(null);

  Future<UserProfile?> checkSession() async {
    final user = await _authRepository.getCurrentUser();
    state = user;
    return user;
  }

  Future<UserProfile?> login(String email, String password) async {
    final user = await _authRepository.login(email, password);
    state = user;
    return user;
  }

  Future<UserProfile?> register(String name, String email, String password) async {
    final user = await _authRepository.register(name, email, password);
    state = user;
    return user;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = null;
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
