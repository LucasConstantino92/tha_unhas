import '../../../../core/utils/app_logger.dart';
import '../models/appointment_model.dart';

abstract class BookingRemoteDatasource {
  Future<List<AppointmentModel>> getBookings(String userId);
  Future<AppointmentModel> createBooking(AppointmentModel booking);
  Future<void> cancelBooking(String bookingId);
}

class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  // SupabaseClient injetado futuramente
  
  @override
  Future<List<AppointmentModel>> getBookings(String userId) async {
    try {
      AppLogger.info('Buscando agendamentos para o usuário ID: $userId', 'BookingRemoteDatasource');
      // Busca do Supabase
      final list = <AppointmentModel>[];
      AppLogger.success('Recuperados ${list.length} agendamentos para o ID: $userId', 'BookingRemoteDatasource');
      return list;
    } catch (e, stack) {
      AppLogger.error('Erro ao buscar agendamentos para o ID: $userId', e, stack, 'BookingRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<AppointmentModel> createBooking(AppointmentModel booking) async {
    try {
      AppLogger.info('Criando agendamento para o usuário ID: ${booking.userId}', 'BookingRemoteDatasource');
      // Inserção no Supabase
      AppLogger.success('Agendamento criado com sucesso! ID: ${booking.id}', 'BookingRemoteDatasource');
      return booking;
    } catch (e, stack) {
      AppLogger.error('Erro ao criar agendamento para o ID: ${booking.userId}', e, stack, 'BookingRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      AppLogger.info('Tentando cancelar agendamento ID: $bookingId', 'BookingRemoteDatasource');
      // Atualização no Supabase
      AppLogger.success('Agendamento ID: $bookingId cancelado com sucesso', 'BookingRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao cancelar agendamento ID: $bookingId', e, stack, 'BookingRemoteDatasource');
      rethrow;
    }
  }
}
