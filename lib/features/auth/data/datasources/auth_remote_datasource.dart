import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String name, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  // Aqui injetaremos a dependência do SupabaseClient no futuro
  
  @override
  Future<UserModel?> login(String email, String password) async {
    // Implementação Supabase
    return null;
  }

  @override
  Future<UserModel?> register(String name, String email, String password) async {
    // Implementação Supabase
    return null;
  }

  @override
  Future<void> logout() async {
    // Implementação Supabase
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Implementação Supabase
    return null;
  }
}
