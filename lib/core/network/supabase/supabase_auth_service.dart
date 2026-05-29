import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obter usuário logado atual
  User? get currentUser => _supabase.auth.currentUser;

  // Obter sessão atual
  Session? get currentSession => _supabase.auth.currentSession;

  // Stream para monitorar o estado de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Login com email e senha
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cadastro de novo usuário
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  // Logout do usuário
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Atualizar/recuperar token
  Future<Session?> refreshSession() async {
    final response = await _supabase.auth.refreshSession();
    return response.session;
  }
}
