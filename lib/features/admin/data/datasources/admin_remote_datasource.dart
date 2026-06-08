import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/supabase/sb_tables.dart';
import '../models/admin_stats_model.dart';
import '../models/work_schedule_model.dart';

abstract class AdminRemoteDatasource {
  Future<AdminStatsModel> getStats(int year, int month);
  Future<void> sendNotificationToAllUsers(String title, String body);
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<List<WorkScheduleModel>> getWorkSchedules();
  Future<void> addWorkSchedule(WorkScheduleModel model);
  Future<void> deleteWorkSchedule(String id);
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final SupabaseClient _supabaseClient;

  AdminRemoteDatasourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<AdminStatsModel> getStats(int year, int month) async {
    try {
      AppLogger.info('Buscando estatísticas do Supabase para $month/$year', 'AdminRemoteDatasource');
      
      final startOfYear = DateTime(year, 1, 1).toUtc().toIso8601String();
      final endOfYear = DateTime(year + 1, 1, 1).toUtc().toIso8601String();

      final response = await _supabaseClient
          .from('appointments')
          .select('paid_price, start_time, status')
          .gte('start_time', startOfYear)
          .lt('start_time', endOfYear);

      double monthlyRevenue = 0.0;
      double potentialMonthlyRevenue = 0.0;
      double yearlyRevenue = 0.0;
      int totalBookingsCount = 0;

      for (final row in response) {
        final status = row['status'] as String? ?? '';
        final price = (row['paid_price'] as num?)?.toDouble() ?? 0.0;
        final startTimeStr = row['start_time'] as String;
        final startTime = DateTime.parse(startTimeStr);

        // Somar receitas de agendamentos concluídos
        if (status == 'completed') {
          yearlyRevenue += price;
          if (startTime.month == month) {
            monthlyRevenue += price;
          }
        }
        
        // Receita potencial (confirmados ou em andamento)
        if (status == 'confirmed' || status == 'in_progress') {
          // Opcional: adicionar yearly potential se precisar, mas aqui pede só do mês ou total
          if (startTime.month == month) {
            potentialMonthlyRevenue += price;
          }
        }

        // Contador total de agendamentos no mês selecionado (ignorar cancelados e testes no_show)
        if (startTime.month == month && status != 'cancelled' && status != 'no_show') {
          totalBookingsCount++;
        }
      }

      AppLogger.success('Estatísticas agregadas com sucesso para $month/$year', 'AdminRemoteDatasource');
      return AdminStatsModel(
        monthlyRevenue: monthlyRevenue,
        potentialMonthlyRevenue: potentialMonthlyRevenue,
        yearlyRevenue: yearlyRevenue,
        totalBookingsCount: totalBookingsCount,
      );
    } catch (e, stack) {
      AppLogger.error('Erro ao buscar estatísticas do Supabase', e, stack, 'AdminRemoteDatasource');
      return const AdminStatsModel(
        monthlyRevenue: 0.0,
        potentialMonthlyRevenue: 0.0,
        yearlyRevenue: 0.0,
        totalBookingsCount: 0,
      );
    }
  }

  @override
  Future<void> sendNotificationToAllUsers(String title, String body) async {
    // Disparo de notificação via Supabase Edge Function ou similar
    AppLogger.info('Tentando disparar notificações em massa: $title', 'AdminRemoteDatasource');
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      AppLogger.info('Atualizando status do agendamento ID: $bookingId para $status no Supabase', 'AdminRemoteDatasource');
      final helper = SBTables.appointments.helper(_supabaseClient);
      
      await helper.update(
        data: {'status': status},
        where: {'id': bookingId},
      );
      AppLogger.success('Status do agendamento ID: $bookingId atualizado para $status', 'AdminRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao atualizar status do agendamento ID: $bookingId', e, stack, 'AdminRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<List<WorkScheduleModel>> getWorkSchedules() async {
    try {
      AppLogger.info('Buscando bloqueios de agenda do Supabase', 'AdminRemoteDatasource');
      final response = await _supabaseClient
          .from('work_schedules')
          .select()
          .order('start_time', ascending: true);
      
      final list = (response as List<dynamic>)
          .map((json) => WorkScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();
      AppLogger.success('Recuperados ${list.length} bloqueios de agenda', 'AdminRemoteDatasource');
      return list;
    } catch (e, stack) {
      AppLogger.error('Erro ao buscar bloqueios de agenda', e, stack, 'AdminRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> addWorkSchedule(WorkScheduleModel model) async {
    try {
      AppLogger.info('Adicionando bloqueio de agenda no Supabase', 'AdminRemoteDatasource');
      final helper = SBTables.workSchedules.helper(_supabaseClient);
      final data = model.toJson();
      await helper.insert(data);
      AppLogger.success('Bloqueio de agenda adicionado com sucesso', 'AdminRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao adicionar bloqueio de agenda', e, stack, 'AdminRemoteDatasource');
      rethrow;
    }
  }

  @override
  Future<void> deleteWorkSchedule(String id) async {
    try {
      AppLogger.info('Removendo bloqueio de agenda ID: $id no Supabase', 'AdminRemoteDatasource');
      final helper = SBTables.workSchedules.helper(_supabaseClient);
      await helper.delete({'id': id});
      AppLogger.success('Bloqueio de agenda ID: $id removido com sucesso', 'AdminRemoteDatasource');
    } catch (e, stack) {
      AppLogger.error('Erro ao remover bloqueio de agenda ID: $id', e, stack, 'AdminRemoteDatasource');
      rethrow;
    }
  }
}
