import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String name, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDatasourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<UserModel?> login(String email, String password) async {
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) return null;
    return _getUserModelFromSupabaseUser(user);
  }

  @override
  Future<UserModel?> register(String name, String email, String password) async {
    final response = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': 'user',
      },
    );
    final user = response.user;
    if (user == null) return null;
    return _getUserModelFromSupabaseUser(user);
  }

  @override
  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;
    return _getUserModelFromSupabaseUser(user);
  }

  UserModel _getUserModelFromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name'] as String? ?? '',
      role: metadata['role'] as String? ?? 'user',
    );
  }
}
