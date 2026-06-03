import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String name, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<String?> signUp(String email, String password);
  Future<void> createUserProfile(UserModel profile);
  Future<UserModel?> getUserProfile(String userId);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _supabaseClient;

  AuthRemoteDatasourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      AppLogger.info('Tentativa de login para o e-mail: $email', 'AuthRemoteDatasource');
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        AppLogger.error('Usuário retornado nulo no login para o e-mail: $email', null, null, 'AuthRemoteDatasource');
        return null;
      }
      AppLogger.success('Login efetuado com sucesso para o e-mail: $email', 'AuthRemoteDatasource');
      return getCurrentUser();
    } catch (e, stack) {
      AppLogger.error('Erro ao realizar login para o e-mail: $email', e, stack, 'AuthRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<UserModel?> register(String name, String email, String password) async {
    try {
      AppLogger.info('Tentativa de registro (completo) para o e-mail: $email (Nome: $name)', 'AuthRemoteDatasource');
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        AppLogger.error('Usuário retornado nulo no registro para o e-mail: $email', null, null, 'AuthRemoteDatasource');
        return null;
      }

      final userModel = UserModel(
        id: user.id,
        email: email,
        name: name,
        phone: '',
        role: 'user',
      );
      await createUserProfile(userModel);
      AppLogger.success('Registro completo finalizado para o e-mail: $email', 'AuthRemoteDatasource');
      return userModel;
    } catch (e, stack) {
      AppLogger.error('Erro ao realizar registro completo para o e-mail: $email', e, stack, 'AuthRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<String?> signUp(String email, String password) async {
    try {
      AppLogger.info('Criando conta de e-mail e senha no Supabase Auth para: $email', 'AuthRemoteDatasource');
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      final userId = response.user?.id;
      if (userId == null) {
        AppLogger.error('Nenhum userId retornado no signUp para o e-mail: $email', null, null, 'AuthRemoteDatasource');
      } else {
        AppLogger.success('Conta do Supabase Auth criada para o e-mail: $email | ID: $userId', 'AuthRemoteDatasource');
      }
      return userId;
    } catch (e, stack) {
      AppLogger.error('Erro ao realizar signUp no Supabase Auth para o e-mail: $email', e, stack, 'AuthRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> createUserProfile(UserModel profile) async {
    try {
      AppLogger.info('Inserindo/Atualizando perfil de usuário no user_profiles: ${profile.id} (Nome: ${profile.name})', 'AuthRemoteDatasource');
      await _supabaseClient.from('user_profiles').upsert(profile.toJson());
      AppLogger.success('Perfil de usuário salvo com sucesso no user_profiles: ${profile.id}', 'AuthRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao salvar perfil no user_profiles para o ID: ${profile.id}', e, stack, 'AuthRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      AppLogger.info('Buscando perfil de usuário no user_profiles para o ID: $userId', 'AuthRemoteDatasource');
      final response = await _supabaseClient
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response == null) {
        AppLogger.info('Nenhum perfil encontrado no user_profiles para o ID: $userId', 'AuthRemoteDatasource');
        return null;
      }
      AppLogger.success('Perfil do user_profiles recuperado para o ID: $userId', 'AuthRemoteDatasource');
      return UserModel.fromJson(response);
    } catch (e, stack) {
      AppLogger.error('Erro ao buscar perfil no user_profiles para o ID: $userId', e, stack, 'AuthRemoteDatasource');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.info('Realizando logout da sessão ativa', 'AuthRemoteDatasource');
      await _supabaseClient.auth.signOut();
      AppLogger.success('Logout realizado com sucesso', 'AuthRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao fazer logout', e, stack, 'AuthRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      AppLogger.info('Verificando sessão ativa de usuário', 'AuthRemoteDatasource');
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        AppLogger.info('Nenhuma sessão ativa encontrada (usuário deslogado)', 'AuthRemoteDatasource');
        return null;
      }

      AppLogger.info('Sessão ativa encontrada (ID: ${user.id}). Verificando tabela user_profiles...', 'AuthRemoteDatasource');
      final profile = await getUserProfile(user.id);
      if (profile == null) {
        AppLogger.info('Perfil do user_profiles não encontrado para o ID: ${user.id} (Precisa preencher cadastro)', 'AuthRemoteDatasource');
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          name: '',
          phone: '',
          role: 'user',
        );
      }
      AppLogger.success('Usuário atual carregado completamente com sessão e perfil', 'AuthRemoteDatasource');
      return profile;
    } catch (e, stack) {
      AppLogger.error('Erro no fluxo getCurrentUser', e, stack, 'AuthRemoteDatasource');
      return null;
    }
  }
}
