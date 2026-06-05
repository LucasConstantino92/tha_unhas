import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

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

@Riverpod(keepAlive: true)
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

  Future<void> updateProfile(String name, String phone) async {
    final currentUser = state;
    if (currentUser == null) return;

    await ref.read(authRepositoryProvider).updateProfile(currentUser.id, name, phone);

    state = UserProfile(
      id: currentUser.id,
      name: name,
      phone: phone,
      email: currentUser.email,
      role: currentUser.role,
    );
  }

  Future<void> softDeleteAccount(List<String> appointmentsToCancel) async {
    final currentUser = state;
    if (currentUser == null) return;

    // 1. Cancel appointments
    for (final appointmentId in appointmentsToCancel) {
      await ref.read(bookingsListProvider.notifier).cancelBooking(appointmentId);
    }

    // 2. Soft delete user profile in DB
    await ref.read(authRepositoryProvider).softDeleteUser(currentUser.id);

    // 3. Log out
    await logout();
  }
}

extension WidgetRefSbExt on WidgetRef {
  UserProfile? get sb => watch(authProvider);
}

extension BuildContextSbExt on BuildContext {
  UserProfile? get sb {
    try {
      return ProviderScope.containerOf(this, listen: false).read(authProvider);
    } catch (_) {
      return null;
    }
  }
}

extension UserProfileNullableExt on UserProfile? {
  String get name => (this?.name == null || this!.name.trim().isEmpty) ? 'Cliente' : this!.name;
  String get phone => this?.phone ?? '';
  String get email => this?.email ?? '';
  String get role => (this?.role == null || this!.role.trim().isEmpty) ? 'user' : this!.role;
  bool get isAdmin => role.toLowerCase() == 'admin';
}
