import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/supabase/sb_tables.dart';
import '../models/appointment_model.dart';

abstract class BookingRemoteDatasource {
  Future<List<AppointmentModel>> getBookings(String userId);
  Future<AppointmentModel> createBooking(AppointmentModel booking);
  Future<void> cancelBooking(String bookingId);
}

class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  final SupabaseClient _supabaseClient;

  BookingRemoteDatasourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<List<AppointmentModel>> getBookings(String userId) async {
    try {
      AppLogger.info('Buscando agendamentos para o usuário ID: $userId no Supabase', 'BookingRemoteDatasource');
      
      // Verificar se o usuário é administrador para determinar se trazemos todos os agendamentos ou apenas os dele.
      final profileResponse = await _supabaseClient
          .from('user_profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      
      final isAdmin = profileResponse != null && profileResponse['role'] == 'admin';
      
      final List<dynamic> response;
      if (isAdmin) {
        AppLogger.info('Usuário é administrador. Buscando TODOS os agendamentos com detalhes do cliente/serviço.', 'BookingRemoteDatasource');
        response = await _supabaseClient
            .from('appointments')
            .select('*, user_profiles(name, phone, email), services(name)')
            .order('start_time', ascending: true);
      } else {
        AppLogger.info('Usuário comum. Buscando apenas os agendamentos associados a ele.', 'BookingRemoteDatasource');
        response = await _supabaseClient
            .from('appointments')
            .select('*, user_profiles(name, phone, email), services(name)')
            .eq('user_id', userId)
            .order('start_time', ascending: true);
      }

      final list = response
          .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.success('Recuperados ${list.length} agendamentos', 'BookingRemoteDatasource');
      return list;
    } catch (e, stack) {
      AppLogger.error('Erro ao buscar agendamentos', e, stack, 'BookingRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<AppointmentModel> createBooking(AppointmentModel booking) async {
    try {
      AppLogger.info('Criando agendamento para o usuário ID: ${booking.userId} no Supabase', 'BookingRemoteDatasource');
      final helper = SBTables.appointments.helper(_supabaseClient);
      final data = booking.toJson();
      if (booking.id.isEmpty) {
        data.remove('id'); // Deixar o Supabase gerar o UUID
      }
      
      final inserted = await helper.insertWithReturn(data, columns: '*');
      final model = AppointmentModel.fromJson(inserted);
      AppLogger.success('Agendamento criado com sucesso! ID: ${model.id}', 'BookingRemoteDatasource');
      return model;
    } catch (e, stack) {
      AppLogger.error('Erro ao criar agendamento para o ID: ${booking.userId}', e, stack, 'BookingRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      AppLogger.info('Tentando cancelar agendamento ID: $bookingId no Supabase', 'BookingRemoteDatasource');
      final helper = SBTables.appointments.helper(_supabaseClient);
      
      await helper.update(
        data: {'status': 'cancelled'},
        where: {'id': bookingId},
      );
      
      AppLogger.success('Agendamento ID: $bookingId cancelado com sucesso', 'BookingRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao cancelar agendamento ID: $bookingId', e, stack, 'BookingRemoteDatasource');
      rethrow;
    }
  }
}
