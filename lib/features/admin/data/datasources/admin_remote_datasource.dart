import '../models/admin_stats_model.dart';

abstract class AdminRemoteDatasource {
  Future<AdminStatsModel> getStats(int year, int month);
  Future<void> sendNotificationToAllUsers(String title, String body);
  Future<void> updateBookingStatus(String bookingId, String status);
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  // SupabaseClient injetado futuramente
  
  @override
  Future<AdminStatsModel> getStats(int year, int month) async {
    // Queries agregadas do Supabase
    return const AdminStatsModel(monthlyRevenue: 0.0, yearlyRevenue: 0.0, totalBookingsCount: 0);
  }

  @override
  Future<void> sendNotificationToAllUsers(String title, String body) async {
    // Disparo de notificação via Supabase Edge Function ou similar
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    // Altera o status na tabela de agendamentos no Supabase
  }
}
