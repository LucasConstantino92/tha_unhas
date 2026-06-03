import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(AuthRemoteDatasourceRef ref) {
  return AuthRemoteDatasourceImpl();
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
  );
}

@riverpod
class Auth extends _$Auth {
  @override
  UserProfile? build() {
    return null;
  }

  Future<UserProfile?> checkSession() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    state = user;
    return user;
  }

  Future<UserProfile?> login(String email, String password) async {
    final user = await ref.read(authRepositoryProvider).login(email, password);
    state = user;
    return user;
  }

  Future<UserProfile?> register(String name, String email, String password) async {
    final user = await ref.read(authRepositoryProvider).register(name, email, password);
    state = user;
    return user;
  }

  Future<String?> signUp(String email, String password) async {
    return ref.read(authRepositoryProvider).signUp(email, password);
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await ref.read(authRepositoryProvider).createUserProfile(profile);
    state = profile;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}
